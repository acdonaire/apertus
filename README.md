# Apertus 8B - Despliegue Serverless

Despliegue optimizado del modelo **Apertus 8B Instruct** (modelo de IA suizo open-source) como contenedor serverless en Verda Cloud con GPUs H100.

## 🎯 Características

- **Modelo**: Apertus-8B-Instruct-2509 (cuantizado Q4_K_M - 5.06 GB)
- **Multilingüe**: Soporte para más de 1000 idiomas incluyendo español, catalán, gallego, euskera
- **Open Source**: Licencia Apache 2.0 - código y datos completamente abiertos
- **Optimizado**: Configurado específicamente para GPUs H100 con CUDA 12.1
- **Serverless-ready**: Modelo precargado en la imagen Docker para minimizar cold starts

## 📊 Especificaciones Técnicas

- **Parámetros**: 8 mil millones
- **Tamaño cuantizado**: 5.06 GB (Q4_K_M)
- **Contexto**: 8,192 tokens (ampliable hasta 65,536)
- **RAM GPU requerida**: ~8 GB durante inferencia
- **Arquitectura GPU**: CUDA Compute Capability 9.0 (H100)

## 🚀 Despliegue Rápido

### Paso 1: Construir la imagen Docker

```bash
# Clonar el repositorio
git clone https://github.com/acdonaire/apertus.git
cd apertus

# Construir la imagen con versión específica (tarda ~10-15 minutos)
# IMPORTANTE: NO usar "latest" - Verda requiere etiquetas versionadas
docker build -t apertus-8b:v1.0 .
```

### Paso 2: Probar localmente (opcional)

```bash
# Ejecutar con GPU
docker run --gpus all -p 8080:8080 apertus-8b:v1.0

# Probar el endpoint
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "¿Qué sabes sobre Suiza?"}
    ],
    "temperature": 0.7,
    "max_tokens": 512
  }'
```

### Paso 3: Subir a Docker Registry

```bash
# Etiquetar para Docker Hub con versión (NO usar "latest")
docker tag apertus-8b:v1.0 acdonaire/apertus-8b:v1.0

# Push
docker login
docker push acdonaire/apertus-8b:v1.0
```

### Paso 4: Desplegar en Verda Cloud

1. Accede a tu panel de Verda Cloud
2. Crear nuevo contenedor serverless:
   - **Imagen**: `acdonaire/apertus-8b:v1.0` (usar versión específica)
   - **GPU**: H100 (80GB)
   - **Puerto**: 8080
   - **Timeout**: 300s (para cold start inicial)
   - **Memoria**: 16GB RAM
   - **Variables de entorno** (opcionales):
     ```
     CTX_SIZE=8192
     TEMPERATURE=0.7
     N_GPU_LAYERS=99
     ```

## 🔧 Configuración

### Variables de Entorno Disponibles

| Variable | Default | Descripción |
|----------|---------|-------------|
| `HOST` | 0.0.0.0 | Host del servidor |
| `PORT` | 8080 | Puerto del servidor |
| `CTX_SIZE` | 8192 | Tamaño del contexto en tokens |
| `N_GPU_LAYERS` | 99 | Capas a cargar en GPU (99 = todas) |
| `TEMPERATURE` | 0.7 | Temperatura de generación |
| `TOP_P` | 0.9 | Top-p sampling |
| `TOP_K` | 40 | Top-k sampling |
| `REPEAT_PENALTY` | 1.1 | Penalización por repetición |
| `N_PREDICT` | 512 | Tokens máximos a generar |

### Modificar Configuración

Edita `server.sh` para cambiar parámetros de generación o reconstruye con diferentes variables:

```bash
docker build \
  --build-arg CTX_SIZE=16384 \
  -t apertus-8b:custom .
```

## 📝 Uso de la API

El servidor expone una API compatible con OpenAI:

### Chat Completions

```bash
curl http://tu-endpoint.verda.cloud/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "Eres un asistente útil y conciso."},
      {"role": "user", "content": "Explícame qué es Apertus"}
    ],
    "temperature": 0.7,
    "max_tokens": 256
  }'
```

### Completions (texto simple)

```bash
curl http://tu-endpoint.verda.cloud/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "La capital de Suiza es",
    "max_tokens": 50,
    "temperature": 0.5
  }'
```

### Health Check

```bash
curl http://tu-endpoint.verda.cloud/health
```

### Métricas

```bash
curl http://tu-endpoint.verda.cloud/metrics
```

## 🌍 Casos de Uso

Apertus es especialmente útil para:

- **Aplicaciones multilingües**: Soporta idiomas minoritarios y europeos
- **Cumplimiento normativo**: Entrenado respetando GDPR y leyes suizas
- **Transparencia**: Modelo completamente auditable
- **Soberanía digital**: Sin dependencia de proveedores estadounidenses

## 💰 Costes en Verda

Con configuración serverless:
- **Activo**: ~$2.50/hora (GPU H100)
- **Inactivo**: ~$0.10/día (storage del contenedor)
- **Estrategia recomendada**: Detener cuando no se use, arranque en ~30-45 segundos

## 🔍 Troubleshooting

### El modelo no carga
```bash
# Verificar que el archivo existe en la imagen
docker run apertus-8b:latest ls -lh /app/model/
```

### Out of Memory
- Reducir `CTX_SIZE` a 4096 o menos
- Verificar que la GPU tiene al menos 8GB libres

### Respuestas lentas
- Aumentar `BATCH_SIZE` y `UBATCH_SIZE`
- Verificar que `N_GPU_LAYERS=99` (todo en GPU)

### Cold start muy largo
- El modelo se descarga durante el build, no en runtime
- Si tarda mucho, verifica la velocidad de red de Verda

## 📚 Recursos

- **Modelo original**: [swiss-ai/Apertus-8B-Instruct-2509](https://huggingface.co/swiss-ai/Apertus-8B-Instruct-2509)
- **GGUF (usado aquí)**: [unsloth/Apertus-8B-Instruct-2509-GGUF](https://huggingface.co/unsloth/Apertus-8B-Instruct-2509-GGUF)
- **Documentación Apertus**: [Swiss AI Initiative](https://swiss-ai.org)
- **llama.cpp**: [GitHub](https://github.com/ggerganov/llama.cpp)

## 📄 Licencia

Este proyecto y el modelo Apertus están bajo licencia **Apache 2.0**.

## 🤝 Contribuciones

Pull requests bienvenidos. Para cambios importantes, abre primero un issue.

---

**Desarrollado por**: Alberto Donaire  
**Repositorio**: https://github.com/acdonaire/apertus  
**Modelo**: Swiss AI Initiative - EPFL, ETH Zurich, CSCS
