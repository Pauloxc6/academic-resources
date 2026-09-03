# Cluster de Alta Disponibilidade (Pacemaker + Corosync + Nginx)

Este guia apresenta a configuração de um cluster de alta disponibilidade utilizando **Pacemaker**, **Corosync** e **PCS**, com dois nós executando o **Nginx** e um **IP Flutuante (Floating IP)**.

---

# Topologia

```text
                   Clientes
                       │
               192.168.10.20
                 (Floating IP)
                       │
        ┌──────────────┴──────────────┐
        │                             │
+--------------------+      +--------------------+
|       Node1        |      |       Node2        |
| 192.168.10.10      |      | 192.168.10.11      |
| node1.example.com  |      | node2.example.com  |
|                    |      |                    |
| Nginx              |      | Nginx              |
| Pacemaker          |◄────►| Pacemaker          |
| Corosync           |      | Corosync           |
+--------------------+      +--------------------+
```

---

# Ambiente

| Host | IP |
|------|----------------|
| Node1 | 192.168.10.10 |
| Node2 | 192.168.10.11 |
| Floating IP | 192.168.10.20 |

---

# 1. Configurando o DNS Local

Em **ambos os servidores**, edite o arquivo:

```bash
sudo nano /etc/hosts
```

Adicione:

```text
192.168.10.10    node1.example.com
192.168.10.11    node2.example.com
```

Verifique a comunicação:

```bash
ping node1.example.com
ping node2.example.com
```

---

# 2. Instalando o Nginx

Instale o servidor Web:

```bash
sudo apt update
sudo apt install nginx -y
```

Habilite o serviço:

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

Configure uma página de teste.

## Node1

```bash
echo "Esta é a página padrão para node1.example.com" | sudo tee /usr/share/nginx/html/index.html
```

## Node2

```bash
echo "Esta é a página padrão para node2.example.com" | sudo tee /usr/share/nginx/html/index.html
```

---

# 3. Instalando Pacemaker, Corosync e PCS

Instale os pacotes em ambos os servidores.

```bash
sudo apt install corosync pacemaker pcs -y
```

Habilite o serviço do PCS:

```bash
sudo systemctl enable pcsd
sudo systemctl start pcsd
sudo systemctl status pcsd
```

---

# 4. Configurando o Usuário do Cluster

Durante a instalação é criado o usuário **hacluster**.

Defina a senha (a mesma em ambos os nós):

```bash
sudo passwd hacluster
```

---

# 5. Autenticando os Nós

Execute apenas no **Node1**.

```bash
sudo pcs cluster auth node1.example.com node2.example.com \
-u hacluster \
-p node@1.example! \
--force
```

---

# 6. Criando o Cluster

Ainda no **Node1**:

```bash
sudo pcs cluster setup --name examplecluster \
node1.example.com \
node2.example.com
```

Habilite o cluster:

```bash
sudo pcs cluster enable --all
```

Inicie o cluster:

```bash
sudo pcs cluster start --all
```

---

# 7. Verificando o Cluster

```bash
sudo pcs status
```

ou

```bash
sudo crm_mon -1
```

---

# 8. Configurando as Propriedades do Cluster

## Desabilitar STONITH

```bash
sudo pcs property set stonith-enabled=false
```

## Ignorar Quorum

```bash
sudo pcs property set no-quorum-policy=ignore
```

Verifique as propriedades:

```bash
sudo pcs property list
```

---

# 9. Criando o IP Flutuante

```bash
sudo pcs resource create floating_ip \
ocf:heartbeat:IPaddr2 \
ip=192.168.10.20 \
cidr_netmask=24 \
op monitor interval=60s
```

---

# 10. Criando o Recurso do Nginx

```bash
sudo pcs resource create http_server \
ocf:heartbeat:nginx \
configfile="/etc/nginx/nginx.conf" \
op monitor timeout="20s" interval="60s"
```

---

# 11. Verificando os Recursos

```bash
sudo pcs status resources
```

ou

```bash
sudo pcs status
```

---

# 12. Firewall (Ubuntu)

Permita o tráfego HTTP:

```bash
sudo ufw allow http
```

Permita o tráfego do cluster:

```bash
sudo ufw allow high-availability
```

Recarregue o firewall:

```bash
sudo ufw reload
```

---

# 13. Testes

Verifique o status do cluster:

```bash
sudo pcs status
```

Visualização em tempo real:

```bash
sudo crm_mon
```

Teste o IP flutuante:

```bash
ping 192.168.10.20
```

Teste o servidor Web:

```bash
curl http://192.168.10.20
```

ou

```bash
wget -qO- http://192.168.10.20
```

Desligue um dos nós para verificar o failover:

```bash
sudo systemctl stop pacemaker
```

ou

```bash
sudo poweroff
```

O IP flutuante deverá migrar automaticamente para o outro nó.

---

# Comandos Úteis

Status do cluster:

```bash
sudo pcs status
```

Status dos recursos:

```bash
sudo pcs status resources
```

Listar propriedades:

```bash
sudo pcs property list
```

Parar o cluster:

```bash
sudo pcs cluster stop --all
```

Iniciar o cluster:

```bash
sudo pcs cluster start --all
```

Desabilitar inicialização automática:

```bash
sudo pcs cluster disable --all
```

---

# Estrutura do Cluster

```text
Node1
├── Nginx
├── Corosync
├── Pacemaker
└── Floating IP

Node2
├── Nginx
├── Corosync
├── Pacemaker
└── Floating IP
```

---

# Observações

- Todos os nós devem utilizar a mesma versão do Pacemaker, Corosync e PCS.
- O usuário `hacluster` deve possuir a mesma senha em todos os nós.
- O STONITH foi desabilitado apenas para ambiente de laboratório. Em produção, recomenda-se configurá-lo adequadamente para evitar situações de split-brain.
- O recurso `floating_ip` é responsável por mover automaticamente o endereço IP entre os nós durante uma falha.
- O Pacemaker monitora continuamente os recursos configurados e realiza o failover automaticamente quando necessário.
```