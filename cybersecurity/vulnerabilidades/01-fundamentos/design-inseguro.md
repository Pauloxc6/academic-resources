## 🏗️ Falha de Design Inseguro (Insecure Design)

A falha de **Insecure Design (Design Inseguro)** acontece quando a própria **arquitetura, lógica ou modelo de segurança de um sistema foi projetado de maneira inadequada**.

👉 Diferente de um simples erro de implementação, aqui o problema pode estar **no próprio projeto da aplicação**. Mesmo que o código seja bem escrito, uma lógica insegura pode continuar vulnerável.

---

## ⚙️ Como acontece

Um sistema precisa considerar segurança desde sua concepção:

- regras de negócio
- autenticação e autorização
- armazenamento de dados
- gerenciamento de credenciais
- controle de confiança
- arquitetura da aplicação
- comunicação entre componentes
- tratamento de erros

💥 O problema aparece quando a segurança **não é considerada durante o planejamento e desenvolvimento**.

Por exemplo, imagine um sistema que permite:

```text
Usuário → Solicita transferência → Sistema aprova automaticamente
```

Se o projeto não considerar limites, autenticação adicional ou validações para operações sensíveis, pode existir uma falha de design.

👉 Nesse caso, não basta apenas "corrigir uma linha de código". É necessário **reavaliar a lógica do sistema**.

---

## 📌 Exemplos práticos

### 🔹 1. Armazenamento inseguro de credenciais

O sistema foi projetado para armazenar senhas diretamente:

```text
usuario: paulo
senha: MinhaSenha123
```

💥 Se o banco de dados for comprometido, as credenciais podem ser obtidas diretamente.

O correto é utilizar mecanismos apropriados de armazenamento de senhas, como **hashing com algoritmos específicos para senhas**.

---

### 🔹 2. Mensagens de erro revelando informações

A aplicação retorna:

```text
Erro ao conectar:

Host: db-interno
Database: sistema
User: root
Password: ********
```

💥 O sistema foi projetado para fornecer informações internas que não deveriam ser apresentadas ao usuário.

Isso está relacionado à **CWE-209 — Generation of Error Message Containing Sensitive Information**.

---

### 🔹 3. Violação de limite de confiança

Imagine uma aplicação com:

```text
Frontend → API → Banco de Dados
```

O design assume que os dados enviados pelo frontend são confiáveis.

```json
{
  "role": "admin"
}
```

💥 Se o backend utilizar essa informação diretamente para decidir permissões, o usuário pode manipular o próprio nível de acesso.

Esse conceito está relacionado à **CWE-501 — Trust Boundary Violation**.

---

### 🔹 4. Credenciais protegidas insuficientemente

Um sistema permite autenticação apenas com:

```text
Usuário + Senha
```

para uma operação extremamente sensível, sem considerar mecanismos adicionais de proteção.

💥 Dependendo do contexto, uma credencial comprometida pode ser suficiente para realizar ações críticas.

Esse cenário está relacionado à **CWE-522 — Insufficiently Protected Credentials**.

---

## 🧠 Design Inseguro vs. Bug de Código

Essa diferença é importante:

**Bug de implementação:**

```python
if senha == senha_correta:
    login()
```

O problema pode estar na implementação específica.

**Falha de design:**

```text
Usuário autenticado
        ↓
Transferência de R$ 100.000
        ↓
Sem confirmação adicional
Sem limite
Sem validação de risco
```

Nesse caso, mesmo que o código esteja funcionando exatamente como foi programado, **a lógica de segurança foi mal projetada**.

👉 **Design inseguro = o sistema foi pensado de maneira insegura.**

---

## 🚨 Impactos

Dependendo da falha, pode ocorrer:

- acesso não autorizado
- vazamento de informações
- comprometimento de credenciais
- fraude
- escalonamento de privilégios
- violação de regras de negócio
- exposição de dados sensíveis
- comprometimento de outros componentes

📌 O impacto depende principalmente **da lógica afetada e da importância do recurso protegido**.

---

## 🔎 Em pentest

Durante um pentest, é importante analisar não apenas o código, mas também **a lógica e a arquitetura da aplicação**.

Testes comuns:

- testar regras de negócio
- tentar contornar fluxos de autenticação
- verificar limites de operações
- analisar controles de autorização
- testar diferentes níveis de privilégio
- verificar como os componentes confiam uns nos outros
- procurar informações sensíveis em erros
- analisar como credenciais são armazenadas e utilizadas

👉 O objetivo é descobrir se existe alguma **falha estrutural na maneira como o sistema foi projetado**.

---

## 🛡️ Como prevenir

- envolver profissionais de **AppSec** durante o desenvolvimento
- realizar **modelagem de ameaças**
- considerar segurança desde a fase de design
- utilizar bibliotecas e componentes de segurança confiáveis
- definir corretamente limites de confiança
- separar responsabilidades entre as camadas
- implementar autenticação e autorização adequadas
- realizar testes unitários e de integração
- revisar a arquitetura periodicamente
- documentar decisões de segurança
- utilizar segregação de redes quando necessário

### 🔹 Modelagem de ameaças

Antes de implementar uma funcionalidade, pergunte:

```text
O que estamos protegendo?
        ↓
Quem pode acessar?
        ↓
O que pode dar errado?
        ↓
Como um atacante poderia abusar?
        ↓
Como podemos impedir?
```

💡 Isso permite identificar problemas **antes que eles se transformem em vulnerabilidades no código**.

---

## 📚 Exemplos de CWEs relacionadas

- **CWE-209** — Geração de mensagem de erro contendo informações sensíveis
- **CWE-256** — Armazenamento desprotegido de credenciais
- **CWE-501** — Violação de limite de confiança
- **CWE-522** — Credenciais protegidas insuficientemente

---

📌 **Regra de ouro:**

👉 **Segurança deve fazer parte do design desde o início — não ser adicionada depois que a aplicação já está pronta.**