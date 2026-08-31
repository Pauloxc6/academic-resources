# 🛡️ Como Desabilitar o IPv6 via sysctl (Método Recomendado)

#blueteam #estudos #linux #soc #ipv6
**Data:** 2025-11-21

---

O **sysctl** é a ferramenta do Linux usada para modificar os parâmetros do kernel em tempo de execução. O arquivo de configuração principal é o `/etc/sysctl.conf`.

---
### Passo 1: Edite o Arquivo de Configuração

Abra o arquivo de configuração do sysctl com seu editor preferido (ex: `vi` ou `nano`):

```bash
sudo nano /etc/sysctl.conf
```

### Passo 2: Adicione as Diretivas de Desativação

Adicione as seguintes três linhas no **final** do arquivo. Elas instruem o kernel a ignorar o IPv6 em todas as interfaces de rede.

```bash
# Desabilitar completamente o IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

### Passo 3: Aplique as Alterações

Para que as alterações entrem em vigor sem a necessidade de reiniciar o sistema, execute o comando:

```bash
sudo sysctl -p
```

O comando `sysctl -p` forçará o carregamento imediato do arquivo `/etc/sysctl.conf`.

---

## 2. Como Verificar se o IPv6 Está Desabilitado

Após aplicar as configurações, você pode verificar o estado do IPv6.

### Verificação 1: Status do sysctl

Verifique se o kernel carregou o valor `1` (desativado) para o parâmetro principal:

```bash
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```

**Resultado esperado:** `1`

### Verificação 2: Endereços de Rede

Use o comando `ip a` (ou `ip address`) para listar as interfaces. Se o IPv6 estiver desabilitado, você não verá mais nenhuma linha com **inet6** (que é o endereço IPv6).

**Exemplo de saída (Após desabilitar):**

```bash
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:1c:1d:9a brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.50/24 brd 192.168.1.255 scope global eth0
    # A linha inet6 (IPv6) não está mais aqui
```

