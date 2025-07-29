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
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- KVServer.Command.parse(data),
           do: KVServer.Command.run(command)

    write_line(socket, msg)

    request_handler(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    # Known error; write to the client
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    # The connection was closed, exit politely
    exit(:shutdown)
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, error}) do
    # Unknown error; write to the client and exit
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
