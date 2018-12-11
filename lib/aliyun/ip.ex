defmodule Aliyun.IP do
  use Tesla

  adapter Tesla.Adapter.Hackney

  plug Tesla.Middleware.BaseUrl, "http://ip-api.com"
  plug Tesla.Middleware.JSON

  @spec mine() :: {:error, any()} | {:ok, Tesla.Env.t()}
  def mine do
    get("/json", query: [])
  end
end
