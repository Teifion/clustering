defmodule Clustering do
  @moduledoc """
  Clustering keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def destroy do
    Amnesia.stop
    Amnesia.Schema.destroy([Node.self()])
  end

  def insert do
    Clustering.Kvp.create_kvp("key", "value")
  end

  # def read do
  #   Clustering.Kvp.("key", "value")
  # end
end
