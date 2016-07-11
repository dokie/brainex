defmodule BrainEx.Tuplespace do
  @moduledoc """
  This is the Tuplespace Server which allows clients to interact with a Tuple Space.
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Add a fact in the form of a tuple to the Tuplespace
  """
  @spec out(server :: pid, fact :: tuple) :: :ok
  def out(server, fact) when is_pid(server) and is_tuple(fact), do: GenServer.cast(server, {:out, fact})

  @doc """
  Retrieve a fact based upon an example template fact from the Tuplespace. This is a blocking call.
  """
  @spec inn(server :: pid, example :: tuple) :: {term, fact :: tuple} | {:noreply, term, :timeout}
  def inn(server, example) when is_pid(server) and is_tuple(example), do: GenServer.call(server, {:in, example}, :infinity)

  @doc """
  Retrieve a fact based upon an example template fact from the Tuplespace. This is a non-blocking call
  """
  @spec inp(server :: pid, example :: tuple) :: {term, fact :: tuple} | {:noreply, term, :timeout}
  def inp(server, example) when is_pid(server) and is_tuple(example), do: GenServer.call(server, {:inp, example})

  # GenServer callbacks
  def handle_call({:in, example}, _from, state) when is_tuple(example) and is_list(state) do
    state 
      |> Enum.partition(&(&1 == example))
      |> in_reply
 end

  def handle_call({:inp, example}, _from, state) when is_tuple(example) and is_list(state) do
    state 
      |> Enum.partition(&(&1 == example))
      |> in_reply
  end

  def handle_cast({:out, fact}, state) when is_tuple(fact) and is_list(state) do
    {:noreply, [fact] ++ state}
  end

  # Private functions
  @spec in_reply({found :: [tuple] | [], remainder :: [tuple] | []}) :: {:reply, tuple | nil, [tuple] | []}
  defp in_reply({[], remainder}), do: {:reply, nil, remainder}
  defp in_reply({[tuple], remainder}), do: {:reply, tuple, remainder}
    
end
