# Ejemplos de Uso - Apertus 8B API

Este archivo contiene ejemplos de cómo usar la API de Apertus 8B desde diferentes lenguajes de programación.

## Python

### Usando requests

```python
import requests
import json

# Configuración
API_URL = "http://tu-endpoint.verda.cloud"

# Chat completion
def chat_completion(messages, temperature=0.7, max_tokens=512):
    response = requests.post(
        f"{API_URL}/v1/chat/completions",
        headers={"Content-Type": "application/json"},
        json={
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens
        }
    )
    return response.json()

# Ejemplo de uso
messages = [
    {"role": "system", "content": "Eres un asistente útil."},
    {"role": "user", "content": "¿Qué es Apertus?"}
]

result = chat_completion(messages)
print(result["choices"][0]["message"]["content"])
```

### Usando OpenAI SDK (compatible)

```python
from openai import OpenAI

# Configurar cliente apuntando a tu servidor
client = OpenAI(
    base_url="http://tu-endpoint.verda.cloud/v1",
    api_key="no-necesario"  # El servidor no requiere API key
)

# Usar como OpenAI
response = client.chat.completions.create(
    model="apertus-8b",  # El nombre es ignorado
    messages=[
        {"role": "system", "content": "Eres un experto en IA."},
        {"role": "user", "content": "Explícame qué hace un modelo de lenguaje"}
    ],
    temperature=0.7,
    max_tokens=300
)

print(response.choices[0].message.content)
```

## JavaScript/Node.js

### Usando fetch

```javascript
const API_URL = "http://tu-endpoint.verda.cloud";

async function chatCompletion(messages, options = {}) {
    const response = await fetch(`${API_URL}/v1/chat/completions`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            messages: messages,
            temperature: options.temperature || 0.7,
            max_tokens: options.max_tokens || 512
        })
    });
    
    return await response.json();
}

// Ejemplo de uso
const messages = [
    { role: "system", content: "Eres un traductor experto." },
    { role: "user", content: "Traduce 'Hello world' al español" }
];

chatCompletion(messages)
    .then(result => {
        console.log(result.choices[0].message.content);
    })
    .catch(error => console.error('Error:', error));
```

### Usando OpenAI SDK

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
    baseURL: 'http://tu-endpoint.verda.cloud/v1',
    apiKey: 'not-needed'
});

async function main() {
    const completion = await client.chat.completions.create({
        model: 'apertus-8b',
        messages: [
            { role: 'user', content: '¿Cuál es la capital de Suiza?' }
        ],
        temperature: 0.5,
        max_tokens: 100
    });
    
    console.log(completion.choices[0].message.content);
}

main();
```

## cURL

### Chat Completion

```bash
curl http://tu-endpoint.verda.cloud/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "Eres un asistente multilingüe."},
      {"role": "user", "content": "¿Hablas catalán?"}
    ],
    "temperature": 0.7,
    "max_tokens": 200
  }'
```

### Completion simple

```bash
curl http://tu-endpoint.verda.cloud/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Suiza es conocida por",
    "max_tokens": 100,
    "temperature": 0.8
  }'
```

### Streaming

```bash
curl http://tu-endpoint.verda.cloud/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Cuenta una historia corta"}
    ],
    "stream": true,
    "max_tokens": 300
  }'
```

## PHP

```php
<?php
function chatCompletion($messages, $temperature = 0.7, $maxTokens = 512) {
    $url = 'http://tu-endpoint.verda.cloud/v1/chat/completions';
    
    $data = [
        'messages' => $messages,
        'temperature' => $temperature,
        'max_tokens' => $maxTokens
    ];
    
    $options = [
        'http' => [
            'header'  => "Content-Type: application/json\r\n",
            'method'  => 'POST',
            'content' => json_encode($data)
        ]
    ];
    
    $context = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    
    return json_decode($result, true);
}

// Ejemplo de uso
$messages = [
    ['role' => 'user', 'content' => '¿Qué es la inteligencia artificial?']
];

