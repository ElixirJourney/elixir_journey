defmodule ElixirJourney.ExerciseState do
  use GenServer
  import Logger
  alias ElixirJourney.Exercise


  @doc """
  Starts the exercise GenServer
  """

  def start_link(journey = {exercise_meta, exercises} \\ {%{}, []}) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, journey, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end


  @doc """
  Add a new excercise to the collection
  """
  def add_exercise(exercise) do
    GenServer.cast(__MODULE__,{:add_exercise, exercise})
  end

  def get_exercise(exercise) do
    GenServer.call(__MODULE__,{:get_exercise, exercise}) |> IO.inspect
  end

  # GenServer Callbacks implementation
  @doc """
  Add a new excercise callback implementation
  """
  def handle_cast({:add_exercise, exercise}, {exercise_meta, exercises}) do
    exercises = [ exercise | exercises]
    {:noreply, {exercise_meta, exercises}}
  end

  def handle_call({:get_exercise, exercise_slug}, _from, {_exercise_meta, exercises}) do
    Logger.info "Looking for slug **#{exercise_slug}** into #{inspect exercises}"
    exercise = Enum.filter(exercises, fn(exercise) ->
      match?(%{^exercise_slug => _}, exercise)
    end) |> List.first
    result = case exercise do
      nil -> {:error, "Exercise #{exercise_slug} not found"}
      _ -> {:ok, exercise}
    end
    {:reply, result, exercises}
  end

  def handle_call({:update_exercise, exercise_slug, new_value}, _from, {exercise_meta, exercises}) do
    Logger.info "handle_call -> :update_excercise #{exercise_slug}, #{inspect new_value}"
    ## Get excercise state
    exercise = case Enum.filter(exercises, fn(exercise) ->
                     match?(%{^exercise_slug => _}, exercise)
                   end) do
                 [] ->
                   Logger.info("Exercise not found")
                   {:error, "Exercise not found"}
                 [exercise] ->
                   Logger.info("Exercise with slug found #{inspect exercise}")
                   exercise
               end
    process = fn
      (reply = {:error, message}) ->
        {:reply, reply, {exercise_meta, exercises}}
      (found_exercise) ->
        Logger.info "Current exercise #{inspect exercise}"
      updated_exercise = update_exercise(exercise_slug, found_exercise, new_value)
      exercises_without_current = Enum.filter(exercises, fn (exercise) ->
        [current_slug] = Map.keys(exercise)
        current_slug != exercise_slug
      end)

      updated_exercises = [ updated_exercise | exercises_without_current ]
      {:reply, :ok, {exercise_meta, updated_exercises}}
    end
    process.(exercise)
  end

  @doc """
  Return new excercise map
  """
  def update_exercise(exercise_slug, current_exercise, {key, value}) do
    Logger.info "Updating #{key} with value #{value} at #{exercise_slug}"
    exercise = current_exercise[exercise_slug]
    Logger.info "Exercise value #{inspect exercise}"
    updated_exercise = Map.merge(exercise, %{key => value})
    Kernel.put_in(current_exercise,[exercise_slug], updated_exercise) |> IO.inspect
  end
end
