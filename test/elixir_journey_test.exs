defmodule ElixirJourneyTest do
  use ExUnit.Case
  #doctest ElixirJourney

  # test "Unable to find exercise file test" do
  #   assert {:error, _} = ElixirJourney.verify(:hello_world)
  # end

  test "execurte exercise stdio" do
    assert ElixirJourney.verify(:hello_world) == true
  end

  test "print exercise description" do
    assert ElixirJourney.description(:hello_world) == :ok
  end

  @tag :focus
  test "load exercises" do
    assert ElixirJourney.exercises("/home/fred/apps/functional_elixir/lib/exercises") == ""
  end

end
