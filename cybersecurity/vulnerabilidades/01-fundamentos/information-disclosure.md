## 🕵️ Information Disclosure (Divulgação de Informações)

A falha de **Information Disclosure**, também conhecida como **Information Leakage**, acontece quando uma aplicação **expõe informações que deveriam permanecer protegidas ou não deveriam ser acessíveis ao usuário**.

👉 Essas informações podem parecer insignificantes isoladamente, mas podem ajudar um atacante a **entender a estrutura do sistema, identificar usuários, descobrir tecnologias ou encontrar dados sensíveis**.

---

## ⚙️ Como acontece

Uma aplicação pode revelar informações através de:

- mensagens de erro
- arquivos de configuração
- arquivos de backup
- comentários no código
- páginas administrativas
- diretórios expostos
- respostas HTTP
- arquivos temporários
- logs
- informações sobre usuários
- metadados

💥 O problema acontece quando informações internas são disponibilizadas para pessoas que **não deveriam ter acesso a elas**.

---

## 📌 Exemplos práticos

### 🔹 1. Mensagem de erro

A aplicação retorna:

```text
SQLSTATE[HY000]:
Access denied for user 'root'
at 192.168.1.10:3306
```

💥 A mensagem pode revelar:

- usuário do banco
- endereço interno
- porta
- tecnologia utilizada

---

### 🔹 2. Arquivo de configuração exposto

Um servidor disponibiliza:

```text
/config.php
```

E o arquivo contém:

```php
$db_user = "admin";
$db_password = "senha123";
```

💥 Nesse caso, informações extremamente sensíveis podem ser expostas diretamente.

📌 **Credenciais encontradas durante um teste autorizado não devem ser reutilizadas fora do escopo definido.**

---

### 🔹 3. Arquivos de backup

O servidor possui:

```text
/backup/
/site.zip
/database.bkp
/config.php.bak
```

💥 Arquivos de backup podem conter:

- código-fonte
- configurações
- credenciais
- dados de usuários
- informações internas

---

### 🔹 4. Comentários no código

Um desenvolvedor deixa:

```html
<!-- Banco de dados: 192.168.1.50 -->
<!-- TODO: remover painel antigo -->
```

💥 Mesmo sem explorar nenhuma vulnerabilidade diretamente, essas informações podem ajudar no reconhecimento da aplicação.

---

## 🔎 Information Disclosure e Google Hacking

Mecanismos de busca podem indexar arquivos que foram publicados acidentalmente.

Operadores de pesquisa podem ser utilizados para **auditoria de exposição**, por exemplo:

```text
filetype:txt
```

```text
inurl:robots.txt filetype:txt
```

```text
intext:"endereco" filetype:txt
```

```text
intext:"senha" filetype:bkp
```

💥 A ideia é verificar se informações que deveriam ser privadas acabaram sendo **indexadas publicamente**.

⚠️ Em pentests, isso deve ser realizado **somente sobre domínios e sistemas autorizados**.

---

## 🚨 Impactos

Information Disclosure pode resultar em:

- exposição de dados pessoais
- vazamento de credenciais
- exposição de informações financeiras
- descoberta de usuários
- exposição de código-fonte
- descoberta da infraestrutura
- identificação de tecnologias
- auxílio em ataques posteriores

📌 Muitas vezes, o Information Disclosure **não é o ataque final**, mas fornece informações que tornam outros ataques muito mais fáceis.

---

## 🔎 Em pentest

Durante um pentest, é comum procurar:

- arquivos `.bak`
- arquivos `.old`
- arquivos `.zip`
- arquivos `.log`
- arquivos `.txt`
- arquivos de configuração
- mensagens de erro
- comentários HTML/JavaScript
- diretórios listáveis
- metadados
- informações em mecanismos de busca

Exemplo:

```text
Reconhecimento
     ↓
Information Disclosure
     ↓
Descoberta de informação
     ↓
Possível vetor de ataque
```

👉 O objetivo é descobrir **quais informações o sistema está revelando além do necessário**.

---

## 🛡️ Como prevenir

- remover arquivos desnecessários do servidor
- nunca armazenar credenciais em arquivos públicos
- desabilitar mensagens de erro detalhadas em produção
- proteger arquivos de configuração
- remover backups do diretório público
- revisar comentários e código publicado
- restringir diretórios administrativos
- configurar corretamente permissões
- revisar logs e arquivos temporários
- verificar periodicamente o que está sendo indexado

📌 **Regra de ouro:**

👉 **Se uma informação não precisa ser pública, ela não deve ser exposta publicamente.**