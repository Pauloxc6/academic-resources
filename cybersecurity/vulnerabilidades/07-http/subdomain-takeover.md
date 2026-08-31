# 🧩 Subdomain Takeover (Aquisição de Subdomínio)

### 🧠 O que é Subdomain Takeover?

**Subdomain Takeover**, também conhecido como **Aquisição de Subdomínio**, é uma vulnerabilidade que ocorre quando um **subdomínio aponta para um serviço externo que não está mais sendo utilizado**, mas o registro DNS continua ativo.

Isso pode permitir que um atacante registre ou reivindique o recurso abandonado no serviço externo e passe a **controlar o conteúdo exibido pelo subdomínio legítimo**.

---

## ⚙️ Como acontece

Imagine que o alvo seja:

```text
example.com
```

Durante a enumeração de subdomínios, encontramos:

```text
subdomain.example.com
```

Analisando os registros DNS:

```text
subdomain.example.com
        │
        ▼
GitHub Pages
```

Por exemplo, o DNS pode possuir um registro semelhante a:

```text
subdomain.example.com CNAME usuario.github.io
```

O problema aparece quando o recurso associado ao serviço externo é removido, mas o registro DNS continua existindo:

```text
subdomain.example.com
        │
        ▼
Recurso abandonado
        │
        ▼
Serviço externo
```

💥 Se o serviço permitir que outra pessoa reivindique aquele recurso, pode surgir uma possibilidade de **Subdomain Takeover**.

---

## 🔎 Encontrando subdomínios

O primeiro passo normalmente é realizar a **enumeração de subdomínios** pertencentes ao domínio autorizado.

Exemplo:

```text
example.com
├── www.example.com
├── api.example.com
├── dev.example.com
├── staging.example.com
└── subdomain.example.com
```

Depois, deve-se analisar os registros DNS dos subdomínios encontrados.

---

## 🌐 Analisando o DNS

Um registro `CNAME` pode indicar que o subdomínio está apontando para um serviço externo.

Exemplo:

```text
subdomain.example.com
        │
        ▼
usuario.github.io
```

Podemos consultar o DNS utilizando ferramentas como:

```bash
dig subdomain.example.com CNAME
```

ou:

```bash
nslookup subdomain.example.com
```

---

## 💥 Quando ocorre o Takeover?

O simples fato de existir um `CNAME` apontando para um serviço externo **não significa que exista uma vulnerabilidade**.

É necessário verificar se:

```text
DNS continua apontando para o serviço
            +
Recurso no serviço não existe mais
            +
Serviço permite reivindicar o recurso
            ↓
     Possível Takeover
```

Por isso, mensagens de erro específicas do provedor podem ser importantes para confirmar a condição.

---

## 🧪 Exploração

Durante um teste autorizado, ferramentas podem auxiliar na identificação de possíveis subdomínios vulneráveis.

### Subzy

Verificar as opções:

```bash
subzy -h
```

Executar a análise de uma lista de hosts:

```bash
subzy --target hosts.txt
```

Onde:

```text
hosts.txt
```

pode conter:

```text
dev.example.com
test.example.com
staging.example.com
subdomain.example.com
```

---

## 🎯 Impactos

Dependendo do serviço e do contexto, um Subdomain Takeover pode permitir:

- Hospedar conteúdo sob um subdomínio legítimo;
- Phishing;
- Distribuição de conteúdo malicioso;
- Abuso da confiança associada ao domínio;
- Roubo de cookies em determinadas configurações;
- Exploração de integrações que confiam no subdomínio;
- Encadeamento com outras vulnerabilidades.

⚠️ O impacto depende principalmente da configuração de **DNS, cookies, CORS, autenticação e do serviço externo utilizado**.

---

## 🔐 Como corrigir

Para evitar Subdomain Takeover:

1. Remover registros DNS de recursos que não são mais utilizados;
2. Manter inventário dos subdomínios;
3. Monitorar registros `CNAME`;
4. Remover recursos externos antes de remover ou alterar sua utilização;
5. Realizar verificações periódicas de DNS;
6. Monitorar subdomínios abandonados;
7. Evitar apontamentos para serviços externos que não são mais necessários.

---

## 🧠 Resumo

```text
Subdomain Takeover

sub.example.com
       │
       ▼
     CNAME
       │
       ▼
Serviço externo
       │
       ▼
Recurso removido
       │
       ▼
Recurso pode ser reivindicado
       │
       ▼
Possível controle do subdomínio
```

📌 **Regra de ouro:**

👉 **Subdomain Takeover geralmente acontece quando um registro DNS permanece apontando para um recurso externo que foi abandonado e pode ser reivindicado por outra pessoa.**