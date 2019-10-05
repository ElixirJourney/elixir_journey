defmodule FunctionalElixir.AnonymousFunctions do

  use ElixirJourney.Exercise,
    slug: "anonymous_functions",
    name: "Anonymous Functions",
    type: :function,
    exercise_dir: "./",
    exercise_file: "ano.exs",
    solution_dir: "lib/exercises/",
    solution_file: "anonymous_functions_solution.exs"

  use ElixirJourney.Assertion

  @moduledoc """
  #Exercercise
  Create an anonymous function that recieves two numbers and returns the adition of the two numbers if the first one equals 10, otherwise the multiplication of the numbers and then execute the funcition.


  #Hints
  Elixir is a functional language, so functions are a basic type and first class citizens.

  This is the basic syntaxis of an anonymous function:

  ```elixir
  fn
     parameters -> body
     parameters -> body
     ...
  end
  ```

  You can see multiple parameters because functions in Elixir accept pattern mantching too.
  When you write an anonymous function like this:

  ```elixir
  sum = fn(a, b) -> a + b end
  ```

  Elixir is trying to matching the values with the pattern, so when you call `sum.(23,2)` then Elixir makes the pattern match by binding `a` to the value of `23`. This opens a world of posibilities when you can write multiple implementations to a single function.


  """

  @doc """
  Journey DSL
  {keyword} [params] == response
  test "name of the test" do
     verify [10, 10] == 110
     verify [12, 10] == 22
  end

  """
  test_case "asssertion verify" do
    verify  [10,20] == 30
    verify [11, 11] == 121
  end
end
