defmodule ExerciseTest do
  use ExUnit.Case
  alias ElixirJourney.Exercise

  test "execute functions" do
    val = fn
      (a = 10, b) ->
        a + b
      (a, b) ->
        a * b
    end

    assert Exercise.execute(:function, val, [10, 10])  == 20
    assert Exercise.execute(:function, val, [11, 10])  == 110
  end
end
