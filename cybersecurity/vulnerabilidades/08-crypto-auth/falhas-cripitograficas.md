# 🔐 Falhas Criptográficas (Cryptographic Failures)

### 🧠 O que são Falhas Criptográficas?

**Falhas Criptográficas**, também conhecidas como **Cryptographic Failures**, ocorrem quando uma aplicação **não protege adequadamente informações sensíveis por meio de criptografia**.

Essa categoria está relacionada principalmente à **implementação incorreta ou ausência de mecanismos criptográficos**, podendo resultar na exposição de dados que deveriam permanecer protegidos.

💡 A ideia principal é observar a **causa do problema**, e não apenas o resultado. Por exemplo, um vazamento de senha pode acontecer porque ela foi armazenada em texto puro, utilizou um algoritmo inadequado ou foi transmitida sem proteção.

---

## 📌 Exemplos

Alguns problemas que podem se enquadrar nessa categoria:

### 1. Dados transmitidos em texto claro

Informações sensíveis podem ser transmitidas sem criptografia:

```text
HTTP
FTP
SMTP
Telnet
```

Por exemplo:

```text
Usuário ────────────────► Servidor
         senha=123456
```

Um protocolo sem proteção adequada pode permitir que essas informações sejam interceptadas.

---

### 2. Dados armazenados em texto claro

Informações sensíveis também podem ser armazenadas sem proteção adequada:

```text
Banco de dados
Arquivos
Backups
Logs
```

Exemplo:

```text
username: paulo
password: 123456
```

💥 Caso o banco de dados seja comprometido, as credenciais podem ser obtidas diretamente.

---

## 🔑 Uso de algoritmos fracos

Outro problema é utilizar algoritmos criptográficos **obsoletos, inadequados ou considerados inseguros** para a finalidade desejada.

Exemplos históricos:

```text
MD5
SHA-1
DES
RC4
```

⚠️ O fato de um algoritmo ainda existir não significa que ele seja apropriado para proteger determinado tipo de informação.

---

## 🔐 Chaves criptográficas fracas

A segurança de um sistema criptográfico também depende da proteção das suas chaves.

Problemas comuns:

```text
→ Chaves muito curtas
→ Chaves previsíveis
→ Chaves padrão
→ Chaves expostas no código
→ Reutilização inadequada de chaves
→ Chaves comprometidas que continuam sendo utilizadas
```

Exemplo:

```php
$secret_key = "123456";
```

Uma chave previsível compromete a segurança do mecanismo que depende dela.

---

## 🌐 Criptografia não aplicada

Dados sensíveis devem ser protegidos durante sua transmissão quando necessário.

Por exemplo:

```text
❌ http://example.com/login

✅ https://example.com/login
```

O HTTPS utiliza **TLS** para proteger a comunicação entre cliente e servidor.

---

## 📜 Certificados não validados

Não basta utilizar criptografia.

A aplicação também precisa **validar corretamente o certificado e a identidade do servidor** durante uma conexão TLS.

Uma implementação que aceita certificados inválidos ou não verifica corretamente o destino pode permitir ataques como:

```text
Cliente
   │
   ▼
Atacante
   │
   ▼
Servidor
```

Nesse cenário, o atacante pode tentar interceptar ou manipular a comunicação.

---

## 🎯 Possíveis impactos

Uma falha criptográfica pode resultar em:

- Exposição de senhas;
- Vazamento de informações pessoais;
- Exposição de dados financeiros;
- Comprometimento de tokens e sessões;
- Recuperação de informações armazenadas;
- Interceptação de comunicações;
- Comprometimento da confidencialidade dos dados.

---

## 🔎 O que verificar durante um pentest?

Durante uma avaliação autorizada, pode-se verificar:

```text
→ A aplicação utiliza HTTPS?
→ O TLS está configurado corretamente?
→ Existem dados sensíveis sendo enviados em HTTP?
→ Senhas estão armazenadas de forma adequada?
→ Existem algoritmos obsoletos?
→ As chaves possuem tamanho e proteção adequados?
→ Existem chaves ou segredos expostos no código?
→ Certificados TLS são devidamente validados?
→ Backups e logs armazenam informações sensíveis sem proteção?
```

---

## 🛡️ Como corrigir?

1. Utilizar **TLS/HTTPS** para proteger dados em trânsito;
2. Utilizar algoritmos criptográficos modernos e adequados;
3. Armazenar senhas utilizando **hashing específico para senhas**, como Argon2id, bcrypt ou scrypt;
4. Utilizar chaves fortes, aleatórias e devidamente protegidas;
5. Nunca utilizar chaves padrão ou comprometidas;
6. Não armazenar chaves e segredos diretamente no código-fonte;
7. Validar corretamente certificados TLS;
8. Proteger backups e arquivos contendo informações sensíveis;
9. Evitar armazenar informações sensíveis desnecessariamente;
10. Manter bibliotecas e componentes criptográficos atualizados.

---

## 🧠 Resumo

```text
Falha Criptográfica

       ↓
Proteção inadequada dos dados
       │
       ├── Dados em texto claro
       ├── Algoritmos fracos
       ├── Chaves fracas
       ├── Chaves expostas
       ├── Criptografia ausente
       └── TLS/certificados mal configurados
       ↓
Exposição de informações sensíveis
```

📌 **Regra de ouro:**

👉 **Não basta utilizar criptografia. É necessário utilizar o algoritmo adequado, chaves fortes e bem protegidas, configuração segura e validação correta de toda a cadeia criptográfica.**