$response = chatCompletion($messages);
echo $response['choices'][0]['message']['content'];
?>
```

## Go

```go
package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
)

type Message struct {
    Role    string `json:"role"`
    Content string `json:"content"`
}

type ChatRequest struct {
    Messages    []Message `json:"messages"`
    Temperature float64   `json:"temperature"`
    MaxTokens   int       `json:"max_tokens"`
}

type ChatResponse struct {
    Choices []struct {
        Message Message `json:"message"`
    } `json:"choices"`
}

func chatCompletion(apiURL string, messages []Message) (string, error) {
    reqBody := ChatRequest{
        Messages:    messages,
        Temperature: 0.7,
        MaxTokens:   512,
    }
    
    jsonData, err := json.Marshal(reqBody)
    if err != nil {
        return "", err
    }
    
    resp, err := http.Post(
        apiURL+"/v1/chat/completions",
        "application/json",
        bytes.NewBuffer(jsonData),
    )
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()
    
    body, err := io.ReadAll(resp.Body)
    if err != nil {
        return "", err
    }
    
    var result ChatResponse
    if err := json.Unmarshal(body, &result); err != nil {
        return "", err
    }
    
    return result.Choices[0].Message.Content, nil
}

func main() {
    apiURL := "http://tu-endpoint.verda.cloud"
    messages := []Message{
        {Role: "user", Content: "¿Qué idiomas hablas?"},
    }
    
    response, err := chatCompletion(apiURL, messages)
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    
    fmt.Println(response)
}
```

## Rust

```rust
use reqwest;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct Message {
    role: String,
    content: String,
}

#[derive(Serialize)]
struct ChatRequest {
    messages: Vec<Message>,
    temperature: f32,
    max_tokens: u32,
}

#[derive(Deserialize, Debug)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Deserialize, Debug)]
struct Choice {
    message: Message,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    let api_url = "http://tu-endpoint.verda.cloud";
    
    let request = ChatRequest {
        messages: vec![
            Message {
                role: "user".to_string(),
                content: "Hola, ¿cómo estás?".to_string(),
            }
        ],
        temperature: 0.7,
        max_tokens: 200,
    };
    
    let response = client
        .post(&format!("{}/v1/chat/completions", api_url))
        .json(&request)
        .send()
        .await?
        .json::<ChatResponse>()
        .await?;
    
    println!("{}", response.choices[0].message.content);
    
    Ok(())
}
```

## Ejemplos Avanzados

### Conversación multi-turno (Python)

```python
def multi_turn_conversation():
    messages = []
    
    while True:
        user_input = input("Tú: ")
        if user_input.lower() in ['salir', 'exit', 'quit']:
            break
            
        messages.append({"role": "user", "content": user_input})
        
        response = chat_completion(messages)
        assistant_message = response["choices"][0]["message"]["content"]
        
        print(f"Apertus: {assistant_message}")
        messages.append({"role": "assistant", "content": assistant_message})

multi_turn_conversation()
```

### Traducción multilingüe

```python
def translate(text, source_lang, target_lang):
    messages = [
        {
            "role": "system",
            "content": f"Eres un traductor profesional de {source_lang} a {target_lang}."
        },
        {
            "role": "user",
            "content": f"Traduce el siguiente texto: {text}"
        }
    ]
    
    response = chat_completion(messages, temperature=0.3)
    return response["choices"][0]["message"]["content"]

# Ejemplo
texto_es = "El modelo Apertus soporta más de 1000 idiomas"
traduccion_ca = translate(texto_es, "español", "catalán")
print(traduccion_ca)
```

### Procesamiento por lotes (Node.js)

```javascript
async function batchProcess(prompts) {
    const results = await Promise.all(
        prompts.map(prompt => 
            chatCompletion([
                { role: "user", content: prompt }
            ])
        )
    );
    
    return results.map(r => r.choices[0].message.content);
}

// Ejemplo
const prompts = [
    "Resume: La inteligencia artificial",
    "Resume: Machine learning",
    "Resume: Deep learning"
];

batchProcess(prompts).then(console.log);
```
