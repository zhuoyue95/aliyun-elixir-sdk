defmodule Aliyun.OSS do
  use Tesla

  import Aliyun.Util

  @access_key_id Application.get_env(:aliyun, :access_key_id)
  @access_key_secret Application.get_env(:aliyun, :access_key_secret)

  @middleware []

  defp client(bucket) do
    middleware =
      [{Tesla.Middleware.BaseUrl, "#{bucket}.oss-cn-shanghai.aliyuncs.com"}] ++ @middleware

    Tesla.client(middleware, Tesla.Adapter.Hackney)
  end

  # Public APIs

  # https://help.aliyun.com/document_detail/31978.html
  @spec put_object(String.t(), String.t(), String.t(), String.t(), [String.t()], :private | :public_read) :: Tesla.Env.result()
  def put_object(file_path, filename, content_type, bucket, key, permission) do
    with {:ok, content} <- File.read(file_path) do
      headers =
        %Aliyun.OSS.Object{
          path: file_path,
          filename: filename,
          bucket: bucket,
          key: key,
          content_type: content_type,
          permission: permission
        }
        |> gen_headers("PUT")

      client = client(bucket)

      put(client, "/#{Enum.join(key, "/")}", content, headers: headers)
    else
      {:error, reason} ->
        {:error, {:file_read_error, reason}}
    end
  end


  # Internals

  @spec gen_headers(Aliyun.OSS.Object.t(), String.t()) :: [{String.t(), String.t()}]
  def gen_headers(%Aliyun.OSS.Object{} = object, http_verb) do
    now_datetime =
      Timex.now()
      |> Timex.shift(hours: 0)

    canonicalized_oss_resource = "/" <> object.bucket <> "/" <> Enum.join(object.key, "/")

    permission =
      object.permission
      |> Atom.to_string()
      |> String.replace("_", "-")

    canonicalized_oss_headers =
      [
        {"x-oss-server-side-encryption", "AES256"},
        {"x-oss-object-acl", permission},
        {"x-oss-storage-class", "Standard"}
      ]
      |> Enum.sort()

    signature =
      gen_signature(
        object,
        now_datetime,
        http_verb,
        canonicalized_oss_headers,
        canonicalized_oss_resource
      )

    [
      {"Content-Disposition", object.filename},
      {"Content-Type", object.content_type},
      {"Date", format_datetime(now_datetime, :http)},
      {"Authorization", "OSS " <> @access_key_id <> ":" <> signature} | canonicalized_oss_headers
    ]
  end

  # https://www.alibabacloud.com/help/zh/doc-detail/31951.htm
  @spec gen_signature(%Aliyun.OSS.Object{}, DateTime.t(), String.t(), [String.t()], String.t()) ::
          String.t()
  def gen_signature(
        %Aliyun.OSS.Object{} = object,
        datetime,
        http_verb,
        canonicalized_oss_headers,
        canonicalized_oss_resource
      ) do
    gmt_formatted_time = format_datetime(datetime, :http)
    # {:ok, content} = File.read(object.path)

    string_to_sign =
      [
        http_verb, # :crypto.hash(:md5, content) |> Base.encode64()
        "",
        object.content_type, #"application/x-www-form-urlencoded"
        gmt_formatted_time,
        generate_canonicalized_headers(canonicalized_oss_headers),
        canonicalized_oss_resource
      ]
      |> Enum.join("\n")

    :crypto.hmac(:sha, @access_key_secret, string_to_sign)
    |> Base.encode64()
  end

  @spec generate_canonicalized_headers([String.t()]) :: String.t()
  def generate_canonicalized_headers(x_oss_headers) do
    x_oss_headers
    |> Enum.map(fn {name, value} ->
      String.downcase(name) <> ":" <> value
    end)
    |> Enum.sort()
    |> Enum.join("\n")
  end
end
