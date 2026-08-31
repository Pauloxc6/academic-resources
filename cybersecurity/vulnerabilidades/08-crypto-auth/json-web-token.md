# 🔑 JSON Web Token (JWT)

## 🧠 O que são JWTs?

**JWT (JSON Web Token)** é um formato padronizado utilizado para transmitir informações em **JSON**, normalmente entre cliente e servidor, com uma **assinatura criptográfica** que permite verificar se o conteúdo foi alterado.

São muito utilizados em:

- Autenticação;
- Gerenciamento de sessão;
- Controle de acesso;
- APIs.

Diferentemente de uma sessão tradicional, algumas informações necessárias para identificar o usuário ficam armazenadas dentro do próprio token.

---

## 🧩 Formato do JWT

Um JWT possui **3 partes**, separadas por `.`:

```text
HEADER.PAYLOAD.SIGNATURE
```

Exemplo:

```text
eyJraWQiOiI5MTM2ZGRiMy1jYjBhLTRhMTktYTA3ZS1lYWRmNWE0NGM4YjUiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTY0ODAzNzE2NCwibmFtZSI6IkNhcmxvcyBNb250b3lhIiwic3ViIjoiY2FybG9zIiwicm9sZSI6ImJsb2dfYXV0aG9yIiwiZW1haWwiOiJjYXJsb3NAY2FybG9zLW1vbnRveWEubmV0IiwiaWF0IjoxNTE2MjM5MDIyfQ.SYZBPIBg2CRjXAJ8vCER0LA_ENjII1JakvNQoP-Hw6GG1zfl4JyngsZReIfqRvIAEi5L4HV0q7_9qGhQZvy9ZdxEJbwTxRs_6Lb-fZTDpW6lKYNdMyjw45_alSCZ1fypsMWz_2mTpQzil0lOtps5Ei_z7mM7M8gCwe_AGpI53JxduQOaB5HkT5gVrv9cKu9CsW5MS6ZbqYXpGyOG5ehoxqm8DL5tFYaW3lB50ELxi0KsuTKEbD0t5BCl0aCR2MBJWAbN-xeLwEenaqBiwPVvKixYleeDQiBEIylFdNNIMviKRgXiYuAvMziVPbwSgkZVHeEdF5MQP1Oe2Spac-6IfA
```

### Header

Contém informações sobre o token:

```json
{
  "kid": "9136ddb3-cb0a-4a19-a07e-eadf5a44c8b5",
  "alg": "RS256"
}
```

### Payload

Contém as **claims** (informações sobre o usuário):

```json
{
  "iss": "portswigger",
  "exp": 1648037164,
  "name": "Carlos Montoya",
  "sub": "carlos",
  "role": "blog_author",
  "email": "carlos@carlos-montoya.net",
  "iat": 1516239022
}
```

### Signature

É a assinatura utilizada para verificar a integridade do token:

```text
SYZBPIBg2CRjXAJ8vCER0LA_ENjII1JakvNQoP-Hw6GG1zfl4JyngsZReIfq...
```

---

## ⚠️ Base64 não é criptografia

O **Header** e o **Payload** são apenas codificados em **Base64URL**.

Isso significa que qualquer pessoa que tenha o JWT pode decodificar essas partes.

Por exemplo:

```text
JWT
 │
 ├── Header    → Base64URL → JSON
 │
 ├── Payload   → Base64URL → JSON
 │
 └── Signature → verifica a integridade
```

Portanto, **não devemos colocar informações secretas no Payload**, como senhas ou chaves privadas.

---

## 🔐 Como funciona a assinatura?

De forma simplificada:

```text
HEADER + "." + PAYLOAD
          │
          ▼
      Algoritmo
          +
      Chave secreta
          │
          ▼
      SIGNATURE
```

Quando o servidor recebe o JWT, ele pode recalcular a assinatura e verificar se o token foi alterado.

Se alguém modificar:

```json
{
  "role": "user"
}
```

para:

```json
{
  "role": "admin"
}
```

a assinatura original não corresponderá ao novo Payload.

---

# 💥 Vulnerabilidades em JWT

Problemas de implementação podem permitir ataques como:

- Manipulação do Payload;
- Algoritmo de assinatura configurado incorretamente;
- Chaves fracas;
- Confusão entre algoritmos;
- Falhas na validação da assinatura;
- Uso inadequado do campo `kid`;
- Vazamento da chave de assinatura;
- Tokens não expirados ou com validação inadequada;
- Falhas de controle de acesso associadas às claims.

---

## 🧪 Teste básico

Durante um pentest autorizado, primeiro identifique se a aplicação utiliza JWT.

Um token normalmente possui o formato:

```text
xxxxx.yyyyy.zzzzz
```

Você pode decodificar **Header** e **Payload** para analisar as claims:

```text
HEADER
PAYLOAD
SIGNATURE
```

Procure principalmente informações como:

```json
{
  "sub": "1234",
  "role": "user",
  "admin": false,
  "exp": 1234567890
}
```

A existência de uma claim como `role` **não significa automaticamente que exista uma vulnerabilidade**. O servidor precisa validar corretamente a assinatura e aplicar o controle de acesso no backend.

---

## 🎯 Impacto

Se um atacante conseguir criar ou modificar JWTs que o servidor aceite como válidos, o impacto pode ser grave:

```text
JWT manipulado
      │
      ▼
Alteração de identidade
      │
      ├── Outro usuário
      ├── Privilégios elevados
      └── Acesso a recursos restritos
```

Isso pode resultar em:

- **Escalada de privilégios**;
- **Impersonação de usuários**;
- Acesso não autorizado;
- Comprometimento de contas;
- Em cenários graves, comprometimento de toda a aplicação.

---

## 🔑 Resumo

```text
JWT
 │
 ├── Header
 │     └── Metadados / algoritmo
 │
 ├── Payload
 │     └── Claims / dados
 │
 └── Signature
       └── Integridade e autenticidade
```

📌 **Regra importante:**

> **JWT não é criptografia. O Payload pode ser lido. A segurança depende principalmente da validação correta da assinatura, algoritmo, claims e controle de acesso no servidor.**