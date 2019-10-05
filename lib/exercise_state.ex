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
  def add_exercise(slug, exercise) do
    GenServer.cast(__MODULE__,{:add_exercise, slug, exercise})
  end

  def add_exercise(exercises) when is_list(exercises) do
    Enum.each(exercises, fn({slug, exercise})-> add_exercise(slug, exercise) end)
  end

  def get_exercise(exercise) do
    GenServer.call(__MODULE__,{:get_exercise, exercise})
  end

  def update_exercise(exercise_slug, value) do
    GenServer.call(__MODULE__,{:update_exercise, exercise_slug, value})
  end

  # GenServer Callbacks implementation
  @doc """
  Add a new excercise callback implementation
  """
  def handle_cast({:add_exercise, slug, exercise}, {exercise_meta, exercises}) do
    new_exercise = %{exercise | slug: slug}
    exercises = Keyword.merge(exercises, ["#{slug}": new_exercise])
    {:noreply, {exercise_meta, exercises}}
  end

  def handle_call({:get_exercise, exercise_slug}, _from, {exercise_meta, exercises}) do
    Logger.info "Looking for slug **#{exercise_slug}** into exercsise state"
    exercise = exercises[exercise_slug]

    result = case exercise do
      nil -> {:error, "Exercise #{exercise_slug} not found"}
      _ -> {:ok, exercise}
    end
    {:reply, result, {exercise_meta, exercises}}
  end

  def handle_call({:update_exercise, exercise_slug, new_value = {key, value}}, _from, {exercise_meta, exercises}) do
    Logger.info "handle_call -> :update_excercise #{exercise_slug}, #{inspect new_value}"
    updated_response = Keyword.get_and_update(exercises, exercise_slug,
      fn
        (nil) -> {{:error, "Not found"}, nil}
        (current_exercise) ->
          updated_value =  Map.merge(current_exercise, %{key => value})
          {current_exercise, updated_value}
    end)

    case updated_response do
      ({reply = {:error, message}, _}) ->
        Logger.error(message)
        {:reply, reply, {exercise_meta, exercises}}
      ({_value, new_exercises}) ->
        Logger.info "Current exercise #{inspect new_exercises}"
      {:reply, :ok, {exercise_meta, new_exercises}}
    end
  end
end
