## 🧠 Sensitive Data Exposure (Exposição de Dados Sensíveis)

A **Sensitive Data Exposure** acontece quando informações sensíveis são **expostas sem proteção adequada**, seja durante o **armazenamento** ou a **transmissão**.

👉 Diferente de _Insecure Data Storage_, aqui o foco é mais na **exposição** (principalmente em trânsito ou acesso indevido).

---

## ⚙️ Como acontece

O sistema falha em proteger dados como:

- senhas
- dados pessoais (CPF, endereço, etc.)
- dados bancários
- tokens e sessões

💥 Isso pode ocorrer por:

- falta de criptografia
- uso de HTTP ao invés de HTTPS
- dados retornados indevidamente em respostas
- APIs mal configuradas

---

## 📌 Exemplos práticos

### 🔹 1. Site sem HTTPS

```txt
http://site.com/login
```

💥 Dados podem ser interceptados na rede (sniffing)

---

### 🔹 2. Senha retornada na resposta

```json
{
  "usuario": "joao",
  "senha": "123456"
}
```

💥 Informação sensível exposta na API

---

### 🔹 3. Token exposto na URL

```txt
/reset?token=abc123
```

💥 Pode ser capturado em logs ou histórico

---

### 🔹 4. Dados sensíveis em cache

- navegador ou proxy salva informações

💥 outro usuário pode acessar

---

### 🔹 5. Criptografia fraca ou inexistente

- dados armazenados ou transmitidos sem proteção

💥 fácil de quebrar ou ler

---

## 🚨 Impactos

- vazamento de dados pessoais 
- roubo de contas
- fraude financeira
- problemas legais (ex: LGPD)
- perda de confiança no sistema

---

## 🔐 Em pentest

O atacante testa:

- se o site usa HTTPS
- respostas da API (vazamento de dados)
- tokens expostos
- tráfego de rede
- dados em cache ou logs

👉 Objetivo: capturar informações sensíveis

---

## 🛡️ Como prevenir

- usar **HTTPS (TLS)** sempre
- criptografar dados sensíveis
- não retornar dados desnecessários
- proteger tokens (não usar em URL)
- usar algoritmos seguros
- controlar cache de dados sensíveis