defmodule NseDownloader.Repo.Migrations.CreateStocksTable do
  use Ecto.Migration

  def change do
    create table(:stocks, primary_key: false ) do
      add :symbol, :"varchar(10)", primary_key: true
      add :series, :"varchar(2)", primary_key: true
      add :open, :float
      add :high, :float
      add :low, :float
      add :close, :float
      add :last, :float
      add :prevclose, :float
      add :tottrdqty, :bigint
      add :tottrdval, :float
      add :timestamp, :date, primary_key: true
      add :totaltrades, :bigint
      add :isin, :"varchar(12)"
    end
    create unique_index(:stocks, [:symbol, :series, :timestamp])


  end
end
