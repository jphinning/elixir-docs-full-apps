import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"umbrella_node@jph-manjaro"},
    {?n..?z, :"secondary_bucket_node@jph-manjaro"}
  ]
end
