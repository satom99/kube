defmodule Kube.MixProject do
  use Mix.Project

  def project do
    [
      app: :kube,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Kube, []},
      applications: [:inets]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"}
    ]
  end
end
