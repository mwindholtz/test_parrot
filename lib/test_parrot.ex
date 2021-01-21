defmodule TestParrot do
  @moduledoc """
  parrot/3
  * the message parroted back depends on the arity when called
  *  **my_function()**  sends back **:name_of_function**
  *  **my_function(arg1)**  sends back **{:name_of_function, arg1}**
  *  **my_function(arg1, arg2)**  sends back **{:name_of_function, arg1, arg2}**
  * the function return value is either
      * the default defined in the macro call, or
      * whatever _term_ was told to say for that scope and function name
  """

  defmacro __using__(_opts) do
    quote do
      import TestParrot
      require TestParrot
    end
  end

  defmacro parrot(scope, name, default) do
    say_fn_name = String.to_atom("say_#{name}")
    var_name = String.to_atom("var_#{scope}_#{name}")
    message_atom = String.to_atom("#{name}")

    quote do
      def unquote(say_fn_name)(stubbed_result) do
        Process.put(unquote(var_name), stubbed_result)
      end

      def unquote(message_atom)(arg1 \\ :not_set, arg2 \\ :not_set, arg3 \\ :not_set) do
        # send back either :function_name, or  {:function_name, :args, ...}
        cond do
          arg1 == :not_set -> send(self(), unquote(message_atom))
          arg2 == :not_set -> send(self(), {unquote(message_atom), arg1})
          arg3 == :not_set -> send(self(), {unquote(message_atom), arg1, arg2})
          true -> send(self(), {unquote(message_atom), arg1, arg2, arg3})
        end

        Process.get(unquote(var_name), unquote(default))
        |> function_or_value()
      end

      defp function_or_value(function_with_result) when is_function(function_with_result, 0) do
        function_with_result.()
      end

      defp function_or_value(value) do
        value
      end
    end
  end
end
