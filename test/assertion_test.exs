defmodule AssertionTest do

  use ExUnit.Case
  import ElixirJourney.Assertion

  test "Assert macro test" do
    assert assert Code.ensure_loaded?(ElixirJourney.Assertion )
    assert ElixirJourney.Assertion.verify([]) == ""
  end
end
