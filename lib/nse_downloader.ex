defmodule NseDownloader do
  @moduledoc """
  `NseDownloader` used for downloading bhavcopy data
  """

  @headers [
    {"Accept",
     "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
    {"Accept-encoding", "gzip, deflate, br"},
    {"Connection", "keep-alive"},
    {"User-agent",
     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"}
  ]

  def string_components_for_date({year, month, day}) do
    month =
      case month do
        1 -> "JAN"
        2 -> "FEB"
        3 -> "MAR"
        4 -> "APR"
        5 -> "MAY"
        6 -> "JUN"
        7 -> "JUL"
        8 -> "AUG"
        9 -> "SEP"
        10 -> "OCT"
        11 -> "NOV"
        12 -> "DEC"
      end

    day = Integer.to_string(day) |> String.pad_leading(2, "0")
    {year, month, day}
  end

  def download_for_date(date) do
    {year, month, day} = string_components_for_date({date.year, date.month, date.day})

    url =
      "https://nsearchives.nseindia.com/content/historical/EQUITIES/#{year}/#{month}/cm#{day}#{month}#{year}bhav.csv.zip"

    case HTTPoison.request(:get, url, "", @headers, timeout: 10000) do
      {:ok, resp} -> :zip.unzip(resp.body, [:memory])
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> NseDownloader.verify("2024-01-30")
      {:ok, %{year: 2024, month: 1, day: 30}}

  """
  @spec verify(String.t()) :: {:ok, Date.t()} | {:error, any()}
  def verify(date) do
    [year, month, day] = String.split(date, "-", trim: true) |> Enum.map(&String.to_integer(&1))

    Date.new(year, month, day)

  end

  def create_item([
        symbol,
        series,
        open,
        high,
        low,
        close,
        last,
        prev,
        tottrdqty,
        tottrdval,
        timestamp,
        qty,
        isin
      ]) do
    [d, m, y] = timestamp |> String.split("-")

    month_map = %{
      "JAN" => 1,
      "FEB" => 2,
      "MAR" => 3,
      "APR" => 4,
      "MAY" => 5,
      "JUN" => 6,
      "JUL" => 7,
      "AUG" => 8,
      "SEP" => 9,
      "OCT" => 10,
      "NOV" => 11,
      "DEC" => 12
    }

    {:ok, date} = Date.new(String.to_integer(y), month_map[m], String.to_integer(d))

    with {open, ""} <- Float.parse(open),
         {high, ""} <- Float.parse(high),
         {low, ""} <- Float.parse(low),
         {close, ""} <- Float.parse(close),
         {last, ""} <- Float.parse(last),
         {prev, ""} <- Float.parse(prev),
         {tottrdqty, ""} <- Integer.parse(tottrdqty),
         {tottrdval, ""} <- Float.parse(tottrdval),
         {qty, ""} <- Integer.parse(qty) do
      [
        symbol: symbol,
        series: series,
        open: open,
        high: high,
        low: low,
        close: close,
        last: last,
        prevclose: prev,
        tottrdqty: tottrdqty,
        tottrdval: tottrdval,
        timestamp: date,
        totaltrades: qty,
        isin: isin
      ]
    else
      :error -> {:error, "Invalid date provided"}
    end
  end

  def insert_into_db(val) do
    NseDownloader.Repo.insert_all(NseDownloader.Stock, val,
      on_conflict: :replace_all,
      conflict_target: [:symbol, :series, :timestamp]
    )
  end

  @spec download(String.t()) :: {:ok, any()} | {:error, any()}
  def download(date) do
    with {:ok, f} <- verify(date),
         {:ok, [{_fname, val}]} <- download_for_date(f) do
      {:ok,
       val
       |> String.split("\n", trim: true)
       |> Enum.drop(1)
       |> Enum.map(&String.split(&1, ",", trim: true))
       |> Enum.map(&create_item(&1))}
    else
      {:error, {:EXIT,_}} -> {:error, "Data doesn't exist for date"}
      {:error, msg} -> {:error, msg}
    end
  end

  @spec download(String.t(), String.t()) :: {:ok, [any()]} | {:error, any()}
  def download(from, to) do
    with {:ok, f} <- verify(from),
         {:ok, t} <- verify(to),
         :lt <- Date.compare(f,t),
         r = Date.range(f, t, 1) do
      dates = r |> Enum.to_list() |> Enum.map(& Date.to_string(&1))
      res = for d <- dates do
        IO.puts("Downloading for: #{d}")
        case download(d) do
          {:ok, val} -> {d, insert_into_db(val)}
          {:error, _} -> {d, :error}
        end
      end
      {:ok, res}
    else
      {:error, msg} -> {:error, msg}
      :gt -> {:error, "first date should be lesser than second date"}
      :eq -> {:error, "first date should be lesser than second date"}
    end
  end
end
