defmodule SlackGameExTest do
  use ExUnit.Case
  doctest SlackGameEx

  test "greets the world" do
    assert SlackGameEx.hello() == :world
  end
end
