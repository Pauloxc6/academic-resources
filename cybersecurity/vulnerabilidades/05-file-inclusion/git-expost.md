## 🐙 Git Exposed — Repositório Git Exposto

## 🧠 O que é Git?

O **Git** é um sistema de controle de versão distribuído e de código aberto, utilizado para acompanhar alterações em projetos.

Ele permite que desenvolvedores:

- criem versões do projeto;
- registrem alterações através de commits;
- trabalhem em equipe;
- recuperem versões anteriores;
- utilizem repositórios remotos;
- criem e integrem branches.

---

## 📁 O que é a pasta `.git`?

Quando um projeto é inicializado com Git:

```bash
git init
```

é criada uma pasta:

```text
.git/
```

Ela contém informações internas do repositório, como:

```text
.git/
├── HEAD
├── config
├── description
├── index
├── objects/
├── refs/
├── logs/
└── ...
```

Dentro dela podem existir informações sobre:

- commits;
- branches;
- referências;
- histórico de alterações;
- configuração do repositório;
- objetos Git;
- referências a repositórios remotos.

📌 O conteúdo exato depende do repositório e da versão/configuração do Git.

---

# 🚨 O que é Git Exposed?

**Git Exposed** ocorre quando a pasta:

```text
/.git/
```

fica acessível através do servidor web.

Por exemplo:

```text
https://exemplo.com/.git/
```

Isso geralmente acontece quando o diretório do projeto é publicado diretamente no servidor sem excluir arquivos e diretórios utilizados pelo Git.

💥 O problema é que o repositório pode revelar informações que não deveriam estar disponíveis publicamente.

---

# 🔎 Como verificar

Em um **pentest autorizado**, uma verificação inicial pode ser:

```text
https://exemplo.com/.git/
```

Existem alguns cenários possíveis.

### 1. `404 Not Found`

```http
HTTP/1.1 404 Not Found
```

Pode indicar que o caminho não está disponível.

```text
.git
 ↓
❌ Não encontrado
```

📌 Isso não prova sozinho que o Git não está exposto, pois o servidor pode estar filtrando o acesso de outras maneiras.

---

### 2. `403 Forbidden`

```http
HTTP/1.1 403 Forbidden
```

Indica que o servidor reconhece o recurso, mas está impedindo o acesso.

```text
.git
 ↓
🔒 Acesso negado
```

Nesse caso, é possível investigar de forma controlada quais arquivos do diretório são acessíveis.

---

### 3. `200 OK`

```http
HTTP/1.1 200 OK
```

Se arquivos ou informações do `.git` forem retornados:

```text
.git/
├── HEAD
├── config
├── objects/
├── refs/
└── logs/
```

💥 Existe uma exposição potencial do repositório.

---

# 🧪 Verificação básica

Por exemplo:

```bash
curl -I https://exemplo.com/.git/
```

Também é possível verificar arquivos específicos:

```bash
curl -I https://exemplo.com/.git/HEAD
```

Se o servidor retornar o conteúdo:

```text
ref: refs/heads/main
```

isso é um forte indicador de que arquivos do repositório Git estão acessíveis.

---

# 🔍 O que pode ser encontrado?

Um `.git` exposto pode permitir recuperar informações como:

```text
Histórico de commits
Branches
Nomes de arquivos
Alterações antigas
Configurações
URLs de repositórios
Código-fonte
```

E, dependendo do conteúdo histórico do projeto:

```text
API keys
tokens
senhas
chaves privadas
credenciais
informações internas
```

⚠️ Mesmo que uma informação tenha sido **apagada do código atual**, ela pode continuar presente em commits antigos.

---

# 🕰️ O problema do histórico

Imagine:

### Commit 1

```python
API_KEY = "segredo"
```

### Commit 2

O desenvolvedor percebe o problema e remove:

```python
API_KEY = ""
```

O código atual aparentemente está seguro.

Porém:

```text
Commit 1
   ↓
API_KEY estava presente
   ↓
Commit 2
   ↓
API_KEY removida
```

Se o `.git` estiver exposto, o histórico pode revelar o conteúdo anterior.

👉 **Remover um segredo do arquivo atual não significa necessariamente removê-lo do histórico Git.**

---

# 🤖 Enumeração

Quando permitido pelo escopo do pentest, ferramentas podem automatizar a identificação e recuperação de repositórios Git expostos.

Uma alternativa simples é procurar os caminhos conhecidos:

```text
/.git/HEAD
/.git/config
/.git/index
/.git/description
/.git/refs/
/.git/objects/
```

Também existem ferramentas específicas para recuperar repositórios Git expostos.

📌 Em ambientes reais, evite baixar ou recuperar dados além do necessário para comprovar a vulnerabilidade.

---

# 🎯 Impactos

Um Git Exposed pode causar:

- divulgação do código-fonte;
- exposição do histórico de desenvolvimento;
- descoberta de endpoints internos;
- descoberta de informações de infraestrutura;
- exposição de segredos antigos;
- exposição de tokens e credenciais;
- auxílio na descoberta de outras vulnerabilidades;
- comprometimento adicional caso credenciais válidas sejam encontradas.

---

# 🛡️ Como prevenir

### 1. Não disponibilizar `.git`

O ideal é que o diretório Git **não esteja dentro do diretório público do servidor web**.

Estrutura inadequada:

```text
/var/www/html/
├── index.php
├── config.php
└── .git/
```

Melhor:

```text
/var/www/
├── .git/
└── html/
    ├── index.php
    └── ...
```

Ou utilizar um processo de deploy que publique apenas os arquivos necessários.

---

### 2. Bloquear `.git` no servidor

Como camada adicional, o servidor web pode bloquear o acesso:

```text
/.git/*
```

📌 Isso é uma defesa adicional, não substitui uma implantação correta.

---

### 3. Não colocar segredos no Git

Evite:

```text
.env
credentials.json
private.key
config-secrets.yml
```

com credenciais reais.

Utilize mecanismos apropriados de gerenciamento de segredos.

---

### 4. Remover segredos do histórico

Se uma chave ou senha foi comprometida, **não basta apagá-la do arquivo atual**.

É necessário:

```text
Revogar/rotacionar o segredo
        ↓
Remover o segredo do histórico quando necessário
        ↓
Verificar onde ele foi utilizado
```

📌 A prioridade é **revogar/rotacionar** a credencial, porque o histórico pode já ter sido copiado.

---

# 📊 Resumo

|Situação|Resultado|
|---|---|
|`/.git/` → `404`|Não acessível por esse caminho|
|`/.git/` → `403`|Recurso reconhecido, mas bloqueado|
|`/.git/` → `200`|Investigar exposição|
|`.git/HEAD` acessível|Forte indicador de Git exposto|
|Histórico acessível|Pode revelar código/segredos antigos|

---

## 🧠 Regra de ouro

👉 **A pasta `.git` é informação de desenvolvimento, não conteúdo público da aplicação.**

O servidor web deve publicar **somente os arquivos necessários para executar a aplicação**, mantendo o repositório Git e seus metadados fora da área pública.