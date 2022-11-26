defmodule ChatWeb.PageController do
  use ChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def handle_call(t, a, x) do
    IO.inspect(t)
  end
end
