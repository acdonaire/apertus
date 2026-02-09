# 🚀 Guía de Despliegue - Próximos Pasos

## ✅ Archivos Creados

Se han creado todos los archivos necesarios para desplegar Apertus 8B:

```
apertus/
├── .dockerignore          # Optimiza el build de Docker
├── .github/
│   └── workflows/
│       └── docker-build.yml  # CI/CD automático (opcional)
├── .gitignore             # Archivos a ignorar en Git
├── Dockerfile             # Imagen Docker optimizada
├── docker-compose.yml     # Para pruebas locales
├── server.sh              # Script de inicio del servidor
├── test_api.sh            # Script de pruebas
├── README.md              # Documentación principal
├── EXAMPLES.md            # Ejemplos de código
└── LICENSE                # Apache 2.0

```

## 📋 Próximos Pasos

### 1️⃣ Subir archivos a tu repositorio GitHub

```bash
# Clona tu repositorio vacío
git clone https://github.com/acdonaire/apertus.git
cd apertus

# Copia todos los archivos descargados
cp -r /ruta/a/archivos/descargados/* .

# Añade todos los archivos
git add .

# Commit inicial
git commit -m "Initial commit: Apertus 8B serverless deployment"

# Push al repositorio
git push origin main
```

### 2️⃣ Construir la imagen Docker

**IMPORTANTE**: 
- El build tardará ~10-15 minutos porque descarga el modelo (5.06 GB) durante la construcción
- **Verda NO acepta la etiqueta "latest"**, usa siempre etiquetas versionadas (v1.0, v1.1, etc.)

```bash
# En tu máquina local con Docker instalado
cd apertus

# Construir con etiqueta versionada (NO usar "latest")
docker build -t apertus-8b:v1.0 .

# Monitoriza el progreso
# Verás la descarga del modelo en el paso "Descargar el modelo durante el build"
```

### 3️⃣ Probar localmente (opcional pero recomendado)

```bash
# Iniciar el contenedor (requiere GPU NVIDIA)
docker run --gpus all -p 8080:8080 apertus-8b:v1.0

# En otra terminal, ejecutar las pruebas
./test_api.sh http://localhost:8080

# O usar docker-compose (edita docker-compose.yml y cambia "latest" por "v1.0")
docker-compose up -d
docker-compose logs -f
```

### 4️⃣ Subir a Docker Registry

#### Opción A: Docker Hub (Recomendado)

```bash
# Login
docker login

# Tag con versión específica (IMPORTANTE: NO usar "latest" para Verda)
docker tag apertus-8b:v1.0 acdonaire/apertus-8b:v1.0

# Push (tardará porque sube ~15-20 GB de imagen total)
docker push acdonaire/apertus-8b:v1.0

# Para futuras versiones, incrementa el número
# docker tag apertus-8b:v1.1 acdonaire/apertus-8b:v1.1
# docker push acdonaire/apertus-8b:v1.1
```

#### Opción B: GitHub Container Registry

```bash
# Login a GitHub
echo $GITHUB_TOKEN | docker login ghcr.io -u acdonaire --password-stdin

# Tag con versión (NO usar "latest")
docker tag apertus-8b:v1.0 ghcr.io/acdonaire/apertus-8b:v1.0

# Push
docker push ghcr.io/acdonaire/apertus-8b:v1.0
```

### 5️⃣ Desplegar en Verda Cloud

1. **Accede a tu panel de Verda Cloud**: https://verda.cloud

2. **Crear nuevo contenedor serverless**:
   - Ve a la sección de "Containers" o "Serverless"
   - Click en "New Container" o "Create"

3. **Configuración básica**:
   ```
   Nombre: apertus-8b-serverless
   Imagen: acdonaire/apertus-8b:v1.0
   Registry: Docker Hub (o el que uses)
   
   ⚠️ IMPORTANTE: NO usar "latest", Verda requiere etiquetas específicas
   ```

4. **Recursos**:
   ```
   GPU: H100 80GB (o A100 si no hay H100)
   RAM: 16 GB
   CPU: 4 cores
   Storage: 30 GB (para la imagen)
   ```

5. **Networking**:
   ```
   Puerto expuesto: 8080
   Protocolo: HTTP
   Acceso: Público o Privado (según necesites)
   ```

6. **Variables de entorno** (opcional):
   ```
   CTX_SIZE=8192
   TEMPERATURE=0.7
   N_GPU_LAYERS=99
   ```

7. **Configuración serverless**:
   ```
   Timeout inicio: 300 segundos (5 minutos - importante!)
   Timeout inactividad: 300 segundos
   Auto-scaling: Deshabilitado (o mín: 0, máx: 1)
   ```

