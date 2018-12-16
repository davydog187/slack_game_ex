defmodule SlackGameEx.TicTacToe.Server do
  use GenServer

  alias SlackGameEx.TicTacToe.Game

  def start_link(opts) do
    GenServer.start_link(__MODULE__, Game.new(), opts)
  end

  def print(pid) do
    GenServer.call(pid, :print)
  end

  def random_move(pid) do
    GenServer.call(pid, {:move, :random})
  end

  def move(pid, position) do
    GenServer.call(pid, {:move, position})
  end

  def restart(pid) do
    GenServer.cast(pid, :restart)
  end

  ## Server
  def init(game) do
    {:ok, %{game: game}}
  end

  def handle_call({:move, position}, _from, state) do
    move =
      case position do
        :random -> Game.random_move(state.game)
        number -> Game.move(state.game, number)
      end

    case move do
      {:win, player, game} ->
        {:reply, {:win, player}, %{state | game: game}}

      {:tie, game} ->
        {:reply, {:tie, game}, %{state | game: game}}

      {:playing, game} ->
        {:reply, {:playing, game}, %{state | game: game}}

      :error ->
        {:reply, :error, state}
    end
  end

  def handle_cast(:restart, state) do
    {:noreply, %{state | game: Game.new()}}
  end

  def handle_call(:print, _from, state) do
    {:reply, Game.print(state.game), state}
  end
end
