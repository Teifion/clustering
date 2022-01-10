defmodule Mix.Tasks.CInstall do
  @moduledoc false
  use Mix.Task
  require Logger

  def run(_) do
    ips = Application.get_env(:clustering, Clustering)[:ips]

    ips
    |> log_and_go("Copying and executing")
    |> Enum.each(fn ip ->
      System.shell("scp -i ~/.ssh/id_rsa remote/install.sh root@#{ip}:/install.sh")
      System.shell("scp -i ~/.ssh/id_rsa remote/bashrc root@#{ip}:/root/.bashrc")
      System.shell(
"""
ssh root@#{ip} <<'ENDSSH'
  sh /install.sh
ENDSSH
"""
    )
    end)
    |> log_and_go("Copied files")
  end

  defp log_and_go(state, message) do
    Logger.info(message)
    state
  end
end
