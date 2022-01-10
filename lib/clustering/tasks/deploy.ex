defmodule Mix.Tasks.Deploy do
  @moduledoc false
  use Mix.Task
  require Logger

  def run(_) do
    ips = Application.get_env(:clustering, Clustering)[:ips]
    new_number = :rand.uniform(8999) + 1000

    # For some reason this isn't working
    System.shell("sed -ir 's/:random_number, [0-9]+/:random_number, #{new_number}/' lib/clustering_web/controllers/page_controller.ex")

    System.shell("sh scripts/build_container.sh")
    System.shell("sh scripts/generate_release.sh")

    ips
    |> log_and_go("Copying and executing")
    |> Parallel.each(fn ip ->
      System.shell("scp -i ~/.ssh/id_rsa remote/dodeploy.sh root@#{ip}:/deploy.sh")
      System.shell("scp -i /home/teifion/.ssh/id_rsa rel/artifacts/clustering.tar.gz root@#{ip}:/releases/clustering.tar.gz")
      System.shell(
"""
ssh root@#{ip} <<'ENDSSH'
  sh /dodeploy.sh
ENDSSH
"""
    )
    end)
    |> log_and_go("Deployed")

    System.shell("mix phx.digest.clean --all")
  end

  defp log_and_go(state, message) do
    Logger.info(message)
    state
  end
end
