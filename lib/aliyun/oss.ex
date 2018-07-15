defmodule Aliyun.OSS do
  use Tesla

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.BaseUrl, "https://sts.aliyuncs.com")
  plug(Tesla.Middleware.JSON)

  @access_key_id Application.get_env(:aliyun, :access_key_id)
  @access_key_secret Application.get_env(:aliyun, :access_key_id)

  def generate_signature(http_verb, content, content_type, datetime) do
    gmt_formatted_time =
      datetime
      |> Timex.format("{WDshort}, {0D} {Mshort} {YYYY} {h24}:{m}:{s} GMT")

    data =
      [
        @access_key_secret,
        http_verb,
        "\n",
        :crypto.hash(:md5, content),
        "\n",
        gmt_formatted_time,
        ""
      ]
      |> Enum.join()
  end

  def generate_canonicalized_headers(x_oss_headers) do
    x_oss_headers
    |> Enum.map(fn {name, value} ->
      String.downcase(name) <> ":" <> String.downcase(value)
    end)
    |> Enum.sort()
    |> Enum.join("\n")
  end

  def dummy_canonicalized_headers() do
    [
      {"x-oss-server-side-encryption", "AES256"},
      {"x-oss-object-acl", "public-read"}
    ]
  end
end
