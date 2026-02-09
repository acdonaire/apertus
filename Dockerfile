# Dockerfile para Apertus 8B Serverless
# Compatible con GPUs A100 y H100 en Verda Cloud

FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Variables del modelo
ENV MODEL_REPO="unsloth/Apertus-8B-Instruct-2509-GGUF"
ENV MODEL_FILE="Apertus-8B-Instruct-2509-UD-Q4_K_M.gguf"
ENV MODEL_PATH="/app/model/${MODEL_FILE}"

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Compilar llama.cpp con soporte CUDA universal (A100 y H100)
RUN git clone https://github.com/ggerganov/llama.cpp && \
    cd llama.cpp && \
    cmake -B build \
        -DGGML_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES="80;90" \
        -DLLAMA_CURL=ON \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release -j$(nproc) && \
    cp build/bin/llama-server /usr/local/bin/ && \
    cp build/bin/llama-cli /usr/local/bin/ && \
    cd .. && \
    rm -rf llama.cpp

# Instalar herramientas de Python para descargar el modelo
RUN pip3 install --no-cache-dir huggingface-hub hf-transfer

# Habilitar transferencia rápida de HuggingFace
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Descargar el modelo durante el build (crítico para serverless - evita cold start largo)
RUN mkdir -p /app/model && \
    python3 -c "from huggingface_hub import hf_hub_download; \
    hf_hub_download( \
        repo_id='${MODEL_REPO}', \
        filename='${MODEL_FILE}', \
        local_dir='/app/model', \
        local_dir_use_symlinks=False \
    )" && \
    echo "Modelo descargado: $(ls -lh /app/model/)" && \
    # Verificar que el archivo existe y tiene tamaño correcto (~5GB)
    test -f "${MODEL_PATH}" && \
    echo "Verificación exitosa: ${MODEL_PATH}"

# Copiar script de inicio
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh

# Puerto del servidor
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Iniciar servidor
CMD ["/app/server.sh"]
