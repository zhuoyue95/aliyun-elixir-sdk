defmodule Aliyun.ECS do
  use Tesla

  adapter Tesla.Adapter.Hackney

  plug Tesla.Middleware.BaseUrl, "https://ecs.aliyuncs.com"
  plug Tesla.Middleware.JSON

  import Aliyun.Util

  @access_key_id Application.get_env(:aliyun, :access_key_id)
  @access_key_secret Application.get_env(:aliyun, :access_key_secret)

  @type permission :: %{
          region_id: bitstring(),
          security_group_id: bitstring(),
          description: bitstring(),
          ip_protocol: bitstring(),
          port_range: bitstring(),
          nic_type: bitstring(),
          policy: bitstring(),
          dest_cidr_ip: bitstring(),
          source_cidr_ip: bitstring(),
          # source_group_id: bitstring(),
          priority: integer
        }

  # https://help.aliyun.com/document_detail/25490.html?spm=a2c4g.11186623.2.15.5b41aa17C9B1su#EcsApiCommonParameters-commonRequestParameters
  # https://help.aliyun.com/document_detail/25492.html?spm=a2c4g.11186623.2.14.e5be6518T87Pnt#EcsApiSignature
  # https://help.aliyun.com/document_detail/25557.html?spm=a2c4g.11186623.6.985.698d2612FHxxdj

  def describe_security_groups(region_id) do
    perform_get_request("DescribeSecurityGroups", [{"RegionId", region_id}])
  end

  def revoke_security_group(permission) do
    perform_get_request("RevokeSecurityGroup", [
      {"RegionId", permission.region_id},
      {"SecurityGroupId", permission.security_group_id}
    ])
  end

  def authorize_security_group(permission) do
    perform_get_request("AuthorizeSecurityGroup", [
      {"RegionId", permission.region_id},
      {"SecurityGroupId", permission.security_group_id},
      {"IpProtocol", permission.ip_protocol},
      {"PortRange", permission.port_range},
      {"NicType", permission.nic_type},
      {"Policy", permission.policy},
      {"SourceCidrIp", permission.source_cidr_ip}
    ])
  end

  def describe_security_group_attribute(region_id, security_group_id, direction) do
    perform_get_request("DescribeSecurityGroupAttribute", [
      {"RegionId", region_id},
      {"SecurityGroupId", security_group_id},
      {"Direction", direction}
    ])
  end

  defp perform_get_request(action, params) do
    get("/", query: query_params([{"Action", action} | params]))
  end

  defp query_params(action_params) do
    now_datetime =
      Timex.now()
      |> Timex.shift(hours: 0)

    %{
      public: public_params(now_datetime),
      action: action_params,
      signature: ""
    }
    |> gen_signature(now_datetime)
    |> construct_query_params()
  end

  defp construct_query_params(%{public: public, action: action, signature: signature}) do
    [{"Signature", signature}]
    |> Enum.concat(public)
    |> Enum.concat(action)
  end

  defp public_params(now_datetime) do
    [
      {"Format", "JSON"},
      {"Version", "2014-05-26"},
      {"AccessKeyId", @access_key_id},
      {"SignatureMethod", "HMAC-SHA1"},
      {"SignatureVersion", "1.0"},
      {"SignatureNonce", to_string(:rand.uniform(10_000_000_000))},
      {"Timestamp", format_datetime(now_datetime, :iso8601)}
    ]
  end

  defp gen_signature(params, _now_datetime) do
    canonicalized_resource =
      (params.public ++ params.action)
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

  defp gen_canonicalized_resource(query_parameters) do
    query_parameters
    |> Enum.sort()
    |> Enum.map(fn {name, value} ->
      percent_encode(name) <> "=" <> percent_encode(value)
    end)
    |> Enum.join("&")
  end
end
