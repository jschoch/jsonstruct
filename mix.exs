defmodule Jsonstruct.Mixfile do
  use Mix.Project

  def project do
    [app: app(),
     version: version(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,:exconstructor]]
  end

  defp version, do: "0.0.3"

  defp app, do: :jsonstruct

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options

  defp aliases do
    [
      build: [ &build_releases/1],
    ]
  end


  
  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=#{app()}.ez"])
    File.rename("#{app()}.ez", "./archives/#{app()}.ez")
    File.rename("#{app()}-#{version()}.ez", "./archives/#{app()}-#{version()}.ez")
  end

  defp deps do
    [
      {:poison, "~> 3.0"},
      {:ex_json_schema, "~> 0.6.2"},
      { :inflex, "~> 1.7.0" },
      {:exconstructor, git:  "https://github.com/SLOBYYYY/exconstructor"}
    ]
  end
end
