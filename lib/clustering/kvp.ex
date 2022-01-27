defmodule Clustering.Kvp do
  require Amnesia
  require Amnesia.Helper
  require Exquisite
  require Database.KVPair

  alias Database.KVPair

  def create_kvp(key, value) do
    Amnesia.transaction do
      %KVPair{key: key, value: value}
      |> KVPair.write()
    end
  end

  def get_kvp(kvp_id) do
    Amnesia.transaction do
      KVPair.read(kvp_id)
    end
    |> case do
      %KVPair{} = kvp -> kvp
      _ -> {:error, :not_found}
    end
  end

  def make_kvp do
    Amnesia.transaction do
      existing =
      IO.inspect get_kvp("key")

    end
  end
end
