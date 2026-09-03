# Servidor LDAP (OpenLDAP)

Este guia apresenta a instalação e configuração básica de um **Servidor LDAP** utilizando o **OpenLDAP**, permitindo centralizar a autenticação e o armazenamento de usuários, grupos e informações da organização.

> **Observação:** O LDAP (Lightweight Directory Access Protocol) é um serviço de diretório, não um banco de dados tradicional. É amplamente utilizado para autenticação centralizada, gerenciamento de usuários e integração com aplicações.

---

# Topologia

```text
                         Clientes
                              │
                 LDAP TCP 389 / LDAPS 636
                              │
         +--------------------------------------+
         |          OpenLDAP Server             |
         |--------------------------------------|
         | slapd                               |
         | ldap-utils                          |
         | Base DN: dc=example,dc=com          |
         +--------------------------------------+
```

---

# Ambiente

| Item | Valor |
|------|--------|
| Servidor | 192.168.122.100 |
| Domínio LDAP | example.com |
| Base DN | dc=example,dc=com |
| Administrador | cn=admin,dc=example,dc=com |

---

# Instalação

## Debian / Ubuntu

Atualize o sistema:

```bash
sudo apt update
```

Instale o OpenLDAP:

```bash
sudo apt install slapd ldap-utils -y
```

Caso a configuração inicial não apareça:

```bash
sudo dpkg-reconfigure slapd
```

---

# Configuração Inicial

Durante a configuração serão solicitadas algumas informações:

| Campo | Exemplo |
|--------|----------|
| DNS Domain Name | example.com |
| Organization Name | Example |
| Administrator Password | ******** |
| Database Backend | MDB |
| Remove Database | No |
| Move Old Database | Yes |

---

# Verificando o Serviço

```bash
sudo systemctl status slapd
```

Habilite na inicialização:

```bash
sudo systemctl enable slapd
```

---

# Testando o Servidor

Consultar o diretório:

```bash
ldapsearch \
-x \
-b "dc=example,dc=com"
```

Consultar como administrador:

```bash
ldapsearch \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
-b "dc=example,dc=com"
```

---

# Criando uma Unidade Organizacional (OU)

Crie o arquivo:

```bash
nano ou.ldif
```

Conteúdo:

```ldif
dn: ou=People,dc=example,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=example,dc=com
objectClass: organizationalUnit
ou: Groups
```

Importe:

```bash
ldapadd \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
-f ou.ldif
```

---

# Criando um Grupo

Arquivo:

```bash
nano group.ldif
```

Conteúdo:

```ldif
dn: cn=users,ou=Groups,dc=example,dc=com

objectClass: posixGroup

cn: users

gidNumber: 10000
```

Adicionar:

```bash
ldapadd \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
-f group.ldif
```

---

# Criando um Usuário

Gere a senha criptografada:

```bash
slappasswd
```

Exemplo de saída:

```text
{SSHA}xxxxxxxxxxxxxxxxxxxxxxxx
```

Crie o arquivo:

```bash
nano user.ldif
```

Conteúdo:

```ldif
dn: uid=paulo,ou=People,dc=example,dc=com

objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount

cn: Paulo Santos

sn: Santos

uid: paulo

uidNumber: 10000

gidNumber: 10000

homeDirectory: /home/paulo

loginShell: /bin/bash

userPassword: {SSHA}xxxxxxxxxxxxxxxx
```

Importe:

```bash
ldapadd \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
-f user.ldif
```

---

# Consultando Usuários

Todos os usuários:

```bash
ldapsearch \
-x \
-b "ou=People,dc=example,dc=com"
```

Usuário específico:

```bash
ldapsearch \
-x \
"(uid=paulo)"
```

---

# Alterando um Usuário

Arquivo:

```bash
nano modify.ldif
```

Conteúdo:

```ldif
dn: uid=paulo,ou=People,dc=example,dc=com

changetype: modify

replace: loginShell

loginShell: /bin/zsh
```

Aplicar:

```bash
ldapmodify \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
-f modify.ldif
```

---

# Removendo um Usuário

```bash
ldapdelete \
-x \
-D "cn=admin,dc=example,dc=com" \
-W \
"uid=paulo,ou=People,dc=example,dc=com"
```

---

# Firewall

### UFW

```bash
sudo ufw allow 389/tcp
sudo ufw allow 636/tcp
sudo ufw reload
```

### Firewalld

```bash
sudo firewall-cmd --permanent --add-service=ldap
sudo firewall-cmd --permanent --add-service=ldaps
sudo firewall-cmd --reload
```

---

# Comandos Úteis

Pesquisar:

```bash
ldapsearch
```

Adicionar:

```bash
ldapadd
```

Modificar:

```bash
ldapmodify
```

Remover:

```bash
ldapdelete
```

Gerar senha:

```bash
slappasswd
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start slapd
```

Parar:

```bash
sudo systemctl stop slapd
```

Reiniciar:

```bash
sudo systemctl restart slapd
```

Status:

```bash
sudo systemctl status slapd
```

Habilitar na inicialização:

```bash
sudo systemctl enable slapd
```

---

# Logs

Visualizar logs:

```bash
sudo journalctl -u slapd
```

Monitorar em tempo real:

```bash
sudo journalctl -fu slapd
```

---

# Arquivos Importantes

```text
/etc/ldap/
/etc/ldap/slapd.d/
/var/lib/ldap/
```

---

# Portas

| Porta | Protocolo | Serviço |
|--------|-----------|----------|
| 389 | TCP | LDAP |
| 636 | TCP | LDAPS (LDAP sobre TLS/SSL) |

---

# Observações

- O **LDAP** centraliza usuários, grupos e informações de autenticação em um único diretório.
- Sempre que possível, utilize **LDAPS (porta 636)** ou **StartTLS** para proteger a comunicação entre clientes e servidor.
- Utilize `slappasswd` para gerar senhas criptografadas antes de adicioná-las ao diretório.
- Em ambientes corporativos, o LDAP é frequentemente integrado a serviços como Samba, Kerberos, Nextcloud, Zabbix e aplicações que suportam autenticação centralizada.
- Faça backups periódicos do diretório LDAP utilizando ferramentas como `slapcat` para exportar os dados em formato LDIF.