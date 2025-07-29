defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    # Get the first byte of the binary
    first = :binary.first(bucket)

    # Try to find an entry in the table() or raise
    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    entry
    |> elem(1)
    |> execute_on_node(node(), bucket, mod, fun, args)
  end

  defp execute_on_node(same_node, same_node, _bucket, mod, fun, args) do
    # Local execution - no need for bucket parameter
    apply(mod, fun, args)
  end

  defp execute_on_node(target_node, _current_node, bucket, mod, fun, args) do
    # Remote execution - need bucket for recursive call
    {KV.RouterTasks, target_node}
    |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
    |> Task.await()
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect(bucket)} in table #{inspect(table())}"
  end

  @doc """
  The routing table.
  """
  def table do
    # Replace computer-name with your local machine name
    [{?a..?m, :"foo@jph-manjaro"}, {?n..?z, :"bar@jph-manjaro"}]
  end
end
