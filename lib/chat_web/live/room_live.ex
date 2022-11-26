defmodule ChatWeb.RoomLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    user_name = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, user_name, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       user_name: user_name,
       topic: topic,
       message: "",
       messages: [],
       user_list: [],
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

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    # Logger.info(joins: joins, leaves: leaves, user_name: socket.assigns.user_name)

    join_messages = joins
      |> Map.keys()
      |> Enum.map(fn user_name ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{user_name} joined"}
      end)

    leave_messages = leaves
      |> Map.keys()
      |> Enum.map(fn user_name ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{user_name} left"}
      end)

    user_list = ChatWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

    {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content} = assigns) do
    ~H"""
    <p id={uuid}><em><%= content %></em></p>
    """
  end

  def display_message(%{uuid: uuid, user_name: user_name, content: content} = assigns) do
    ~H"""
    <p id={uuid}><strong><%= user_name %>: </strong><%= content %></p>
    """
  end
end
