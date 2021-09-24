use Mix.Config

defmodule Repo do
  def __adapter__ do
    true
  end

  def config do
    [priv: "tmp/#{inspect(Ecto.Gen.Migration)}", otp_app: :rawl]
  end
end

config :rawl,
  ecto_repos: [
    Repo
  ]
