defmodule TestParrotTest do
  @moduledoc false
  use ExUnit.Case

  defmodule Module001Parrot do
    use TestParrot
    parrot(:module_01, :my_function, :ok)
  end

  defmodule Module002Parrot do
    use TestParrot
    parrot(:module_02, :my_function, :ok)
  end

  setup do
    %{data: "Some-Data", default: :ok}
  end

  describe "parrot/3" do
    test "arity ZERO - my_function() - send parroted message" do
      Module001Parrot.my_function()
      assert_receive :my_function
    end

    test "arity ONE - my_function(arg1) - send parroted message" do
      Module001Parrot.my_function(:arg1)
      assert_receive {:my_function, :arg1}
    end

    test "arity TWO - my_function(arg1, arg2) - send parroted message" do
      Module001Parrot.my_function(:arg1, :arg2)
      assert_receive {:my_function, :arg1, :arg2}
    end

    test "arity THREE - my_function(arg1, arg2, arg3) - send parroted message" do
      Module001Parrot.my_function(:arg1, :arg2, :arg3)
      assert_receive {:my_function, :arg1, :arg2, :arg3}
    end

    test "parrot - returns say data", conn do
      Module001Parrot.say_my_function(conn.data)
      assert conn.data == Module001Parrot.my_function()
    end

    test "parrot - default", conn do
      assert conn.default == Module001Parrot.my_function()
    end

    test "scope. say in  Module_01, read from Module_02.  Module_02 gets default ", conn do
      Module001Parrot.say_my_function(conn.data)
      assert conn.default == Module002Parrot.my_function()
    end
  end
end
