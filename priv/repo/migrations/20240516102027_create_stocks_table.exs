defmodule NseDownloader.Repo.Migrations.CreateStocksTable do
  use Ecto.Migration

  def change do
    create table(:stocks, primary_key: false) do
      add :symbol, :string
      add :series, :string
      add :open, :float
      add :high, :float
      add :low, :float
      add :close, :float
      add :last, :float
      add :prevclose, :float
      add :tottrdqty, :integer
      add :tottrdval, :float
      add :timestamp, :date
      add :totaltrades, :integer
      add :isin, :string
    end
    create unique_index(:stocks, [:symbol, :timestamp])

  end
end
