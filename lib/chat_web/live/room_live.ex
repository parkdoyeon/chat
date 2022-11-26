defmodule ChatWeb.RoomLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    user_name = MnemonicSlugs.generate_slug(2)
    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    {:ok,
     assign(socket,
       room_id: room_id,
       user_name: user_name,
       topic: topic,
       message: "",
       messages: [%{uuid: UUID.uuid4(), user_name: "system", content: "#{user_name} joined the chat"}],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, user_name: socket.assigns.user_name}
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message, topic: topic}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end
end
