defmodule ElixirJourney do
  use Application

  alias ElixirJourney.Exercise
  alias ElixirJourney.ExerciseState
  require Logger
  import Destructure

  @moduledoc """
  Documentation for ElixirJourney

  ## State
  State handle a nested structure of components that have the following:
  * Information about the journey
  * Metadata about each exercise
  """

  @doc """
  Starts a supervisor for exercises state GenServer
  """
  def start(_type, _args) do
    children = [
      {ElixirJourney.ExerciseState, {%{}, []}}
    ]

    opts = [strategy: :one_for_one, name: ElixirJourney.Supervisor]
    Supervisor.start_link(children, opts)
  end

  #  def description(_exercise_slug) do
  def docs(exercise_slug) do
    # TODO transform into with to check errors
    {:ok, exercise} = ExerciseState.get_exercise(exercise_slug)
    opts = IEx.Config.ansi_docs()
    IO.ANSI.Docs.print(exercise.doc, opts)
  end

  @doc """
  verify/1

  Will verify if submited file exists

  """
  def verify(exercise_slug) do
    # IO.puts System.cwd!
    exercise_meta = exercises[exercise_slug]
    verify(exercise_meta.type, exercise_meta)
  end

  def verify(exercise_slug, params, result) do
    # IO.puts System.cwd!
    exercise_meta = exercises[exercise_slug]
    verify(exercise_meta.type, exercise_meta, params, result)
  end

  def verify(:stdout, meta) do
    exercise_file = meta.exercise_dir <> meta.exercise_file
    solution_file = meta.solution_dir <> meta.solution_file

    Logger.info("Looking for exercise file #{exercise_file} and solution #{solution_file}")

    with :ok <- Exercise.verify_file(exercise_file, :exercise_file),
         :ok <- Exercise.verify_file(solution_file, :solution_file) do
      # run submited exercise in a new process
      submited_exercise =
        Task.async(fn ->
          Exercise.execute(meta.type, exercise_file)
        end)
        |> Task.await()

      solution_exercise =
        Task.async(fn ->
          Exercise.execute(meta.type, solution_file)
        end)
        |> Task.await()

      Logger.info("Submited exercise response #{submited_exercise}")
      Logger.info("Solution exercise response #{solution_exercise}")
      solution_exercise == submited_exercise
    else
      error = {:error, reason} ->
        Logger.error(reason)
        error
    end
  end

#  def verify(:forward, meta), do: true
  def verify(:function, solution_file, params, result) do
    #solution_file = meta.solution_dir <> meta.solution_file

    with :ok <- Exercise.verify_file(solution_file, :solution_file) do
      response = Exercise.execute(:function, solution_file, params)
      case response == result do
        true ->
          Logger.info("Send exercise pass response")
          :ok
        false ->
          Logger.info("Exercise fails with response =  #{response}")
          {:fail, "Exercise fails with response =  #{response}"}
      end
    else
      error = {:error, reason} ->
        Logger.error(reason)
      error
    end
  end


  def exercises do
    %{
      hello_world: %{
        slug: "hello_world",
        name: "Hello World",
        type: :stdout,
        exercise_dir: "./",
        exercise_file: "exercise.exs",
        solution_dir: "lib/exercises/",
        solution_file: "hello_world_solution.exs"
      },
      pattern_matching: %{
        slug: "pattern_matching",
        name: "Pattern Matching",
        exercise_dir: "exercises/",
        exercise_file: "pattern_matching.exs",
        sulution_dir: "solutions/",
        solution_file: "pattern_matching_solution.exs",
        type: :forward
      },
      anonymous_functions: %{
        slug: "anonymous_functions",
        name: "Anonymous Functions",
        type: :function,
        exercise_dir: "./",
        exercise_file: "ano.exs",
        solution_dir: "lib/exercises/",
        solution_file: "anonymous_functions_solution.exs"
      }
    }
  end

  def exercises(exercises_dir) do
    with {:ok, exercises} <- File.ls(exercises_dir) do
      exercises = load_modules(exercises_dir, exercises)
    end
  end

  def load_modules(dir, _modules) do
    modules =  ["baby_steps.ex", "anonymous_functions.ex", "modules.ex",
                "hello_world.ex", "pattern_matching.ex"]

    modules =  ["anonymous_functions.ex", "hello_world.ex"]


    # {:ok, files} = File.ls(dir)
    # Enum.filter(files, &(Regex.match?(~r/(#[a-z].ex/i,&1))) |> IO.inspect
    Enum.map(modules, fn(exercise_file) ->
      with {{:module, name, _list, _}, _} <- Code.eval_file("#{dir}/#{exercise_file}"),
      {:docs_v1, _, _, _, %{} = doc, _metadata, _} <- Code.fetch_docs(name),
      %{"en" => doc} <- doc do

        #       opts <- IEx.Config.ansi_docs(),
        # IO.ANSI.Docs.print(doc, opts)


        underscore_name = Atom.to_string(name)
        |> String.split(".")
        |> List.last()
        |> Macro.underscore

        Logger.info("Exercise #{underscore_name} loaded")

        slug = String.to_atom(underscore_name)
        exercise_name = Macro.underscore(underscore_name) |> String.split("_") |> Enum.reduce("", &(&2 <> " " <> String.capitalize(&1))) |> String.trim

        {:"#{slug}",
         %{slug: slug,
           name: exercise_name,
           module: name,
           doc: doc
         }
        }
      else
        error ->
          IO.inspect(error)
        {:error, "Invalid exercise"}
      end
    end) |> ExerciseState.add_exercise
  end

  def run(exercise_slug, solution_file) do
    {:ok, exercise} = ExerciseState.get_exercise(exercise_slug)
    exercise.module.run(solution_file)
  end

  @doc """
  Executing and anonimous function of a module using the Kernel.apply function.
  apply(Enum, :reverse, [[1, 2, 3]])
  ## Howto
  1. Load the module file into the variable name

  ```elixir
  iex(1)> {{:module, name, _list, _}, _llist} = Code.eval_file("lib/exercises/modules.ex")
  ```
  2. Get a list of functions defined in the module
  ```elixir
  iex(1)> {function, _} = name.__info__(:functions) |> List.first

  ```

  3. Finally execude the function ussing the apply command.
  ```elixir
  iex(1)>  apply(name, function, [])
  ```


  1. Passed (also represented by `nil`)
  2. Failed
  3. Skipped (via @tag :skip)
  4. Excluded (via :exclude filters)
  5. Invalid (when setup_all fails)
  """
  def apply do
  end
end
