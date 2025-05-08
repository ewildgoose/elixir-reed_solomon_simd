# RsSimd

High-performance [Reed-Solomon erasure coding](https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction) in
Elixir using SIMD-accelerated native code via [`reed-solomon-simd`](https://github.com/AndersTrier/reed-solomon-simd)
Rust crate.

This library provides a simple Elixir interface for encoding and recovering data across multiple shards, useful for
distributed storage, forward error correction, or lossy channel protection.

## Features

- Fast Reed-Solomon encoding using SIMD intrinsics (AVX2, NEON, SSE).
- encode/3 `N` data shards into `M` recovery shards.
- decode/4 any missing original shards from a subset of data + recovery.
- `correct/4` returns the **full original message**, repaired and ordered.

## Installation

Add to `mix.exs`:

```elixir
def deps do
  [
    {:reed_solomon_simd, "~> 0.1"}
  ]
end
```

---

## API

### `encode(original_shards, recovery_shards, data)`

Encodes data shards into parity shards.

Parameters:

- `original_shards`: Number of original data shards (integer)
- `recovery_shards`: Number of recovery/parity shards (integer)
- `data`: List of binaries (length must equal data_shards)

Returns: `{:ok, [recovery_shard1, ...]}` or `{:error, reason}`

### `decode(original_shards, recovery_shards, provided_original, provided_recovery)`

Recovers missing original shards from recovery shards.

Note: This library does NOT check for corruption in the provided original/recovery shards, so if there is a possibility
of corruption in these, then there is a requirement to implement a checksum system to exclude corrupted shards

Parameters:

- `original_shards`: Number of original data shards (integer)
- `recovery_shards`: Number of recovery/parity shards (integer)
- `provided_original`: List of {index, shard} tuples for available original shards
- `provided_recovery`: List of {index, shard} tuples for available recovery shards

## Returns

{:ok, %{index => restored_shard}, ..} or {:error, reason}

### `correct(original_shards, recovery_shards, provided_original, provided_recovery)`

Similar to decode/4, but return value is the entire original data, not just the recovered shards

See the note for decode/4 that this library does not check for corrupted shards.

Parameters:

- `original_shards`: Number of original data shards (integer)
- `recovery_shards`: Number of recovery/parity shards (integer)
- `provided_original`: List of {index, shard} tuples for available original shards
- `provided_recovery`: List of {index, shard} tuples for available recovery shards

## Returns

{:ok, [data1, ...]} or {:error, reason}

## Example

```elixir
# Encode
iex> original_data = [
    <<1,2,3,4>>,
    <<5,6,7,8>>,
    <<9,10,11,12>>,
    <<13,14,15,16>>
  ]

iex> {:ok, ecc} = RsSimd.encode(4, 2, original_data)
{:ok, [<<148, 141, 5, 70>>, <<148, 141, 5, 86>>]}

# Erase some shards
iex> erased = original_data
            |> Enum.with_index(fn e, idx -> {idx, e} end)
            |> Enum.drop(-1)
[
    {0, <<1, 2, 3, 4>>},
    {1, <<5, 6, 7, 8>>},
    {2, "\t\n\v\f"}
]

# Decode
iex> ecc_indexed = ecc |> Enum.with_index(fn e, idx -> {idx, e} end)

iex> {:ok, decoded} = RsSimd.decode(4, 2, erased, ecc_indexed)
{:ok, %{3 => <<13, 14, 15, 16>>}}

iex> {:ok, decoded} = RsSimd.correct(4, 2, erased, ecc_indexed)
{:ok, [<<1, 2, 3, 4>>, <<5, 6, 7, 8>>, "\t\n\v\f", <<13, 14, 15, 16>>]}
```
