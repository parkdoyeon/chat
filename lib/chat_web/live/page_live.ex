defmodule ChatWeb.PageLive do
  use Phoenix.LiveView
  require Logger

  # def render(assigns) do
  #   ~H"""
  #   <button phx-click="random-room" title="Create a random room">Create a random room </button>
  #   """
  # end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _session, socket) do
    random_slug = "/" <> MnemonicSlugs.generate_slug(4)
    Logger.info("click")
    {:noreply, push_redirect(socket, to: random_slug)}
  end
end
