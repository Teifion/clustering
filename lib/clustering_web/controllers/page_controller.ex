defmodule ClusteringWeb.PageController do
  use ClusteringWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout(:blank)
    |> render("index.html")
  end
end
