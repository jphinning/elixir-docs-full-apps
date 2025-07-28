defmodule KVServer do
  require Logger

  @moduledoc """
  Documentation for `KVServer`.
  """

  def setup_listener(port) do
    # TODO Setup tcp listener on port

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Server listening on port #{port}")
    connection_acceptor(socket)
  end

  def connection_acceptor(socket) do
    ## Accept connection and pass it to the request handler
    {:ok, client_socket} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(KVServer.TaskSupervisor, fn ->
        request_handler(client_socket)
      end)

    :ok = :gen_tcp.controlling_process(client_socket, pid)

    connection_acceptor(socket)
  end

  def request_handler(socket) do
    socket |> read_line() |> write_line(socket)

    request_handler(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)

    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
