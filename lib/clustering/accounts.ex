defmodule Clustering.Accounts do
  require Amnesia
  require Amnesia.Helper
  require Exquisite
  require Database.Account

  alias Database.Account

  def create_account(first_name, last_name, starting_balance) do
    Amnesia.transaction do
      %Account{first_name: first_name, last_name: last_name, balance: starting_balance}
      |> Account.write()
    end
  end

  def get_account(account_id) do
    Amnesia.transaction do
      Account.read(account_id)
    end
    |> case do
      %Account{} = account -> account
      _ -> {:error, :not_found}
    end
  end
end
