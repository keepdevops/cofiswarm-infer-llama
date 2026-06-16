#!/usr/bin/env bash
set -euo pipefail
: "${COFISWARM_INFER_MODEL_PATH:?}"
: "${MATRIX_LLAMA_SERVER:?}"
HOST="${COFISWARM_INFER_HOST:-0.0.0.0}"
PORT="${COFISWARM_INFER_PORT:-8080}"
PARALLEL="${COFISWARM_INFER_PARALLEL:-1}"
CTX_CAP="${COFISWARM_INFER_CTX_CAP:-8192}"
CONTEXT="${COFISWARM_INFER_CONTEXT:-1024}"
GPU="${COFISWARM_INFER_GPU_LAYERS:-99}"
SLOTS_DIR="${MATRIX_SLOTS_DIR:-/tmp/cofiswarm-slots}"
mkdir -p "$SLOTS_DIR"
CTX=$(( CONTEXT * PARALLEL ))
if (( CTX > CTX_CAP )); then CTX=$CTX_CAP; fi
ARGS=(-m "$COFISWARM_INFER_MODEL_PATH" -c "$CTX" --host "$HOST" --port "$PORT"
  --n-gpu-layers "$GPU" --parallel "$PARALLEL" --metrics
  --slot-save-path "$SLOTS_DIR" --fit off)
if [[ "${COFISWARM_INFER_FLASH_ATTN:-0}" == "1" ]]; then
  ARGS+=(--flash-attn on --cache-type-k q8_0 --cache-type-v q8_0)
fi
exec "$MATRIX_LLAMA_SERVER" "${ARGS[@]}" "$@"
