defmodule NseDownloader.Stock do
  use Ecto.Schema

  @primary_key false
  schema "stocks" do
    field :symbol, :string, primary_key: true
    field :series, :string
    field :open, :float
    field :high, :float
    field :low, :float
    field :close, :float
    field :last, :float
    field :prevclose, :float
    field :tottrdqty, :integer
    field :tottrdval, :float
    field :timestamp, :date, primary_key: true
    field :totaltrades, :integer
    field :isin, :string
  end
end
