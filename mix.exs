defmodule KvUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        umbrella_node: [
          version: "0.0.1",
          applications: [kv_server: :permanent, kv: :permanent],
          cookie: "weknoweachother"
        ],
        secondary_bucket_node: [
          version: "0.0.1",
          applications: [kv: :permanent],
          cookie: "weknoweachother"
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end
end
