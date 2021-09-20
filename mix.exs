defmodule TestParrot.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_parrot,
      version: "0.3.4",
      elixir: "~> 1.9.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      files: ~w(lib  .formatter.exs mix.exs README*  LICENSE* CHANGELOG* ),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/mwindholtz/test_parrot"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "TestParrot helps in stubbing unit tests for pure functions"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:mix_test_watch, ">= 1.1.0", only: :dev, runtime: false}
    ]
  end
end
