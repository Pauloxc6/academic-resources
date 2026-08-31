## 🧠 Privilege Escalation (Escalonamento de Privilégio)

A **Privilege Escalation** acontece quando um usuário consegue **aumentar seus privilégios dentro do sistema**, acessando recursos ou funções que não deveria.

👉 Ou seja: alguém comum vira admin (ou algo próximo disso).

---

## ⚙️ Tipos principais

### 🔹 1. Escalonamento Horizontal

- acessar dados de outro usuário no mesmo nível

👉 Exemplo: usuário A acessa conta do usuário B

---

### 🔹 2. Escalonamento Vertical

- subir de nível de privilégio

👉 Exemplo: usuário comum vira administrador

---

## 📌 Exemplos práticos

### 🔹 1. Alteração de parâmetro (IDOR)

```txt
/perfil?id=123
```

Usuário muda para:

```txt
/perfil?id=124
```

💥 Acessa dados de outra pessoa

---

### 🔹 2. Alteração de role

```json
{
  "role": "user"
}
```

Usuário muda:

```json
{
  "role": "admin"
}
```

💥 Ganha acesso administrativo

---

### 🔹 3. Acesso direto a rota restrita

```txt
/admin/dashboard
```

💥 Se não houver validação → acesso liberado

---

### 🔹 4. Uso de falha de lógica

- sistema não verifica permissões corretamente

💥 usuário executa ações de admin sem ser admin

---

### 🔹 5. Mass Assignment

```json
{
  "isAdmin": true
}
```

💥 Escalonamento direto (ligação com outra falha)

---

## 🚨 Impactos

- acesso total ao sistema
- vazamento de dados sensíveis
- modificação de informações críticas
- controle completo da aplicação
- comprometimento geral

---

## 🔐 Em pentest

Testes comuns:

- mudar IDs (IDOR)
- acessar rotas restritas
- manipular roles/permissões
- testar endpoints escondidos
- explorar outras falhas (mass assignment, lógica, etc.)

👉 Objetivo: ganhar mais acesso do que deveria

---

## 🛡️ Como prevenir

- validar permissões no **backend sempre**
- implementar **controle de acesso (RBAC/ABAC)**
- checar autorização em TODAS as rotas
- não confiar em dados do cliente
- usar princípio do **menor privilégio**