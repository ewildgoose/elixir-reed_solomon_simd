use rustler::{ Binary, Env, NewBinary };
use reed_solomon_simd;
use std::collections::HashMap;

rustler::init!("Elixir.RsSimd");

#[rustler::nif]
fn encode<'a>(
    env: Env<'a>,
    original_shards: usize,
    recovery_shards: usize,
    data: Vec<Binary<'a>>
) -> Result<Vec<Binary<'a>>, String> {
    let original: Vec<Vec<u8>> = data
        .into_iter()
        .map(|b| b.as_slice().to_vec())
        .collect();

    let recovery = reed_solomon_simd
        ::encode(original_shards, recovery_shards, &original)
        .map_err(|e| format!("Encoding error: {}", e))?;

    let binaries: Vec<Binary> = recovery
        .into_iter()
        .map(|vec| {
            let mut bin = rustler::NewBinary::new(env, vec.len());
            bin.as_mut_slice().copy_from_slice(&vec);
            Binary::from(bin)
        })
        .collect();

    Ok(binaries)
}

#[rustler::nif]
fn decode<'a>(
    env: Env<'a>,
    original_shards: usize,
    recovery_shards: usize,
    provided_original: Vec<(usize, Binary<'a>)>,
    provided_recovery: Vec<(usize, Binary<'a>)>,
) -> Result<HashMap<usize, Binary<'a>>, String> {
    let original_entries: Vec<(usize, Vec<u8>)> = provided_original
        .into_iter()
        .map(|(k, v)| (k, v.as_slice().to_vec()))
        .collect();

    let recovery_entries: Vec<(usize, Vec<u8>)> = provided_recovery
        .into_iter()
        .map(|(k, v)| (k, v.as_slice().to_vec()))
        .collect();

    let restored = reed_solomon_simd::decode(original_shards, recovery_shards, original_entries, recovery_entries)
        .map_err(|e| format!("Decoding error: {}", e))?;

    let mut result = HashMap::new();
    for (index, data) in restored {
        let mut bin = NewBinary::new(env, data.len());
        bin.as_mut_slice().copy_from_slice(&data);
        result.insert(index, Binary::from(bin));
    }

    Ok(result)
}

#[rustler::nif]
fn correct<'a>(
    env: Env<'a>,
    original_shards: usize,
    recovery_shards: usize,
    provided_original: Vec<(usize, Binary<'a>)>,
    provided_recovery: Vec<(usize, Binary<'a>)>,
) -> Result<Vec<Binary<'a>>, String> {
    // Decode the missing shards
    let original_entries: Vec<(usize, Vec<u8>)> = provided_original
        .iter()
        .map(|(k, v)| (*k, v.as_slice().to_vec()))
        .collect();

    let recovery_entries: Vec<(usize, Vec<u8>)> = provided_recovery
        .iter()
        .map(|(k, v)| (*k, v.as_slice().to_vec()))
        .collect();

    let recovered = reed_solomon_simd::decode(
        original_shards,
        recovery_shards,
        original_entries.clone(),
        recovery_entries,
    ).map_err(|e| format!("Decoding error: {}", e))?;

    // Create Vec<Binary> in order of 0..original_shards
    let mut result = Vec::with_capacity(original_shards);
    for i in 0..original_shards {
        if let Some(orig) = provided_original.iter().find(|(idx, _)| *idx == i) {
            let mut bin = NewBinary::new(env, orig.1.len());
            bin.as_mut_slice().copy_from_slice(orig.1.as_slice());
            result.push(Binary::from(bin));
        } else if let Some(repaired) = recovered.get(&i) {
            let mut bin = NewBinary::new(env, repaired.len());
            bin.as_mut_slice().copy_from_slice(repaired);
            result.push(Binary::from(bin));
        } else {
            return Err(format!("Missing shard {}", i));
        }
    }

    Ok(result)
}