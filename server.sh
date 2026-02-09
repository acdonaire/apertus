#!/bin/bash

# Script de inicio del servidor Apertus 8B
# Configurado para máximo rendimiento en GPU H100

set -e

# Variables de configuración
MODEL_PATH="${MODEL_PATH:-/app/model/Apertus-8B-Instruct-2509-UD-Q4_K_M.gguf}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
CTX_SIZE="${CTX_SIZE:-8192}"  # Apertus soporta hasta 65536, pero 8192 es óptimo para serverless
N_GPU_LAYERS="${N_GPU_LAYERS:-99}"  # Cargar todo el modelo en GPU
THREADS="${THREADS:-4}"
BATCH_SIZE="${BATCH_SIZE:-512}"
UBATCH_SIZE="${UBATCH_SIZE:-256}"

# Parámetros de generación
N_PREDICT="${N_PREDICT:-512}"
TEMPERATURE="${TEMPERATURE:-0.7}"
TOP_P="${TOP_P:-0.9}"
TOP_K="${TOP_K:-40}"
REPEAT_PENALTY="${REPEAT_PENALTY:-1.1}"
MIN_P="${MIN_P:-0.05}"

echo "=========================================="
echo "Iniciando Apertus 8B Instruct Server"
echo "=========================================="
echo "Modelo: ${MODEL_PATH}"
echo "Puerto: ${PORT}"
echo "Contexto: ${CTX_SIZE} tokens"
echo "GPU Layers: ${N_GPU_LAYERS}"
echo "=========================================="

# Verificar que el modelo existe
if [ ! -f "$MODEL_PATH" ]; then
    echo "ERROR: Modelo no encontrado en ${MODEL_PATH}"
    exit 1
fi

# Mostrar información del modelo
echo "Información del modelo:"
ls -lh "$MODEL_PATH"
echo "=========================================="

# Iniciar el servidor llama.cpp
exec llama-server \
    -m "$MODEL_PATH" \
    --host "$HOST" \
    --port "$PORT" \
    -c "$CTX_SIZE" \
    -ngl "$N_GPU_LAYERS" \
    --n-predict "$N_PREDICT" \
    --temp "$TEMPERATURE" \
    --top-p "$TOP_P" \
    --top-k "$TOP_K" \
    --repeat-penalty "$REPEAT_PENALTY" \
    --min-p "$MIN_P" \
    --threads "$THREADS" \
    --batch-size "$BATCH_SIZE" \
    --ubatch-size "$UBATCH_SIZE" \
    --metrics \
    --log-format text \
    --cont-batching \
    --parallel 4 \
    --flash-attn \
    --no-mmap \
    --verbose
