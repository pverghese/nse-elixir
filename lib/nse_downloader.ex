defmodule NseDownloader do
  @moduledoc """
  `NseDownloader` used for downloading bhavcopy data
  """


  @headers  [
    {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
    {"Accept-encoding", "gzip, deflate, br"},
    {"Connection", "keep-alive"},
    {"User-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"}]

  def string_components_for_date({year, month, day}) do
    month = case month do
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
    day = Integer.to_string(day) |> String.pad_leading(2,"0")
    {year, month, day}

  end
  def download_for_date(%{year: year, month: month, day: day}) do
    {year, month, day} = string_components_for_date({year, month, day})
    url = "https://nsearchives.nseindia.com/content/historical/EQUITIES/#{year}/#{month}/cm#{day}#{month}#{year}bhav.csv.zip"

    case HTTPoison.request(:get, url,"", @headers, timeout: 10000) do
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
  @spec verify(String.t()) :: {:ok, %{year: pos_integer(), month: pos_integer(), day: pos_integer()}} | {:error, String.t()}
  def verify(date) do
    [year, month, day] = String.split(date, "-", trim: true) |> Enum.map(& String.to_integer(&1))

    cond do
      year < 1990 or year > 2030 -> {:error, "year not in range"}
      month < 1 or month > 12 -> {:error, "Month not in range"}
      day < 1 or day > 31 -> {:error, "day not in range"}
      true -> {:ok, %{year: year, month: month, day: day}}
    end

  end

  def download(date) do
    with {:ok, f} <- verify(date),
         {:ok, [{fname, val}]} <- download_for_date(f),
         exists <- File.exists?("./temp") do
          case exists do
            true -> File.write("./temp/#{fname |> to_string}", val)
            false -> a = IO.getn(:stdio, "Create temp directory and write file(y/n)")
              case a do
                "y" ->
                  File.mkdir("./temp")
                  File.write("./temp/#{fname |> to_string}", val)
                _ -> {:error, "./temp directory does not exist"}
              end
          end
    else
          {:error, _} -> {:error, "Error while downloading. Data might not exist"}
    end

  end
  @spec download(String.t(), String.t()) :: :ok
  def download(from, to) do
    with {:ok, f} <- verify(from),
      {:ok , t} <- verify(to) do
        IO.puts("from: #{f.year}-#{f.month}-#{f.day}")
        IO.puts("to: #{t.year}-#{t.month}-#{t.day}")
      else
        {:error, msg} -> IO.puts("Error: #{msg}")
      end
  end
end
