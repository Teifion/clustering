defmodule Mix.Tasks.Redeploy do
  @moduledoc false
  use Mix.Task
  require Logger

  def run(_) do
    ips = Application.get_env(:clustering, Clustering)[:ips]

    ips
    |> log_and_go("Copying and executing")
    |> Enum.each(fn ip ->
      System.shell(
"""
ssh root@#{ip} <<'ENDSSH'
  sh /dodeploy.sh
ENDSSH
"""
    )
      :timer.sleep(6000)
    end)
    |> log_and_go("Deployed")

    System.shell("mix phx.digest.clean --all")
  end

  defp log_and_go(state, message) do
    Logger.info(message)
    state
  end
end
