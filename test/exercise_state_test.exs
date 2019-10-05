defmodule ExerciseStateTest do
  use ExUnit.Case
  alias ElixirJourney.ExerciseState
  alias ElixirJourney.Exercise


  @tag :focus
  test "Start a new process and inspect state" do
    {:ok, pid} = GenServer.start_link(ExerciseState, {%{}, []})
    assert  {:error, _message} = GenServer.call(pid, {:update_exercise, :hello_world, {:slug, :hello_world}})
  end

  @tag :focus
  test "Update value with one exercise" do
    {:ok, pid} = GenServer.start_link(ExerciseState, {%{}, [hello_world: %Exercise{name: "Hello world"}]})
    assert GenServer.call(pid, {:update_exercise, :hello_world, {:exercise_dir, "~/hello"}}) == :ok
  end

  @tag :focus
  test "Update value with mutiple exercises" do
    {:ok, pid} = GenServer.start_link(ExerciseState, {%{}, [hello_world: %{name: "Hello world"}, introduction: %{name: "Hello world"}]})
    assert GenServer.call(pid, {:update_exercise, :hello_world, {:dir, "~/hello"}}) == :ok  end

  @tag :focus
  test "get an excercise" do
    {:ok, pid} = GenServer.start_link(ExerciseState, {%{}, [hello_world: %Exercise{name: "Hello world"}, introduction: %Exercise{name: "Hello world"}]})
    {:ok, exercise} = GenServer.call(pid, {:get_exercise, :introduction})
    assert  %Exercise{} = exercise
  end

  @tag :focus
  test "get a non existing excercise" do
    {:ok, pid} = GenServer.start_link(ExerciseState, {%{}, [%{hello_world: %Exercise{name: "Hello world"}}, %{introduction: %Exercise{name: "Hello world"}}]})
    assert {:error, _} = GenServer.call(pid, {:get_exercise, :undefined})
  end

  @tag :focus
  test "add new exercise to empty" do
    assert :ok = ExerciseState.add_exercise(:joyce_marielle, %Exercise{name: "Joyce Marielle"})
    {_meta, exercises} = :sys.get_state(ElixirJourney.ExerciseState)
    assert %{slug: :joyce_marielle} = exercises |> Keyword.get(:joyce_marielle)
  end

  @tag :wip
  test "update exercise without empty map" do
    assert :ok = ExerciseState.add_exercise(:hello_world,  %Exercise{name: "Hello world"})
    assert :ok = ExerciseState.update_exercise(:hello_world, {:file, "hello.exs"})
    {_meta, exercises} = :sys.get_state(ElixirJourney.ExerciseState)
    [hello_world: %{file: "hello.exs", name: "Hello world"}] = exercises

  end

  @tag :wip
  test "add multiple excersies at once" do
    assert :ok = ExerciseState.add_exercise(hello_world: %Exercise{name: "Hello world"}, introduction: %Exercise{name: "Introduction"})
    {_meta, exercises} = :sys.get_state(ElixirJourney.ExerciseState)
    %{slug: :hello_world, name: "Hello world"} = Keyword.get(exercises, :hello_world)
    %{slug: :introduction, name: "Introduction"} = Keyword.get(exercises, :introduction)
  end

  @tag :focus
  test "add new exercise" do
    ExerciseState.add_exercise(:hello_world, %Exercise{name: "Hello world"})
    ExerciseState.add_exercise(:introduction, %Exercise{name: "Introduction"})
    assert :ok = ExerciseState.add_exercise(:joyce_marielle, %Exercise{slug: :joyce_marielle})
    assert :sys.get_state(ElixirJourney.ExerciseState) == {%{}, [hello_world: %ElixirJourney.Exercise{exercise_dir: "", exercise_file: "", name: "Hello world", slug: :hello_world, solution_file: "", sulution_dir: "", type: ""}, introduction: %ElixirJourney.Exercise{exercise_dir: "", exercise_file: "", name: "Introduction", slug: :introduction, solution_file: "", sulution_dir: "", type: ""}, joyce_marielle: %ElixirJourney.Exercise{exercise_dir: "", exercise_file: "", name: "", slug: :joyce_marielle, solution_file: "", sulution_dir: "", type: ""}]}

  end
end
