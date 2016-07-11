defmodule BrainEx.Utils do
  @moduledoc """
  A set of utilities for the Brain.
  """

  @doc """
  A parallel map function.

    ## Examples

      iex> l = 1..1000
      iex> f = fn e -> e * 2 end
      iex> expected = l |> Enum.map(f)
      iex> result = l |> BrainEx.Utils.pmap(f)
      iex> assert result == expected
      true

  """

  @spec pmap(list :: Enumerable.t, transformer :: (any -> any)) :: Enumerable.t
  def pmap(list, transformer) when is_function(transformer, 1) do
    mapper = Kernel.self
    wrapper = fn elem -> Kernel.spawn(fn -> mapper |> scatter(transformer, elem) end) end
    
    list |> Enum.map(wrapper) |> gather
  end

  @doc """
  A parallel for-each function.

    ## Examples

      iex> l = 1..1000
      iex> f = fn e -> e + 1 end
      iex> result = l |> BrainEx.Utils.pforeach(f)
      iex> assert :ok == result
      true

  """

  @spec pforeach(list :: Enumerable.t, transformer :: (any -> any)) :: :ok
  def pforeach(list, transformer) when is_function(transformer, 1) do
    wrapper = fn elem -> Kernel.spawn(fn -> Kernel.apply(transformer, [elem]) end) end
    list |> Enum.each(wrapper)
  end

  @doc """
  A parallel for-each with index function.

    ## Examples

      iex> l = 1..500
      iex> f = fn (e, i) -> (e * e) + (i * i) end
      iex> result = l |> BrainEx.Utils.pforeach_with_index(f)
      iex> assert :ok == result
      true

  """

  @spec pforeach_with_index(list :: Enumerable.t, transformer :: ((any, pos_integer) -> any)) :: :ok
  def pforeach_with_index(list, transformer) when is_function(transformer, 2) do
    wrapper = fn (elem, index) -> 
                  Task.async(fn -> Kernel.apply(transformer, [elem, index]) end) |> Task.await
              end
    each_with_index(wrapper, list)
    :ok
  end

  @spec each_with_index(transformer :: (any, pos_integer -> pid), list :: Enumerable.t) :: [any]
  defp each_with_index(transformer, list) do
    for {elem, index} <- Enum.zip(list, 1..Enum.count(list)), do: Kernel.apply(transformer, [elem, index])
  end

  @spec scatter(parent :: pid, transformer :: fun(e :: any) :: any, elem :: any) :: any
  defp scatter(parent, transformer, elem) when is_pid(parent) and is_function(transformer, 1),
    do: parent |> Kernel.send({Kernel.self, Kernel.apply(transformer, [elem])})

  @spec gather([worker :: pid | rest :: any]) :: Enumerable.t
  defp gather([worker | rest]) when is_pid(worker) do
    receive do
      {w, result} when w == worker -> [result | gather(rest)]
    end
  end
  defp gather([]), do: []
end
