defmodule ClusteringWeb.PageController do
  use ClusteringWeb, :controller

  def index(conn, _params) do
    if Application.get_env(:clustering, Clustering)[:dev_mode] do
      conn
      |> put_layout(:blank)
      |> render("iframe.html")
    else
      conn
      |> put_layout(:blank)
      |> assign(:random_number, 7259)
      |> render("index.html")
    end
  end
end
