defmodule ElixirJourney.Assertion do

  defmacro verify({:==, _meta, [left, right]}) do
    quote bind_quoted: [left: left, right: right] do
      %{type: ex_type} = __MODULE__.exercise
      options = var!(options, ElixirJourney.Assertion)
       ElixirJourney.Test.assert(left, right, ex_type, options)
    end
  end

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro test_case(description, do: block) do

    fn_name = description
    |> String.downcase
    |> String.replace(~r/[^a-zA-Z0-9]/,"_")
    |> String.to_atom

    # {:verify, ver_meta , verify} = block
    # verify_block = verify ++ [{:options, [], Elixir}]
    # #verify_block = verify ++ ["file path"]
    # new_block = {:verify, ver_meta , verify_block}

    quote do
      @tests {unquote(fn_name), unquote(description)}
      def unquote(fn_name)(options) do
        var!(options, ElixirJourney.Assertion) = options
        unquote(block)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run(exercise_file) do
        IO.puts("running all my test cases #{inspect @tests} #{exercise_file}")
        ElixirJourney.Test.run(@tests, __MODULE__, exercise_file)
      end
    end
  end
end

defmodule ElixirJourney.Test do

  def run(tests, module, exercise_file) do
    Enum.each(tests, fn({test_fn, description}) ->
      case apply(module, test_fn, exercise_file: exercise_file) do
        :ok ->
          IO.write("Test case #{description} pass\n")
        {:fail, reason} -> IO.puts """
        ============================
        Failure: #{description}
        ============================
        #{reason}
        """
        response -> IO.write("Teest case #{inspect response} for #{description}")
      end

    end)
  end
  def assert(left, right, ex_type = :function, options) do
    IO.inspect("--------")
    {:exercise_file, file} = options
    ElixirJourney.verify(ex_type, file, left, right)
  end

  def assert(left, right) when left == right do
    :ok
  end

  def assert(left, right) do
    {:fail,  """
    Expected: #{left}
    To be equal to: #{right}
    """}
  end
end

# defmodule ElixirJourney.MathTest do

#   use  ElixirJourney.Assertion
#   test "test 1 macro" do
#     assert 1 == 1
#     assert "ad" == "88"
#     assert true == true
#     assert 10 *10 == 100
#   end

#   test "test macro 2" do
#     assert :new == :new
#   end
#   # def run do
#   #   assert 1 == 1
#   #   assert "ad" == "88"
#   #   assert true == true
#   #   assert 10 *10 == 100
#   # end
# end

# ElixirJourney.MathTest.run
