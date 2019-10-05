defmodule ElixirJourneyTest do
  use ExUnit.Case
  alias ElixirJourney.ExerciseState
  #doctest ElixirJourney

  # test "Unable to find exercise file test" do
  #   assert {:error, _} = ElixirJourney.verify(:hello_world)
  # end

  test "execurte exercise stdio" do
    assert ElixirJourney.verify(:hello_world) == true
  end

  @tag :ex
  test "print exercise description" do
    ElixirJourney.exercises("lib/exercises")
    ElixirJourney.docs(:hello_world)
  end

  @tag :focus
  test "load exercises" do
    assert ElixirJourney.exercises("lib/exercises") == :ok
    assert {_meta, exercises} = :sys.get_state(ElixirJourney.ExerciseState)
    assert %{slug: :anonymous_functions} = exercises[:anonymous_functions]
    assert %{slug: :hello_world} = exercises[:hello_world]
    assert %{module: module} = exercises[:anonymous_functions]
    module.run("")
  end

  @tag :wip
  test "run and verify solution" do
    ElixirJourney.exercises("lib/exercises")
    ElixirJourney.run(:anonymous_functions, "lib/exercises/solutions/anonymous_functions.exs")
  end


end
