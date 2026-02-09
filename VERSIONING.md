# Guía de Versionado para Verda Cloud

## ⚠️ Restricción importante de Verda

**Verda Cloud NO acepta la etiqueta "latest"**. Debes usar siempre etiquetas versionadas específicas.

## ✅ Formato de versiones recomendado

Usa **Semantic Versioning** (SemVer): `vMAJOR.MINOR.PATCH`

Ejemplos:
- `v1.0.0` o `v1.0` - Primera versión estable
- `v1.1.0` o `v1.1` - Nuevas funcionalidades, compatible hacia atrás
- `v1.0.1` - Corrección de bugs
- `v2.0.0` o `v2.0` - Cambios incompatibles (breaking changes)

## 📝 Esquema de versionado

### Cuándo incrementar cada número:

**MAJOR (v2.0)** - Cambios incompatibles:
- Cambio de modelo (de 8B a 70B)
- Cambio de API que rompe compatibilidad
- Cambios en variables de entorno obligatorias

**MINOR (v1.1)** - Nuevas funcionalidades compatibles:
- Nueva cuantización del modelo
- Nuevas variables de entorno opcionales
- Optimizaciones de rendimiento
- Añadir nuevos endpoints

**PATCH (v1.0.1)** - Correcciones:
- Bugs fixes
- Correcciones de configuración
- Mejoras en documentación
- Actualizaciones de seguridad

## 🔨 Cómo crear versiones

### Método 1: Build manual

```bash
# Primera versión
docker build -t apertus-8b:v1.0 .
docker tag apertus-8b:v1.0 acdonaire/apertus-8b:v1.0
docker push acdonaire/apertus-8b:v1.0

# Segunda versión (después de hacer cambios)
docker build -t apertus-8b:v1.1 .
docker tag apertus-8b:v1.1 acdonaire/apertus-8b:v1.1
docker push acdonaire/apertus-8b:v1.1
```

### Método 2: Con Git tags (recomendado con GitHub Actions)

```bash
# Hacer cambios y commit
git add .
git commit -m "Optimización de parámetros del servidor"

# Crear tag de versión
git tag v1.1

# Push código y tag
git push origin main
git push origin v1.1

# GitHub Actions construirá automáticamente acdonaire/apertus-8b:v1.1
```

## 📋 Histórico de versiones sugerido

### v1.0 - Versión inicial
- Modelo: Apertus 8B Q4_K_M
- Contexto: 8192 tokens
- Primera versión estable

### v1.1 - Optimización (ejemplo)
- Contexto aumentado a 16384 tokens
- Flash attention habilitada
- Batch size optimizado

### v1.2 - Ajustes (ejemplo)
- Parámetros de temperatura ajustados
- Timeout aumentado
- Correcciones de logs

### v2.0 - Cambio mayor (ejemplo futuro)
- Cambio a modelo 70B
- Breaking change: nuevas variables requeridas
- API actualizada

## 🎯 Mejores prácticas

### ✅ HAZ:
```bash
docker build -t apertus-8b:v1.0 .
docker tag apertus-8b:v1.0 acdonaire/apertus-8b:v1.0
docker push acdonaire/apertus-8b:v1.0
```

### ❌ NO HAGAS:
```bash
# Esto NO funciona en Verda
docker build -t apertus-8b:latest .
docker push acdonaire/apertus-8b:latest
```

## 🔄 Actualizar versión en Verda

Cuando tengas una nueva versión:

1. Construye y push la nueva versión:
   ```bash
   docker build -t apertus-8b:v1.1 .
   docker tag apertus-8b:v1.1 acdonaire/apertus-8b:v1.1
   docker push acdonaire/apertus-8b:v1.1
   ```

2. En Verda Cloud:
   - Ve a tu contenedor serverless
   - Edita la configuración
   - Cambia la imagen de `acdonaire/apertus-8b:v1.0` a `acdonaire/apertus-8b:v1.1`
   - Guarda y redespliega

## 📊 Mantener registro de versiones

Crea un archivo `CHANGELOG.md` en tu repositorio:

```markdown
# Changelog

## [v1.1] - 2026-02-10
### Añadido
- Flash attention para mejor rendimiento
- Soporte para contextos de 16K tokens

### Cambiado
- Optimizado batch size de 512 a 1024

### Corregido
- Bug en el health check

## [v1.0] - 2026-02-09
### Añadido
- Versión inicial
- Modelo Apertus 8B Q4_K_M
- Servidor llama.cpp optimizado para H100
```

## 🏷️ Etiquetas adicionales útiles

Además de versiones, puedes usar etiquetas descriptivas:

```bash
# Múltiples etiquetas para la misma imagen
docker build -t apertus-8b:v1.1 .
docker tag apertus-8b:v1.1 acdonaire/apertus-8b:v1.1
docker tag apertus-8b:v1.1 acdonaire/apertus-8b:stable
docker tag apertus-8b:v1.1 acdonaire/apertus-8b:q4-optimized

docker push acdonaire/apertus-8b:v1.1
docker push acdonaire/apertus-8b:stable
docker push acdonaire/apertus-8b:q4-optimized
```

Pero para Verda, **siempre especifica la versión numérica** (v1.1), no "stable" o similares.

## 🤔 ¿Qué versión usar en producción?

### Desarrollo/pruebas
- Usa versiones MINOR frecuentes: v1.1, v1.2, v1.3
- Itera rápido
- Prueba optimizaciones

### Producción estable
- Usa versiones específicas probadas: v1.0, v2.0
- Documenta bien los cambios
- Prueba exhaustivamente antes de actualizar

### Rollback
Si v1.1 tiene problemas, simplemente revierte en Verda a v1.0:
```
Imagen: acdonaire/apertus-8b:v1.0  # Versión anterior estable
```

## 📝 Resumen rápido

```bash
# ✅ CORRECTO para Verda
acdonaire/apertus-8b:v1.0
acdonaire/apertus-8b:v1.1
acdonaire/apertus-8b:v2.0
acdonaire/apertus-8b:sha-abc123f

# ❌ NO FUNCIONA en Verda
acdonaire/apertus-8b:latest
acdonaire/apertus-8b
```

**Regla de oro**: Siempre usa etiquetas versionadas específicas en Verda. Nunca "latest".
