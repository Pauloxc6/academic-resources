## 🧬 Falha na Integridade de Dados e Software (Software and Data Integrity Failures)

A falha de **Software and Data Integrity Failures** acontece quando um sistema **confia em software, atualizações, bibliotecas, dados ou processos que não tiveram sua integridade ou origem devidamente verificada**.

👉 Ou seja: o sistema aceita algo como **confiável sem confirmar se foi realmente produzido por uma fonte legítima e se não foi alterado**.

Essa categoria do **OWASP Top 10** envolve principalmente **atualizações de software, pipelines de CI/CD, dependências e dados críticos**.

---

## ⚙️ Como acontece

O problema pode aparecer quando o sistema:

- instala atualizações sem verificar sua origem
- utiliza dependências não confiáveis
- não valida a integridade de arquivos
- possui pipelines CI/CD mal protegidos
- confia em artefatos sem assinatura ou verificação
- utiliza dados críticos sem validação de integridade
- desserializa dados não confiáveis

💥 O ponto central é:

> **O sistema confia em algo que poderia ter sido alterado ou substituído.**

---

## 📌 Exemplos práticos

### 🔹 1. Atualização sem verificação de integridade

Imagine um sistema que baixa uma atualização:

```text
https://exemplo.com/update.zip
```

O sistema simplesmente baixa e instala:

```text
Download
   ↓
Instalação
```

Sem verificar:

```text
Origem
Integridade
Assinatura
```

💥 Se o arquivo for substituído por uma versão maliciosa, o sistema pode executar código não confiável.

---

### 🔹 2. Pipeline CI/CD comprometido

Imagine o fluxo:

```text
Git
 ↓
Build
 ↓
Testes
 ↓
Deploy
```

Um atacante consegue modificar o processo de build.

```text
Código legítimo
      ↓
   Build alterado
      ↓
Software comprometido
      ↓
   Produção
```

💥 O software malicioso pode chegar até o ambiente de produção através de um processo que originalmente era considerado confiável.

---

### 🔹 3. Dependência comprometida

Uma aplicação utiliza:

```text
Biblioteca A
Biblioteca B
Biblioteca C
```

Uma dependência é substituída por uma versão maliciosa.

```text
Aplicação
    ↓
Dependência
    ↓
Código malicioso
```

💥 A aplicação pode acabar executando código que seus desenvolvedores não pretendiam utilizar.

---

### 🔹 4. Desserialização insegura

A **desserialização** transforma dados serializados novamente em objetos utilizados pela aplicação.

Exemplo conceitual:

```text
Dados serializados
        ↓
   Desserialização
        ↓
      Objeto
```

Se a aplicação desserializa **dados não confiáveis** sem mecanismos adequados de segurança:

```text
Entrada controlada pelo usuário
          ↓
Desserialização insegura
          ↓
Comportamento inesperado
```

💥 Dependendo da tecnologia e da implementação, isso pode resultar em consequências graves, incluindo **execução de código**.

👉 Por isso, **desserialização insegura** passou a ser tratada dentro dessa categoria do OWASP.

---

## 🚨 Impactos

Dependendo do cenário, pode ocorrer:

- execução de código malicioso
- comprometimento da aplicação
- comprometimento do servidor
- alteração de software
- vazamento de informações
- alteração de dados
- comprometimento da cadeia de desenvolvimento
- propagação de código malicioso

📌 Uma característica importante é que o ataque pode acontecer **antes mesmo de o software chegar ao usuário final**, por exemplo, comprometendo uma dependência ou pipeline de CI/CD.

---

## 🔎 Em pentest

Durante um pentest, é comum analisar:

- processo de atualização
- dependências
- integridade de arquivos
- assinaturas digitais
- pipelines CI/CD
- repositórios
- permissões do processo de build
- origem dos artefatos
- mecanismos de desserialização

Exemplo conceitual:

```text
Código
  ↓
Dependências
  ↓
Build
  ↓
Artefato
  ↓
Deploy
  ↓
Produção
```

👉 O objetivo é descobrir **em quais pontos o sistema confia em software ou dados sem verificar adequadamente sua integridade**.

---

## 🧠 Integridade × Confidencialidade

É importante diferenciar:

```text
Confidencialidade
↓
"Quem pode ver?"

Integridade
↓
"Quem pode alterar?"

Autenticidade
↓
"De onde veio?"
```

Uma aplicação pode proteger muito bem o acesso aos dados, mas ainda assim possuir um problema de integridade se aceitar **arquivos, atualizações ou componentes sem verificar sua origem e autenticidade**.

---

## 🛡️ Como prevenir

- verificar assinaturas de atualizações
- validar a integridade de arquivos
- utilizar hashes quando apropriado
- proteger pipelines CI/CD
- restringir permissões de build e deploy
- proteger repositórios
- controlar dependências
- utilizar fontes confiáveis
- revisar alterações no pipeline
- evitar desserialização de dados não confiáveis
- utilizar formatos de dados mais seguros quando possível
- validar a origem dos artefatos antes da implantação

📌 **Regra de ouro:**

👉 **Não confie em software ou dados apenas porque eles chegaram até você — verifique sua origem e integridade antes de utilizá-los.**