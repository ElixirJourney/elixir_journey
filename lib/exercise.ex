defmodule ElixirJourney.Exercise do

  require Logger
  defstruct name: "", slug: "", exercise_dir: "", exercise_file: "", sulution_dir: "", solution_file: "", type: "", module: nil, docs: ""

  defmacro __using__(opts) do

    quote do
      import unquote(__MODULE__)
      @exercise %ElixirJourney.Exercise{
        name: unquote(Keyword.get(opts, :name)),
        slug: unquote(Keyword.get(opts, :slug)) || "",
        type: unquote(Keyword.get(opts, :type)) || "",
        exercise_dir: unquote(Keyword.get(opts, :exercise_dir)) || "",
        exercise_file: unquote(Keyword.get(opts, :exercise_file)) || "",
        solution_file: unquote(Keyword.get(opts, :solution_file)) || "",
      }
      def exercise do
        @exercise
      end
    end
  end
  def process(exercise, options) do
    ## load exercise
    ## execute exercise
  end

  def execute(:stdout, exercise) do
    original_stderr = Process.whereis(:standard_error)
    Process.unregister(:standard_error)
    {:ok, dev} = StringIO.open("")
    Process.register(dev, :standard_error)
    Code.eval_file(exercise, File.cwd!) |> elem(0)
    captured = StringIO.flush(dev)
    Process.unregister(:standard_error)
    Process.register(original_stderr, :standard_error)
    captured
    # a= System.cmd("elixir", ["lib/exercise.exs"], into: IO.stream(:stdio,:line))
  end

  def execute(:function, exercise, params) do
    Logger.info("Executin exercise file #{exercise}")
    function_to_apply =   Code.eval_file(exercise, File.cwd!) |> elem(0)
    apply(function_to_apply, params)
  end

  def verify_file(name, type) do
    case File.exists?(name) do
      true -> :ok
      false -> {:error, "File #{name} for #{type} do not exits"}
    end
  end
end
