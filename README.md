# TestParrot

## Installation

```elixir
def deps do
  [
    {:test_parrot, "~> 0.1.4"}
  ]
end
```

* [TestParrot on Hex](https://hex.pm/packages/test_parrot)

## Pattern Name
TestParrot

## Problem
  In an isolated Test how do we: 
  1. assert that dependent module-functions were called by the Software-Under-Test?
  1. assert that the correct arguments were passed to the dependent module-functions?
  1. stub out return data that the dependent module-function should return?

## Context
  We are writing isolated, pure, fast-running Unit Tests.
  In Elixir I can think of this as `Module testing`.  Because we want to limit the test to one module.
  Classic blog post by *Mike Feathers* and what makes unit different from Integration testing.   
  [A Set of Unit Testing Rules](https://www.artima.com/weblogs/viewpost.jsp?thread=126923)

  ##### A test is not a unit test if:

  1. It talks to the database
  2. It communicates across the network
  3. It touches the file system
  4. It can't run at the same time as any of your other unit tests
  5. You have to do special things to your environment (such as editing config files) to run it.

In Elixir, in particular, do not:

  6. Read the System Time (subset of rule 5 above, but often forgotten)
  7. It cannot involve the erlang Scheduler.  No multiple processes.


## Solution 
  Inject into the Software-Under-Test a **Parrot** with the same interface as the real depedency.
  *  A **Parrot** is a kind of *Test Double* that has the same interface as the dependency (sometimes using a @behaviour)
  *  The interface function is stubbed by a default return value, and can be told to say with a customreturn value per test
  *  The **Parrot** sends a message back to the test-process when the interface function is called.
  *  The message sent back to the test-process contains the name of the called function and the arguments 
  *  Do not pass the Parrot more than one Module deep. 

## Limitations
  * Parrots are intentionally limited for when the test and Software-Under-Test are IN THE SAME PROCESS.

---

## Example using Parrot in a test 


  See the real usage in: `TestParrot.DemoTest`

  ```elixir
  @dependent  SomeDependencyParrot 

  test "some test pseudo code for demo purposes" do
    # Given
    SomeDependencyParrot.say_get({:ok, 42})
    params = 123
    # When
    result = TargetCode.my_function(params, @dependent)
    # Then
    assert {:ok, 42} == result
    assert_receive {:get, 123}
  end
  ```

  ```elixir
  defmodule TargetCode do
    def my_function(params, dependent) do
      dependent.get(params)
    end
  end
  ```

  ## Defining the SomeDependencyParrot

   provide only semantically meaningful parts
  * the message parroted back depends on the arity
  *  **my_function()**  sends back **:name_of_function**
  *  **my_function(arg1)** sends back **{:name_of_function, arg_1}**
  *  **my_function(arg1, arg2)** sends back **{:name_of_function, arg1, arg2}**
  * the function return value is either 
    * the default defined in the macro call, or 
    * whatever _term_ was told to say for that scope and function name
  
  ```elixir
  defmodule SomeDependencyParrot do
    import TestParrot
    require TestParrot
    # optional behaviour
    @behaviour Somewhere.DependentBehaviour
    #       scope,     function,             default-result
    parrot(:resource, :all,                 [])
    parrot(:resource, :get,                 {:ok, %{}})
    parrot(:resource, :update,              {:ok, %{}})
    parrot(:resource, :create,              {:ok, %{}})
    parrot(:resource, :delete,              :ok)
  end
  ```


## Discussion

### Why not use techniques and tools like [MOX](https://github.com/plataformatec/mox) ?

See the **Mocks as locals** section in [Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/ )

"Although we have used the application configuration for solving the external API issue, sometimes it is easier to just pass the dependency as argument. Imagine this example in Elixir where some function may perform heavy work which you want to isolate in tests:"  -- José Valim

José seems to say that Mox is good for large external interfaces.
And points to **Mocks as Locals** as a way to do testing for simpler smaller cases.  These simpler cases are Unit tests.




