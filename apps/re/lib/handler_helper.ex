defmodule Re.HandlerHelper do
  def wait_for(metadata, handler, timeout \\ 5_000) do
    stream_id = Map.get(metadata, :stream_id)
    stream_version = Map.get(metadata, :stream_version)

    Commanded.Subscriptions.wait_for(
      stream_id,
      stream_version,
      [consistency: [handler]],
      timeout
    )
  end
end
