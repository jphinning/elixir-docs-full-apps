defmodule KV do
  use Application

  @impl true
  def start(_start, _args) do
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
