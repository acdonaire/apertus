#!/bin/bash

# Script de prueba para el servidor Apertus 8B
# Uso: ./test_api.sh [URL_DEL_SERVIDOR]

# URL del servidor (default: localhost)
SERVER_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo "Probando servidor Apertus 8B"
echo "URL: ${SERVER_URL}"
echo "=========================================="

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar resultados
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# Test 1: Health Check
echo ""
echo "${YELLOW}Test 1: Health Check${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "${SERVER_URL}/health")
if [ "$response" = "200" ]; then
    test_result 0 "Health endpoint responde correctamente"
else
    test_result 1 "Health endpoint falló (código: $response)"
fi

# Test 2: Métricas
echo ""
echo "${YELLOW}Test 2: Métricas${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "${SERVER_URL}/metrics")
if [ "$response" = "200" ]; then
    test_result 0 "Metrics endpoint responde correctamente"
else
    test_result 1 "Metrics endpoint falló (código: $response)"
fi

# Test 3: Completion simple
echo ""
echo "${YELLOW}Test 3: Completion simple${NC}"
echo "Prompt: 'La capital de Suiza es'"
response=$(curl -s "${SERVER_URL}/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "La capital de Suiza es",
    "max_tokens": 20,
    "temperature": 0.5
  }')

if echo "$response" | grep -q "choices"; then
    test_result 0 "Completion endpoint funciona"
    echo "Respuesta: $(echo $response | jq -r '.choices[0].text' 2>/dev/null || echo "$response")"
else
    test_result 1 "Completion endpoint falló"
    echo "Error: $response"
fi

# Test 4: Chat completion (español)
echo ""
echo "${YELLOW}Test 4: Chat en español${NC}"
response=$(curl -s "${SERVER_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "Eres un asistente útil y conciso."},
      {"role": "user", "content": "¿Qué es Apertus? Responde en una frase."}
    ],
    "temperature": 0.7,
    "max_tokens": 100
  }')

if echo "$response" | grep -q "choices"; then
    test_result 0 "Chat endpoint funciona"
    echo "Respuesta: $(echo $response | jq -r '.choices[0].message.content' 2>/dev/null || echo "$response")"
else
    test_result 1 "Chat endpoint falló"
    echo "Error: $response"
fi

# Test 5: Chat multilingüe (catalán)
echo ""
echo "${YELLOW}Test 5: Chat en catalán${NC}"
response=$(curl -s "${SERVER_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Digues-me la capital de Catalunya en català."}
    ],
    "temperature": 0.5,
    "max_tokens": 50
  }')

if echo "$response" | grep -q "choices"; then
    test_result 0 "Chat multilingüe funciona"
    echo "Respuesta: $(echo $response | jq -r '.choices[0].message.content' 2>/dev/null || echo "$response")"
else
    test_result 1 "Chat multilingüe falló"
fi

# Test 6: Parámetros de temperatura
echo ""
echo "${YELLOW}Test 6: Diferentes temperaturas${NC}"
echo "Temperatura baja (0.1):"
response=$(curl -s "${SERVER_URL}/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "El modelo Apertus fue creado por",
    "max_tokens": 30,
    "temperature": 0.1
  }')
echo "$(echo $response | jq -r '.choices[0].text' 2>/dev/null || echo "$response")"

echo ""
echo "Temperatura alta (1.2):"
response=$(curl -s "${SERVER_URL}/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "El modelo Apertus fue creado por",
    "max_tokens": 30,
    "temperature": 1.2
  }')
echo "$(echo $response | jq -r '.choices[0].text' 2>/dev/null || echo "$response")"

echo ""
echo "=========================================="
echo "Tests completados"
echo "=========================================="
