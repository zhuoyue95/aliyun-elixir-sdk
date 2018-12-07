defmodule Aliyun.MixProject do
  use Mix.Project

  def project do
    [
      app: :aliyun,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),

      source_url: "https://github.com/zhuoyue95/aliyun-elixir-sdk",
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:tesla, "~> 1.0"},
      {:hackney, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:timex, "~> 3.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "aliyun",
      # These are the default files included in the package
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zhuoyue95/aliyun-elixir-sdk"}
    ]
  end
end
