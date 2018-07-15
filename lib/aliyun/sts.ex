defmodule Aliyun.STS do
  use Tesla

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.BaseUrl, "https://sts.aliyuncs.com")
  plug(Tesla.Middleware.JSON)

  import Aliyun.Util

  @access_key_id Application.get_env(:aliyun, :access_key_id)
  @access_key_secret Application.get_env(:aliyun, :access_key_secret)

  # https://help.aliyun.com/document_detail/28761.html

  @type query :: %{public: Tesla.Env.param(), assume_role: Tesla.Env.param(), signature: binary()}

  @doc """
  You can pattern match the result with
  - `{:ok, %Tesla.Env{body: body, status: 200} = response}` to get `body["Credentials"]`
  - `{:ok, %Tesla.Env{status: 403} = response}` to return an `:not_authorised` error
  """
  @spec get_token(binary()) :: {:ok, Tesla.Env.t()} | {:error, any()}
  def get_token(role_arn) do
    get("/", query: query_params(role_arn))
  end

  def get_token() do
    query =
      Application.get_env(:aliyun, :default_role_arn)
      |> query_params()

    get("/", query: query)
  end

  @spec query_params(binary()) :: Tesla.Env.param()
  def query_params(role_arn) do
    now_datetime =
      Timex.now()
      |> Timex.shift(hours: 0)

    %{
      public: public_params(now_datetime),
      assume_role: assume_role_params(role_arn),
      signature: ""
    }
    |> gen_signature(now_datetime)
    |> construct_query_params()
  end

  @spec construct_query_params(Aliyun.STS.query()) :: Tesla.Env.param()
  defp construct_query_params(%{public: public, assume_role: assume_role, signature: signature}) do
    [{"Signature", signature}]
    |> Enum.concat(public)
    |> Enum.concat(assume_role)
  end

  @spec public_params(DateTime.t()) :: Tesla.Env.param()
  def public_params(now_datetime) do
    [
      {"Format", "JSON"},
      {"Version", "2015-04-01"},
      {"AccessKeyId", @access_key_id},
      {"SignatureMethod", "HMAC-SHA1"},
      {"SignatureVersion", "1.0"},
      {"SignatureNonce", to_string(:rand.uniform(10_000_000_000))},
      {"Timestamp", format_datetime(now_datetime, :iso8601)}
    ]
  end

  @spec assume_role_params(binary()) :: Tesla.Env.param()
  def assume_role_params(role_arn) do
    [
      {"Action", "AssumeRole"},
      {"RoleArn", role_arn},
      {"RoleSessionName", "booklet"}
    ]
  end

  @spec gen_signature(Aliyun.STS.query(), DateTime.t()) :: Aliyun.STS.query()
  def gen_signature(params, _now_datetime) do
    canonicalized_resource =
      (params.public ++ params.assume_role)
      |> gen_canonicalized_resource()

    data =
      ["GET", percent_encode("/"), percent_encode(canonicalized_resource)]
      |> Enum.join("&")

    signature =
      :crypto.hmac(:sha, @access_key_secret <> "&", data)
      |> Base.encode64()

    params
    |> Map.put(:signature, signature)
  end

  @spec gen_canonicalized_resource(Tesla.Env.param()) :: binary()
  def gen_canonicalized_resource(query_parameters) do
    query_parameters
    |> Enum.sort()
    |> Enum.map(fn {name, value} ->
      percent_encode(name) <> "=" <> percent_encode(value)
    end)
    |> Enum.join("&")
  end
end
