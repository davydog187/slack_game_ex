defmodule SlackGameEx.TicTacToe.Bot do
  use SlackGameEx.Slack.Bot

  alias SlackGameEx.TicTacToe
  alias SlackGameEx.TicTacToe.Game

  require Logger

  def init(state) do
    log("got init")
    {:ok, state}
  end

  def handle_event({:message, "restart", message}, state) do
    with {:ok, game} <- TicTacToe.Supervisor.find_game(key(message)) do
      :ok = TicTacToe.Server.restart(game)

      reply = """
      Restarted the game.

      ```
      #{TicTacToe.Server.print(game)}
      ```
      """

      {:reply, reply, state}
    else
      _ -> {:reply, "Could not restart the game. Would you like to start one?", state}
    end
  end

  def handle_event({:message, "print game", message}, state) do
    with {:ok, game} <- TicTacToe.Supervisor.find_game(key(message)) do
      reply = """
      Current game board:

      ```
      #{TicTacToe.Server.print(game)}
      ```
      """

      {:reply, reply, state}
    else
      _ -> {:reply, "Could not print the game. Would you like to start one?", state}
    end

  end

  def handle_event({:message, "new game", message}, state) do
    {:ok, game} = TicTacToe.Supervisor.find_or_start_game(key(message))

    reply = """
    Starting a new game of tic tac toe!

    ```
    #{TicTacToe.Server.print(game)}
    ```
    """

    {:reply, reply, state}
  end

  def handle_event({:message, "move " <> position, message}, state) do
    with {position, _} <- Integer.parse(position),
         {:ok, game} <- TicTacToe.Supervisor.find_game(key(message)) do

      reply =
        case TicTacToe.Server.move(game, position) do
          {:win, player} ->
            "You won player #{player}! Nice!"
          {:tie, _game} ->
            "Looks like it was a tie"
          {:playing, game} ->
            Process.send_after(self(), {:bot_move, key(message), message["channel"]}, 1000)

            """
            You moved.

            ```
            #{TicTacToe.Game.print(game)}
            ```
            """
          :error ->
            "Something went wrong"
        end

      {:reply, reply, state}
    else
      :error ->
        {:reply, "`#{position}` is not a valid move", state}
    end
  end

  def handle_event({:message, text, channel}, state) do
    {:reply, "got your message: #{text}", channel, state}
  end

  def handle_info({:bot_move, key, channel} = message, state) do
    IO.inspect message, label: "bot movin"

    send_message(channel, "bot movin!", state)
  end

  defp log(message) do
    Logger.info("#{inspect(__MODULE__)} #{message}")
  end

  defp key(%{"user" => user}) do
    {:tictactoe, user}
  end
end
