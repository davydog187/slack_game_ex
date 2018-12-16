defmodule SlackGameEx.TicTacToe.Game do
  defstruct board: %{}, player: :one, available: nil

  def new do
    %__MODULE__{available: MapSet.new(1..9)}
  end

  def random_move(%__MODULE__{board: board} = game) do
    if MapSet.size(game.available) == 0 do
      :error
    else
      position = Enum.random(game.available)
      board = Map.put(board, position, game.player)
      available = MapSet.delete(game.available, position)

      game_state(%{game | board: board, available: available})
    end
  end

  @doc """
  iex> game = new()
  iex> move(game, 1)
  {:playing, %SlackGameEx.TicTacToe.Game{
    available: MapSet.new(2..9),
    board: %{1 => :one},
    player: :two
  }}
  """
  def move(%__MODULE__{board: board} = game, position) when position >= 1 and position <= 9 do
    if Map.has_key?(board, position) do
      :error
    else
      board = Map.put(board, position, game.player)
      available = MapSet.delete(game.available, position)

      game_state(%{game | board: board, available: available})
    end
  end

  defp game_state(%{board: board} = game) do
    cond do
      won?(game) -> {{:win, game.player}, game}
      Map.size(board) == 9 -> {:tie, game}
      true -> {:playing, %{game | player: next_player(game.player)}}
    end
  end

  def print(%__MODULE__{board: board}) do
    for x <- 1..9 do
      case Map.get(board, x) do
        nil -> x
        :one -> "X"
        :two -> "O"
      end
    end
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join(&1, " | "))
    |> Enum.join("\n----------\n")
  end

  defp won?(%__MODULE__{board: board}) do
    lines = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 5, 9],
      [3, 5, 7]
    ]

    Enum.any?(lines, fn [first | rest] ->
      first = Map.get(board, first, :error)

      Enum.all?(rest, fn index -> Map.get(board, index) == first end)
    end)
  end

  defp next_player(player) do
    case player do
      :one -> :two
      :two -> :one
    end
  end
end
