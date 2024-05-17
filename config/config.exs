import Config

config :nse_downloader, NseDownloader.Repo,
  database: "stocks",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config(:nse_downloader, ecto_repos: [NseDownloader.Repo])
