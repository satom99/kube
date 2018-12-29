defmodule Kube.Worker do
  use GenServer

  alias Kube.Config

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    handle_info(:timeout, state)
    send(self(), :timeout)
    {:ok, state}
  end

  def handle_info(:timeout, state) do
    base = Config.master()
    token = Config.token()
    selector = Config.selector()
    namespace = Config.namespace()

    path = "api/v1/namespaces/#{namespace}/pods"
    final = "#{base}/#{path}?labelSelector=#{selector}"
    headers = [{'authorization', 'Bearer #{token}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    :httpc.request(:get, request, options, [])
    |> handle_response
    |> Enum.filter(&healthy?/1)
    |> Enum.map(&to_node/1)
    |> Enum.each(&Node.connect/1)

    {:noreply, state, 5000}
  end

  defp handle_response({:ok, response}) do
    handle_response(response)
  end
  defp handle_response({:error, reason}) do
    raise List.to_string(reason)
  end
  defp handle_response({{_version, status, _reason}, _headers, body}) do
    handle_response({status, body})
  end
  defp handle_response({200, body}) do
    Jason.decode!(body)["items"]
  end
  defp handle_response({status, body}) do
    reason = [status: status, body: body]
    handle_response({:error, reason})
  end

  defp healthy?(%{"status" => %{"phase" => "Running", "containerStatuses" => containers}}) do
    containers
    |> Enum.reject(&healthy?/1)
    |> length
    == 0
  end
  defp healthy?(%{"state" => %{"running" => _object}, "ready" => true}), do: true
  defp healthy?(_other), do: false

  defp to_node(%{"status" => %{"podIP" => ip}, "metadata" => %{"name" => name}}) do
    :"#{name}@#{ip}"
  end
end
