defmodule SurrogateTest do
  use ExUnit.Case
  doctest Surrogate

  alias Surrogate.PubSub

  test "subscribe/1 links to a topic" do
    {:ok, _pid} = PubSub.start_link

    :ok = PubSub.subscribe("topic.1")
    :ok = PubSub.subscribe("topic.2")

    {:ok, other_conn} = Redix.start_link
    {:ok, _} = Redix.command(other_conn, ~w(PUBLISH topic.1 hello))
    {:ok, _} = Redix.command(other_conn, ~w(PUBLISH topic.2 world))

    assert_receive "hello"
    assert_receive "world"
  end
end
