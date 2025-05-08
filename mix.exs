defmodule RsSimd.MixProject do
  use Mix.Project

  @source_url "https://github.com/ewildgoose/elixir-reed_solomon_simd"
  @version "0.1.0"

  def project do
    [
      app: :rs_simd,
      description: description(),
      package: package(),
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.29"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Elixir/rust wrapper around Reed-Solomon-SIMD rust library.
    Generate (or recover using) reed solomon protection shards
    """
  end
  defp package do
    %{
      name: :reed_solomon_simd,
      files: ["lib", "native", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Ed Wildgoose"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end
end
