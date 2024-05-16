defmodule NseDownloader.Repo do
  use Ecto.Repo,
    otp_app: :nse_downloader,
    adapter: Ecto.Adapters.Postgres
end
