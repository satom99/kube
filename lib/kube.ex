defmodule Kube do
  use Application

  alias Kube.Worker

  def start(_type, _args) do
    children = [
      Worker
    ]
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]
    Supervisor.start_link(children, options)
  end
end
