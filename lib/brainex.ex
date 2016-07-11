defmodule BrainEx.Application do
  @moduledoc """
  This is the Brain Application.
  """

  use Application

  @doc """
  Starts the Application.

    ## Examples

      iex> BrainEx.Application.__info__(:functions)
      [start: 2, stop: 1]

      iex> Application.started_applications |> Enum.any?(fn({app, _name, _version}) -> app == :brainex end)
      true
  """

  @spec start(type :: Kernel.start_type, args :: term) :: {:ok, pid} | {:error, term}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)

  end
end
