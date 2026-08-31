# 🔓 Quebra de Controle de Acesso (Broken Access Control)

## 🧠 O que é Quebra de Controle de Acesso?

**Quebra de Controle de Acesso (Broken Access Control)** ocorre quando uma aplicação possui falhas na forma como determina **quais usuários, sistemas ou dispositivos podem acessar determinados recursos ou executar determinadas ações**.

Em outras palavras, o servidor deveria verificar:

```text
"Este usuário pode acessar este recurso?"
```

Mas, devido a uma implementação inadequada, acaba permitindo o acesso mesmo quando o usuário **não possui autorização**.

---

## ⚙️ Como acontece?

Imagine uma aplicação com três níveis:

```text
Usuário comum
      │
      ├── Ver perfil
      ├── Editar próprio perfil
      └── Criar posts

Administrador
      │
      ├── Gerenciar usuários
      ├── Excluir posts
      └── Alterar configurações
```

Se um usuário comum conseguir acessar:

```text
/admin/users
```

simplesmente digitando a URL, existe uma possível **falha de controle de acesso**.

O servidor deveria verificar a autorização antes de entregar o recurso.

---

## 📌 Exemplos

### IDOR

Um usuário acessa:

```text
https://example.com/profile?id=100
```

E altera para:

```text
https://example.com/profile?id=101
```

Se conseguir visualizar informações privadas do usuário `101`, pode existir uma falha de controle de acesso do tipo **IDOR**.

---

### Acesso a funções administrativas

Usuário comum:

```http
GET /admin/users HTTP/1.1
Host: example.com
```

Se o servidor responder com a página administrativa sem verificar a permissão do usuário:

```text
Usuário comum
     │
     ▼
/admin/users
     │
     ▼
Acesso concedido ❌
```

temos uma quebra de controle de acesso.

---

### Alteração de método HTTP

Uma aplicação pode bloquear:

```http
GET /admin/delete?id=10
```

mas esquecer de aplicar a mesma autorização em:

```http
POST /admin/delete
```

O problema não está no método HTTP em si, mas na **ausência de uma verificação de autorização consistente no servidor**.

---

## 🎯 Impactos

Dependendo da falha, pode permitir:

- Acesso a informações de outros usuários;
- Alteração de dados;
- Exclusão de recursos;
- Acesso a funções administrativas;
- Escalada horizontal de privilégios;
- Escalada vertical de privilégios;
- Comprometimento de contas.

---

## ↔️ Escalada Horizontal

O atacante acessa recursos de **outro usuário com o mesmo nível de privilégio**.

```text
Usuário A
   │
   └──> Dados do Usuário B ❌
```

Exemplo:

```text
/profile?id=123
        ↓
/profile?id=124
```

---

## ⬆️ Escalada Vertical

O atacante consegue acessar funcionalidades de um usuário com **privilégios superiores**.

```text
Usuário comum
      │
      ▼
Função de administrador ❌
```

Exemplo:

```text
/user/dashboard
       ↓
/admin/dashboard
```

---

## 🔍 Durante um Pentest

Procure principalmente:

```text
/admin/
/administrator/
/manage/
/users/
/settings/
/api/users/
/api/admin/
```

E parâmetros que identifiquem objetos:

```text
?id=
?user_id=
?uid=
?account=
?document=
?order_id=
```

Também vale comparar requisições feitas por:

```text
Usuário A
Usuário B
Administrador
Usuário não autenticado
```

A ideia é verificar se o servidor realmente aplica **autorização no backend**.

---

## 🔐 Como prevenir?

A aplicação deve:

- Implementar autorização **no servidor**;
- Negar acesso por padrão;
- Verificar permissões em **cada requisição**;
- Não confiar em parâmetros enviados pelo cliente;
- Validar se o usuário possui acesso ao objeto solicitado;
- Separar claramente autenticação de autorização;
- Aplicar controles consistentes em todas as rotas e métodos HTTP.

📌 **Regra de ouro:**

> **Autenticação responde "quem é você?". Autorização responde "o que você pode fazer?".**

Uma aplicação segura nunca deve confiar apenas no que o cliente informa sobre suas próprias permissões.