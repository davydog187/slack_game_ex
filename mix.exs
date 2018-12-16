defmodule SlackGameEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_game_ex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SlackGameEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:websockex, "~> 0.4.0"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"}
    ]
  end
end
