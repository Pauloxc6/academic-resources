# MariaDB (MySQL) - Instalação e Primeiros Passos

Este guia apresenta a instalação do **MariaDB Server**, criação de usuários, bancos de dados, tabelas e comandos básicos de SQL.

---

# Topologia

```text
               Aplicação
                    │
             Porta TCP 3306
                    │
          +----------------------+
          |     MariaDB Server   |
          |   localhost:3306     |
          +----------------------+
```

---

# Instalação

Atualize os repositórios:

```bash
sudo apt update
```

Instale o MariaDB:

```bash
sudo apt install mariadb-server mariadb-client -y
```

Verifique o serviço:

```bash
sudo systemctl status mariadb
```

Habilite a inicialização automática:

```bash
sudo systemctl enable mariadb
```

---

# Configuração Inicial

Execute o assistente de segurança:

```bash
sudo mysql_secure_installation
```

Durante a configuração você poderá:

- Definir senha do usuário root.
- Remover usuários anônimos.
- Desabilitar login remoto do root.
- Remover banco de testes.
- Recarregar as permissões.

---

# Acessando o Banco

```bash
sudo mysql
```

ou

```bash
mysql -u root -p
```

---

# Criando um Usuário

```sql
CREATE USER 'paulo'@'localhost' IDENTIFIED BY 'paulo';
```

Conceda privilégios:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'paulo'@'localhost' WITH GRANT OPTION;
```

Atualize as permissões:

```sql
FLUSH PRIVILEGES;
```

Caso deseje remover um usuário:

```sql
DROP USER 'usuario'@'localhost';
```

> **Observação:** Não é recomendado remover o usuário `root`, pois ele é o administrador principal do banco de dados.

---

# Criando um Banco de Dados

```sql
CREATE DATABASE db_teste
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;
```

Selecionando o banco:

```sql
USE db_teste;
```

Listando bancos:

```sql
SHOW DATABASES;
```

---

# Criando uma Tabela

```sql
CREATE TABLE tb_test (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    senha VARCHAR(32) NOT NULL,
    PRIMARY KEY (id)
);
```

Visualizar tabelas:

```sql
SHOW TABLES;
```

Visualizar estrutura:

```sql
DESCRIBE tb_test;
```

---

# Inserindo Dados

```sql
INSERT INTO tb_test (nome, senha)
VALUES ('admin1', '123');
```

Inserindo vários registros:

```sql
INSERT INTO tb_test (nome, senha)
VALUES
('admin2', '456'),
('admin3', '789');
```

---

# Consultando Dados

Todos os registros:

```sql
SELECT * FROM tb_test;
```

Registro específico:

```sql
SELECT * FROM tb_test
WHERE id = 1;
```

Consulta com OR:

```sql
SELECT * FROM tb_test
WHERE id = 1 OR id = 10;
```

Consulta maior ou igual:

```sql
SELECT * FROM tb_test
WHERE id >= 5;
```

Ordenando resultados:

```sql
SELECT * FROM tb_test
ORDER BY nome;
```

Ordenando em ordem decrescente:

```sql
SELECT * FROM tb_test
ORDER BY id DESC;
```

---

# Atualizando Dados

```sql
UPDATE tb_test
SET senha = '321'
WHERE id = 1;
```

---

# Removendo Registros

```sql
DELETE FROM tb_test
WHERE id = 1;
```

Remover todos os registros:

```sql
DELETE FROM tb_test;
```

---

# Excluindo Tabelas

```sql
DROP TABLE tb_test;
```

---

# Excluindo Banco de Dados

```sql
DROP DATABASE db_teste;
```

---

# Relacionando Tabelas (JOIN)

## Exemplo

Tabela de usuários:

```sql
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100)
);
```

Tabela de pedidos:

```sql
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    produto VARCHAR(100),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
```

---

## INNER JOIN

Retorna apenas registros presentes em ambas as tabelas.

```sql
SELECT
    usuarios.nome,
    pedidos.produto
FROM usuarios
INNER JOIN pedidos
ON usuarios.id = pedidos.usuario_id;
```

---

## LEFT JOIN

Retorna todos os registros da tabela da esquerda.

```sql
SELECT
    usuarios.nome,
    pedidos.produto
FROM usuarios
LEFT JOIN pedidos
ON usuarios.id = pedidos.usuario_id;
```

---

## RIGHT JOIN

Retorna todos os registros da tabela da direita.

```sql
SELECT
    usuarios.nome,
    pedidos.produto
FROM usuarios
RIGHT JOIN pedidos
ON usuarios.id = pedidos.usuario_id;
```

---

# Comandos Úteis

Listar bancos:

```sql
SHOW DATABASES;
```

Selecionar banco:

```sql
USE db_teste;
```

Listar tabelas:

```sql
SHOW TABLES;
```

Mostrar estrutura:

```sql
DESCRIBE tb_test;
```

Mostrar usuários:

```sql
SELECT User, Host
FROM mysql.user;
```

Sair do MariaDB:

```sql
EXIT;
```

---

# Arquivos Importantes

```text
Configuração:
/etc/mysql/

/etc/mysql/mariadb.conf.d/

Serviço:
mariadb.service
```

---

# Gerenciamento do Serviço

Iniciar:

```bash
sudo systemctl start mariadb
```

Parar:

```bash
sudo systemctl stop mariadb
```

Reiniciar:

```bash
sudo systemctl restart mariadb
```

Status:

```bash
sudo systemctl status mariadb
```

Logs:

```bash
sudo journalctl -u mariadb
```

---

# Observações

- Utilize `utf8mb4` para oferecer suporte completo a caracteres Unicode, incluindo emojis.
- Evite utilizar o usuário `root` para aplicações; crie usuários específicos com apenas as permissões necessárias.
- Sempre utilize senhas fortes e mantenha o MariaDB atualizado.
- Faça backups periódicos utilizando ferramentas como `mysqldump` antes de realizar alterações importantes.