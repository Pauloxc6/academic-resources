## ⚙️ Configuração Insegura (Security Misconfiguration)

A falha de **Security Misconfiguration (Configuração Insegura)** acontece quando um sistema, servidor, aplicação ou serviço está configurado de forma **inadequada ou insegura**, deixando recursos, informações ou funcionalidades expostos desnecessariamente.

👉 Em outras palavras: **o sistema pode até estar funcionando corretamente, mas foi configurado de maneira que facilita um ataque.**

---

## ⚙️ Como acontece

Configurações inseguras podem aparecer em diferentes partes do ambiente:

- servidores web
- bancos de dados
- aplicações
- sistemas operacionais
- serviços de rede
- APIs
- containers
- cloud
- painéis administrativos

💥 O problema pode surgir quando:

- credenciais padrão não são alteradas
- serviços desnecessários ficam habilitados
- mensagens de erro revelam informações
- arquivos sensíveis ficam expostos
- permissões são muito permissivas
- recursos administrativos ficam acessíveis
- configurações de segurança são desativadas

---

## 📌 Exemplos práticos

### 🔹 1. Credenciais padrão

Um sistema é instalado com:

```txt
Usuário: admin
Senha: admin
```

💥 Se essas credenciais não forem alteradas, um atacante pode tentar utilizá-las para acessar o sistema.

---

### 🔹 2. Mensagens de erro detalhadas

A aplicação apresenta:

```txt
PDOException:
SQLSTATE[HY000]:
Access denied for user 'root'
```

💥 A mensagem pode revelar informações sobre:

- banco de dados utilizado
- usuário do banco
- estrutura interna da aplicação
- tecnologias utilizadas

Em produção, essas informações normalmente não deveriam ser exibidas ao usuário.

---

### 🔹 3. Directory Listing habilitado

O servidor permite acessar diretamente um diretório:

```txt
/files/
├── backup.zip
├── config.php
├── usuarios.txt
└── documentos/
```

💥 Um atacante pode descobrir arquivos que não deveriam estar publicamente acessíveis.

---

### 🔹 4. Serviço desnecessário exposto

Um servidor possui:

```txt
22/tcp   SSH
80/tcp   HTTP
3306/tcp MySQL
```

Se o MySQL não precisa estar acessível pela rede, deixá-lo exposto aumenta a superfície de ataque.

💥 Quanto mais serviços expostos, maior a quantidade de possíveis pontos de entrada.

---

### 🔹 5. Modo debug habilitado

Uma aplicação Flask pode estar configurada assim:

```python
app.run(debug=True)
```

💥 Em ambiente de produção, isso pode revelar informações internas e, dependendo da situação, criar riscos graves.

---

## 🔎 Como identificar

Durante um pentest, é comum verificar:

- serviços expostos
- portas abertas
- configurações padrão
- permissões
- mensagens de erro
- arquivos e diretórios acessíveis
- interfaces administrativas
- recursos de debug
- headers HTTP
- configurações de segurança

Ferramentas podem auxiliar nessa identificação:

```bash
nmap
```

```bash
nikto
```

```bash
nuclei
```

Também é importante analisar manualmente o comportamento da aplicação.

👉 O objetivo é descobrir **configurações que aumentem desnecessariamente a superfície de ataque**.

---

## 🚨 Impactos

Dependendo da configuração, pode ocorrer:

- vazamento de informações
- acesso não autorizado
- exposição de arquivos
- comprometimento de contas
- acesso a serviços internos
- escalonamento de privilégios
- comprometimento do servidor

📌 O impacto depende diretamente de **qual configuração está incorreta e qual recurso ela expõe**.

---

## 🔐 Em pentest

Testes comuns:

- verificar credenciais padrão
- procurar arquivos e diretórios expostos
- analisar mensagens de erro
- identificar serviços desnecessários
- verificar permissões
- procurar interfaces administrativas
- verificar configurações de debug
- analisar headers e configurações HTTP

👉 O objetivo é encontrar **configurações que possam ser utilizadas para obter informações ou acesso indevido**.

---

## 🛡️ Como prevenir

- alterar credenciais padrão
- desabilitar serviços desnecessários
- restringir serviços à rede necessária
- desativar debug em produção
- configurar corretamente permissões
- evitar mensagens de erro detalhadas
- remover arquivos desnecessários
- aplicar configurações seguras por padrão
- realizar auditorias periódicas

📌 Regra de ouro:

👉 **Tudo que não precisa estar exposto deve permanecer desativado ou restrito.**