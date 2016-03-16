defmodule Surrogate.PubSub do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(opts) do
    {:ok, conn} = Redix.PubSub.start_link(opts)
    {:ok, %{conn: conn, subs: %{}}}
  end

  def subscribe(topic) do
    GenServer.call(__MODULE__, {:subscribe, topic})
  end

  def handle_call({:subscribe, topic}, {pid, _}, %{conn: conn, subs: subs} = state) do
    :ok = Redix.PubSub.subscribe(conn, topic, self())

    tops = Map.get(subs, pid, MapSet.new)
    subs = Map.put(subs, pid, MapSet.put(tops, topic))

    {:reply, :ok, %{state | subs: subs}}
  end

  def handle_info({:redix_pubsub, :message, message, topic}, %{subs: subs} = state) do
    for {pid, topics} <- subs do
      if MapSet.member?(topics, topic), do: send pid, message
    end

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
