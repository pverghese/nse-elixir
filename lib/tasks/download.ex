defmodule Mix.Tasks.Download do
  @moduledoc """
  Downloads data between from and to dates and inserts into db
  """
  @shortdoc "Downloads data between two dates"

  import NseDownloader
  use Mix.Task
  @requirements ["app.start"]
  def run([from, to]) do
    IO.puts("Starting date: #{from}")
    IO.puts("Ending date: #{to}")

    Logger.configure(level: :error)
    download(from, to)

  end

  def run(_args) do
    IO.puts("Invalid number of arguments provided. Provided a from and to date")
  end

end
