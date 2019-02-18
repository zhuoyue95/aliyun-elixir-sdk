defmodule Aliyun.OSS.Object do
  defstruct path: nil,
            filename: "file",
            bucket: nil,
            key: [],
            content_type: nil,
            permission: :private,
            signature: nil

  @type t :: %__MODULE__{
          path: String.t(),
          filename: String.t(),
          bucket: String.t(),
          key: [String.t()],
          content_type: String.t(),
          permission: :private | :public_read,
          signature: String.t()
        }
end
