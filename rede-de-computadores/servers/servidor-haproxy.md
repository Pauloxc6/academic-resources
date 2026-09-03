# Balanceamento de Carga com HAProxy

Este guia apresenta a instalação e configuração do **HAProxy** para realizar balanceamento de carga entre múltiplos servidores Web.

---

# Topologia

```text
                     Clientes
                         │
                         │
                  192.168.10.20
                         │
                +----------------+
                |    HAProxy     |
                |   Porta :80    |
                +-------+--------+
                        │
          ┌─────────────┴─────────────┐
          │                           │
 +-------------------+       +-------------------+
 |    Web Server 1   |       |    Web Server 2   |
 | 127.0.0.1:8001    |       | 127.0.0.1:8002    |
 +-------------------+       +-------------------+
```

---

# Instalação

Atualize os repositórios:

```bash
sudo apt update
```

Instale o HAProxy:

```bash
sudo apt install haproxy -y
```

Verifique se o serviço foi instalado corretamente:

```bash
sudo systemctl status haproxy
```

---

# Arquivo de Configuração

Edite o arquivo principal:

```bash
sudo nano /etc/haproxy/haproxy.cfg
```

---

# Estrutura do HAProxy

O arquivo de configuração é dividido em diferentes seções.

## global

Contém configurações globais do HAProxy.

Exemplos:

- Logs
- Socket administrativo
- Usuário e grupo
- SSL
- Número máximo de conexões

Existe apenas uma seção **global**.

---

## defaults

Define configurações padrão para todas as seções seguintes.

Exemplos:

- Modo HTTP ou TCP
- Timeouts
- Retries
- Opções padrão

É possível possuir múltiplas seções **defaults**.

---

## frontend

Representa a entrada das conexões.

Nele são definidos:

- IP
- Porta
- ACLs
- Regras de roteamento
- Backend padrão

---

## backend

Define o conjunto de servidores responsáveis por atender às requisições.

Também define o algoritmo de balanceamento.

Alguns algoritmos disponíveis:

- roundrobin
- leastconn
- source
- uri
- hdr

---

## listen

Combina as funções de **frontend** e **backend** em uma única seção.

É normalmente utilizada para pequenas configurações ou páginas administrativas.

---

# Exemplo de Configuração

```cfg
global
    stats socket /run/haproxy/admin.sock mode 660 level admin

defaults
    mode http

    timeout client 10s
    timeout connect 5s
    timeout server 10s
    timeout http-request 10s

frontend my_frontend

    bind 127.0.0.1:80
    default_backend my_backend

backend my_backend

    balance leastconn
    server server1 127.0.0.1:8001
    server server2 127.0.0.1:8002

listen stats

    bind :8000
    stats enable
    stats uri /monitoring
    stats auth username:password
```

---

# Explicação da Configuração

## global

```cfg
stats socket /run/haproxy/admin.sock mode 660 level admin
```

Cria um socket administrativo para gerenciamento do HAProxy.

---

## defaults

```cfg
mode http
```

Utiliza o protocolo HTTP.

---

```cfg
timeout client 10s
```

Tempo máximo aguardando dados do cliente.

---

```cfg
timeout connect 5s
```

Tempo máximo para conectar ao backend.

---

```cfg
timeout server 10s
```

Tempo máximo aguardando resposta do servidor.

---

```cfg
timeout http-request 10s
```

Tempo máximo para receber uma requisição HTTP.

---

## frontend

```cfg
bind 127.0.0.1:80
```

Define o endereço e porta onde o HAProxy irá escutar.

---

```cfg
default_backend my_backend
```

Todas as conexões serão encaminhadas para o backend **my_backend**.

---

## backend

```cfg
balance leastconn
```

Utiliza o algoritmo **Least Connections**, enviando novas conexões ao servidor menos ocupado.

---

```cfg
server server1 127.0.0.1:8001
```

Primeiro servidor.

---

```cfg
server server2 127.0.0.1:8002
```

Segundo servidor.

---

## listen

```cfg
bind :8000
```

Interface Web administrativa.

---

```cfg
stats enable
```

Habilita estatísticas.

---

```cfg
stats uri /monitoring
```

URL de acesso.

Exemplo:

```
http://IP_DO_SERVIDOR:8000/monitoring
```

---

```cfg
stats auth username:password
```

Usuário e senha para acessar a página de monitoramento.

---

# Reiniciando o Serviço

```bash
sudo systemctl restart haproxy
```

Verifique o status:

```bash
sudo systemctl status haproxy
```

---

# Testando

Acesse utilizando o navegador:

```
http://127.0.0.1
```

Ou utilize:

```bash
curl http://127.0.0.1
```

Para visualizar o painel administrativo:

```
http://127.0.0.1:8000/monitoring
```

---

# Comandos Úteis

Iniciar:

```bash
sudo systemctl start haproxy
```

Parar:

```bash
sudo systemctl stop haproxy
```

Reiniciar:

```bash
sudo systemctl restart haproxy
```

Status:

```bash
sudo systemctl status haproxy
```

Habilitar na inicialização:

```bash
sudo systemctl enable haproxy
```

Validar a configuração:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

Logs:

```bash
sudo journalctl -u haproxy
```

Monitorar logs:

```bash
sudo journalctl -fu haproxy
```

---

# Estrutura dos Arquivos

```text
/etc/haproxy/
├── haproxy.cfg
└── errors/
```

---

# Algoritmos de Balanceamento

| Algoritmo | Descrição |
|-----------|-----------|
| roundrobin | Distribui igualmente entre os servidores |
| leastconn | Envia para o servidor com menos conexões |
| source | Baseado no endereço IP do cliente |
| uri | Baseado na URI requisitada |
| hdr | Baseado em um cabeçalho HTTP |

---

# Observações

- Sempre valide a configuração utilizando:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

antes de reiniciar o serviço.

- O algoritmo **leastconn** é recomendado para aplicações com conexões de longa duração.
- Utilize o painel de estatísticas para acompanhar conexões, servidores ativos e desempenho em tempo real.
- Em ambientes de produção, recomenda-se utilizar HTTPS, certificados TLS e realizar verificações de saúde (*health checks*) nos servidores backend.