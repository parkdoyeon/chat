defmodule ChatWeb.RoomLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    ChatWeb.Endpoint.subscribe(topic)
    {:ok, assign(socket, room_id: room_id, topic: topic, messages: ["Hello"])}
  end

  @impl true
  def handle_event(a, %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message, a: a)
    ChatWeb.Endpoint.broadcast(socket.assign.topic, "new-message", message)
    {:noreply, socket}
  end
end
