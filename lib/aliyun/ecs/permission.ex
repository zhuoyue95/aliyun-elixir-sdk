defmodule Aliyun.ECS.Permission do
  @type t() :: %{
    region_id: bitstring(),
    security_group_id: bitstring(),
    description: bitstring(),
    ip_protocol: bitstring(),
    port_range: bitstring(),
    nic_type: bitstring(),
    policy: bitstring(),
    dest_cidr_ip: bitstring(),
    source_cidr_ip: bitstring(),
    source_group_id: bitstring(),
    priority: integer
  }

  def cast_to_permission(region_id, security_group_id, permission) do
    %{
      region_id: region_id,
      security_group_id: security_group_id,
      description: permission["Description"],
      ip_protocol: permission["IpProtocol"],
      port_range: permission["PortRange"],
      nic_type: permission["NicType"],
      policy: permission["Policy"],
      dest_cidr_ip: permission["DestCidrIp"],
      source_cidr_ip: permission["SourceCidrIp"],
      source_group_id: permission["SourceGroupId"],
      priority: permission["Priority"]
    }
  end
end
