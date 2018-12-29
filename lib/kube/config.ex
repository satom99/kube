defmodule Kube.Config do
  import Application

  @master "kubernetes.default.svc"
  @account "/var/run/secrets/kubernetes.io/serviceaccount"

  def master, do: get(:master, @master)
  def selector, do: get(:selector, "")

  def token, do: read("token")
  def namespace, do: read("namespace")

  defp get(key, default) do
    get_env(:kube, key, default)
  end

  defp read(name) do
    @account
    |> Path.join(name)
    |> File.read!
    |> String.trim
  end
end
