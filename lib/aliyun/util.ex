defmodule Aliyun.Util do
  @moduledoc """
  A collection of utility functions.
  """

  @spec format_datetime(DateTime.t(), :http) :: binary()
  def format_datetime(datetime, :http) do
    datetime
    |> Timex.format("{WDshort}, {0D} {Mshort} {YYYY} {h24}:{m}:{s} GMT")
    |> elem(1)
  end

  @spec format_datetime(DateTime.t(), :iso8601) :: binary()
  def format_datetime(datetime, :iso8601) do
    datetime
    |> Timex.format("{YYYY}-{0M}-{0D}T{h24}:{m}:{s}Z")
    |> elem(1)
  end

  @spec percent_encode(binary()) :: binary()
  def percent_encode(str) do
    URI.encode(str, &URI.char_unreserved?/1)
  end
end
