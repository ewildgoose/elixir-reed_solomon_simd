defmodule RsSimd do
  use Rustler, otp_app: :rs_simd, crate: :rs_simd_nif

  @moduledoc """
  Reed-Solomon erasure coding with SIMD acceleration
  """

  @doc """
  Encodes data into recovery shards.

  ## Parameters
  - original_shards: Number of original data shards
  - recovery_shards: Number of recovery shards to generate
  - data: List of binaries representing original shards

  ## Returns
    `{:ok, [recovery_shard1, ...]}` or `{:error, reason}`
  """
  def encode(_original_shards, _recovery_shards, _data), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Decodes missing original shards from available shards.

  ## Parameters
  - original_shards: Original number of data shards
  - recovery_shards: Number of recovery shards that were generated
  - provided_original: List of {index, shard} tuples for available original shards
  - provided_recovery: List of {index, shard} tuples for available recovery shards

  ## Returns
    `{:ok, %{index => restored_shard}}` or `{:error, reason}`
  """
  def decode(_original_shards, _recovery_shards, _provided_original, _provided_recovery),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Decodes and repairs the original message, returning all shards

  ## Parameters
  - original_shards: Original number of data shards
  - recovery_shards: Number of recovery shards that were generated
  - provided_original: List of {index, shard} tuples for available original shards
  - provided_recovery: List of {index, shard} tuples for available recovery shards

  ## Returns
    `{:ok, %{index => restored_shard}}` or `{:error, reason}`
  """
  def correct(_original_shards, _recovery_shards, _provided_original, _provided_recovery),
    do: :erlang.nif_error(:nif_not_loaded)
end
