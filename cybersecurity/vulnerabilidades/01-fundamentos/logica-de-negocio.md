## 🧠 Falha de Lógica de Negócio (Business Logic Flaw)

A **falha de lógica de negócio** acontece quando o sistema tem um erro na forma como as regras do negócio foram implementadas.

👉 Ou seja: o sistema funciona “tecnicamente certo”, mas **a lógica está errada**.

---

## ⚙️ Como acontece

Diferente de outras falhas, aqui o problema não é código inseguro, mas sim:

- regras mal definidas
- validações incompletas
- fluxo de processo incorreto

👉 O sistema permite ações que **não deveriam ser possíveis**.

---

## 📌 Exemplos práticos

### 🔹 1. Compra com valor negativo

```txt
Preço: R$100
Desconto aplicado: -200
Total: -R$100
```

💥 Usuário pode “ganhar dinheiro” ao invés de pagar

---

### 🔹 2. Pular etapas do processo

```txt
/checkout → /pagamento → /confirmacao
```

Usuário acessa direto:

```txt
/confirmacao
```

💥 Finaliza compra sem pagar

---

### 🔹 3. Uso duplicado de cupom

```txt
Cupom: DESCONTO10
```

💥 Usuário aplica várias vezes o mesmo cupom

---

### 🔹 4. Alteração de parâmetros na URL

```txt
/transferir?valor=100
```

Usuário muda para:

```txt
/transferir?valor=10000
```

💥 Sistema aceita sem validação correta

---

### 🔹 5. Acesso indevido por sequência lógica

- usuário comum acessa função de admin  
    💥 porque o sistema não verifica corretamente permissões em cada etapa
    

---

## 🚨 Impactos

- prejuízo financeiro
- fraude
- acesso indevido
- quebra de regras do sistema
- abuso de funcionalidades

---

## 🔐 Em pentest

Essa falha é explorada testando:

- fluxos fora da ordem
- repetição de ações
- manipulação de parâmetros
- combinações inesperadas de ações

👉 Aqui o foco é **pensar como o sistema deveria funcionar e tentar quebrar isso**.

---

## 🛡️ Como prevenir

- definir regras de negócio claramente
- validar cada etapa do processo
- não confiar no fluxo do usuário
- validar dados no backend sempre
- implementar controle de estado (ex: etapa atual do processo)
- revisar cenários de abuso (abuse cases)