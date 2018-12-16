defmodule SlackGameEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      if Mix.env() == :test do
        []
      else
        [
          {Registry, keys: :unique, name: SlackGameEx.TicTacToe.Registry},
          SlackGameEx.TicTacToe.Supervisor,
          {SlackGameEx.TicTacToe.Bot, auth_token()}
        ]
      end

    opts = [strategy: :one_for_one, name: SlackGameEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def auth_token do
    Application.get_env(:slack_game_ex, :auth_token)
  end
end
