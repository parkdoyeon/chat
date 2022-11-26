defmodule ChatWeb.RoomLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       message: "",
       messages: [%{uuid: UUID.uuid4(), content: "Hello"}],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message, topic: topic}, socket) do
    Logger.info(payload: message)
    {:noreply, assign(socket, messages: [%{uuid: UUID.uuid4(), content: message}])}
  end
end
