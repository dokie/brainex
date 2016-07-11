defmodule BrainEx.TuplespaceTest do
  use ExUnit.Case

  alias BrainEx.Tuplespace

  setup do
    {:ok, brain} = Tuplespace.start_link
    {:ok, [space: brain]}
  end

  test "simple out operation", context do
    brain = context[:space]
    assert :ok == Tuplespace.out(brain, {"hello", 1})
  end

  test "more representative out operation", context do
    brain = context[:space]
    assert :ok = Tuplespace.out(brain, {UUID.uuid4, "scalar", "P3", [UUID.uuid4, UUID.uuid4]})
  end

  test "match fact exactly", context do
    brain = context[:space]
    fact = {"Yo Yo", 99, <<"HELLO">>, 1.2345}
    :ok = Tuplespace.out(brain, fact)
    remembered = Tuplespace.inn(brain, {"Yo Yo", 99, <<"HELLO">>, 1.2345})
    deja_vu = Tuplespace.inp(brain, fact)
    assert fact == remembered
    assert nil == deja_vu
  end
end
