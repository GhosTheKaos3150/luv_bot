defmodule LuvbotTest do
  use ExUnit.Case
  doctest Luvbot

  test "greets the world" do
    assert Luvbot.hello() == :world
  end
end