8. **Deploy**: Click en "Deploy" o "Create"

### 6️⃣ Verificar el despliegue

Una vez desplegado, Verda te dará una URL. Pruébala:

```bash
# Reemplaza con tu URL real
export VERDA_URL="https://tu-endpoint.verda.cloud"

# Health check
curl $VERDA_URL/health

# Prueba simple
curl $VERDA_URL/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hola"}],
    "max_tokens": 50
  }'

# O usa el script de pruebas
./test_api.sh $VERDA_URL
```

## 🔧 Solución de Problemas

### Problema: Build muy lento
**Solución**: Es normal, descarga 5 GB. Asegúrate de tener buena conexión.

### Problema: Out of Memory durante el build
**Solución**: Aumenta la memoria de Docker (Settings > Resources > Memory a 8GB+)

### Problema: Error al descargar el modelo
**Solución**: 
```bash
# Prueba descargarlo manualmente primero
pip install huggingface-hub
python -c "from huggingface_hub import hf_hub_download; hf_hub_download('unsloth/Apertus-8B-Instruct-2509-GGUF', 'Apertus-8B-Instruct-2509-UD-Q4_K_M.gguf')"
```

### Problema: Cold start muy largo en Verda
**Causas posibles**:
- El modelo ya está en la imagen, pero puede tardar 30-60s en cargar en GPU
- Aumenta el timeout de inicio a 300s
- La primera llamada siempre será más lenta (cold start)

### Problema: "No space left on device"
**Solución**: La imagen final es ~15-20 GB. Asegúrate de tener espacio suficiente.

## 📊 Monitorización

### Logs en tiempo real
```bash
# Si usas docker-compose localmente
docker-compose logs -f

# Si usas docker run
docker logs -f <container-id>
```

### Métricas del modelo
```bash
curl $VERDA_URL/metrics
```

### Rendimiento esperado
- **Cold start**: 30-60 segundos (primera llamada)
- **Warm**: <1 segundo por request
- **Tokens/segundo**: 30-50 (depende de la GPU)
- **Memoria GPU**: ~8 GB durante inferencia

## 💡 Optimizaciones Opcionales

### Reducir tamaño de contexto para más velocidad
Edita `server.sh` y cambia:
```bash
CTX_SIZE="${CTX_SIZE:-4096}"  # En vez de 8192
```

### Usar cuantización más ligera (Q3)
En el `Dockerfile`, cambia:
```dockerfile
ENV MODEL_FILE="Apertus-8B-Instruct-2509-UD-Q3_K_M.gguf"
```
Tamaño: ~4 GB (vs 5 GB de Q4), algo menos preciso pero más rápido.

Luego reconstruye con nueva versión:
```bash
docker build -t apertus-8b:v1.1 .
docker tag apertus-8b:v1.1 acdonaire/apertus-8b:v1.1
docker push acdonaire/apertus-8b:v1.1
```

### Habilitar CI/CD con GitHub Actions
1. Ve a tu repositorio > Settings > Secrets
2. Añade:
   - `DOCKER_USERNAME`: tu usuario de Docker Hub
   - `DOCKER_PASSWORD`: tu token de Docker Hub
3. Cada push a `main` construirá y publicará automáticamente

## 📈 Próximos Pasos Avanzados

1. **Añadir autenticación**: Implementar API keys en el servidor
2. **Rate limiting**: Limitar requests por usuario
3. **Caching**: Cachear respuestas comunes
4. **Monitoring**: Integrar Prometheus/Grafana
5. **Múltiples réplicas**: Escalar horizontalmente
6. **Load balancer**: Distribuir carga entre instancias

## 🆘 Soporte

Si tienes problemas:
1. Revisa los logs: `docker logs <container>`
2. Verifica el README.md para troubleshooting
3. Prueba localmente primero antes de desplegar
4. Abre un issue en GitHub con los logs del error

## 📞 Contacto

- **GitHub**: https://github.com/acdonaire/apertus
- **Issues**: https://github.com/acdonaire/apertus/issues

---

**¡Listo para desplegar!** 🎉

El siguiente comando inicia todo (recuerda: NO usar "latest" para Verda):
```bash
docker build -t apertus-8b:v1.0 . && \
docker tag apertus-8b:v1.0 acdonaire/apertus-8b:v1.0 && \
docker push acdonaire/apertus-8b:v1.0
```

**Nota sobre versionado:**
- Primera versión: `v1.0`
- Cambios menores: `v1.1`, `v1.2`, etc.
- Cambios mayores: `v2.0`, `v3.0`, etc.
- Siempre usa etiquetas versionadas, nunca "latest" con Verda
