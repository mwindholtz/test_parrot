defmodule TestParrot.DemoTest do
  @moduledoc false
  use ExUnit.Case

  # define MyRepoBehaviour ----------------------------------------------------------------------
  defmodule MyRepoBehaviour do
    @moduledoc false
    @callback heavy_work() :: {:ok, binary} | {:error, binary}
  end

  # define RealMyRepoModule ----------------------------------------------------------------------
  defmodule RealMyRepoModule do
    @behaviour MyRepoBehaviour

    @impl MyRepoBehaviour
    def heavy_work() do
      # does slow or side-effect stuff here in the real world
      # so we don't what this to run in our micro-tests (aka unit-tests)
      # the Parrot will do this instead.
      {:ok, "Margaritaville"}
    end
  end

  defmodule MyModule do
    def my_function(input_number, dep \\ RealMyRepoModule) do
      {:ok, string_from_dependency} = dep.heavy_work()
      combined_result = string_from_dependency <> Integer.to_string(input_number)
      {:ok, combined_result}
    end
  end

  # define MyRepoParrot ----------------------------------------------------------------------
  defmodule MyRepoParrot do
    import TestParrot
    require TestParrot

    @behaviour MyRepoBehaviour
    #                 scope,      function,           default-result
    parrot(:my_function, :heavy_work, {:ok, "nothing"})
    # . . .
  end

  test "using the Parrot to remove slow or side-effect dependency" do
    # Given
    stubbed_data = "Cheeseburger in Paradise"
    MyRepoParrot.say_heavy_work({:ok, stubbed_data})
    # When
    result = MyModule.my_function(234, MyRepoParrot)
    # Then
    assert {:ok, "Cheeseburger in Paradise234"} == result
    assert_receive :heavy_work
  end

  test "calling the real code by default" do
    # Given
    stubbed_data = "Cheeseburger in Paradise"
    MyRepoParrot.say_heavy_work({:ok, stubbed_data})
    # When
    result = MyModule.my_function(234)
    # Then
    assert {:ok, "Margaritaville234"} == result
    refute_receive :heavy_work
  end
end
