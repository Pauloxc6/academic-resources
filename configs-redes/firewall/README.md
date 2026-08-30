# Firewall

O firewall é uma camada muito importante, pois atraves dela podemos proteger nosso sistema de todas direções

---
## UFW (Uncomplicated Firewall) Debain/Ubuntu

Talvez o firewall mais simples e versetil que podemos ter em um ambiente de testes ou produção.
UFW consiste em um firewall simples, através de simples comandos você tenha uma firewall robusto.

---

### 1. Iniciando o Firewall

1. Habilitar/Desabilitar o Firewall:
- **Habilitar:** Ativa o UFW. Se for a primeira vez, é **crucial** permitir o acesso SSH/porta de gerenciamento antes de habilitar, para não perder o acesso.
	
```bash
ufw enable
```

- **Desabilitar:** Desativa o UFW e remove as regras ativas.
```bash
ufw disable
```

2. Verificar o staus:
- Utilize estas variações para obter diferentes níveis de detalhe sobre as regras ativas.

```bash
ufw status          # Mostra uma versão simples
ufw status verbose  # Mostra uma versão mais detalhada
ufw status numbered # Mostra uma versão numerada das regras
```

## 🔒 Boas Práticas e Políticas Padrão (Default)

Antes de habilitar o firewall pela primeira vez, é uma **boa prática de segurança** definir as políticas padrão para o tráfego de entrada e saída, e **permitir o acesso SSH** (porta 22) **imediatamente**.

### 3. Definindo Políticas Padrão

As políticas padrão definem a ação para conexões que não correspondem a nenhuma regra explícita.

- **Negar todo o tráfego de entrada (Incoming):** Esta é a configuração mais segura.

```bash
ufw default deny incoming
```

- **Permitir todo o tráfego de saída (Outgoing):** É comum permitir o tráfego de saída para que o servidor possa se conectar à internet (para atualizações, etc.).

```bash
ufw default allow outgoing
```

---
### 4. Permissão para Gerenciamento Remoto (SSH)

**Esta etapa deve ser feita ANTES de `ufw enable` se estiver em uma conexão remota!**

- **Permitir serviço SSH (porta 22):**
```bash
ufw allow ssh
# ou
ufw allow 22
```

---
## ⚙️ Gerenciamento de Regras: Adicionar e Bloquear

Esta é a parte principal onde você define o que é permitido ou negado.

### 5. Adicionar Regras de Permissão (Allow)

Você pode usar o **nome do serviço** (geralmente definido em `/etc/services`) ou o **número da porta**.

- **Permitir serviço HTTP (Porta 80):**
```bash
ufw allow http
# ou
ufw allow 80
```

- Permitir porta com protocolo e comentário:
```bash
ufw allow 80/tcp comment "ACCEPT | Web Server (HTTP)"
```

Permitir faixa de portas (Ex: 60000-61000/tcp para VoIP):
```bash
ufw allow 60000:61000/tcp comment "VoIP RTP Port Range"
```

### 6. Bloquear Regras (Deny)

- **Bloquear porta DNS (53):**
```bash
ufw deny 53
```

### 7. Regras Avançadas: Especificando Origem/Destino

Para maior segurança, restrinja o acesso a serviços apenas a **endereços IP ou sub-redes** específicas.

- **Permitir SSH (porta 22) apenas do IP `192.168.1.100`:**
```bash
ufw allow from 192.168.1.100 to any port 22 comment "Allow SSH from Admin PC"
```

- Negar tráfego UDP (DNS) da sub-rede `10.1.0.0/24` para o IP `10.1.0.53`:
```bash
ufw deny proto udp from 10.1.0.0/24 to 10.1.0.53 port 53 comment "BLOCK | DNS from internal subnet"
```

- Restringir o acesso a uma interface específica (Ex: `eth0`):
```bash
ufw allow in on eth0 to any port 80 comment "Allow HTTP on external interface"
```

---
## 🗑️ Gerenciamento de Regras: Exclusão (Delete)

Existem duas formas principais de remover regras, sendo a remoção por número de regra a mais comum.

### 8. Excluir Regra por Número

Primeiro, obtenha a lista numerada:
```bash
ufw status numbered
```

Em seguida, exclua a regra pelo índice (Ex: Para excluir a regra de número **1**):
```bash
ufw delete 1
```

### 9. Excluir Regra por Sintaxe Completa

Você pode remover uma regra especificando a **sintaxe exata** que você usou para adicioná-la (sem o comentário, que é opcional).

- **Exemplo de exclusão da regra `ufw allow http`:**
```bash
ufw delete allow http
```

### 10. Defesa Ativa Contra Brute-Force (Rate Limiting) 🚫

Esta é a melhor melhoria que pode fazer no UFW. Em vez de simplesmente abrir uma porta, use a regra `limit` para mitigar ataques de força bruta, como os que vimos no `auth.log`.

O `limit` funciona como um **Rate Limiter** rudimentar: permite 6 conexões por protocolo/IP em 30 segundos e, se exceder esse limite, bloqueia o IP por um período.

 **Exemplo: SSH (Porta 22)**
 ```bash
# Apague a regra allow 22 simples se ela existir
ufw delete allow 22

# Adicione a regra LIMIT
ufw limit 22/tcp comment "MITIGACAO | Brute-Force SSH" 
 ```

- **Resultado:** Se um atacante tentar 7 senhas em 30 segundos, o UFW bloqueia o IP dele.
---
## Firewalld (Red Hat, CentOS, Fedora, AlmaLinux)

O **Firewalld** é o utilitário de gerenciamento de firewall padrão e dinâmico para distribuições baseadas em RHEL (Red Hat Enterprise Linux), como CentOS e Fedora. Ele é mais complexo que o UFW porque utiliza uma arquitetura baseada em **Zonas**, que é o conceito central que você precisa entender.

### Conceito Central: Zonas (Zones)

Em vez de aplicar regras sequenciais como o UFW, o Firewalld associa interfaces de rede a **Zonas**. Cada zona representa um nível de confiança:

- `public`: Para redes públicas (menos confiança).
- `home`/`internal`: Para redes internas (mais confiança).
- `drop`/`block`: Rejeita/descarta todo o tráfego.

### 1. Iniciando e Status do Firewalld

O Firewalld é gerenciado como um serviço do `systemd`.

1. **Habilitar/Iniciar/Parar:**
```bash
sudo systemctl enable firewalld   # Garante que inicia no boot
sudo systemctl start firewalld    # Inicia o serviço
sudo systemctl stop firewalld     # Para o serviço
```

2. Verificar o Status:
```bash
firewall-cmd --state            # Mostra o status (running/not running)
sudo systemctl status firewalld # Status detalhado do serviço
```

---
### 2. Gerenciamento de Regras e Zonas

O Firewalld separa as regras ativas (**Runtime**, temporárias) das regras salvas (**Permanent**, persistentes). **Toda regra que você adicionar deve ter o flag `--permanent` para sobreviver a um reboot.**

1. **Verificar a Zona Padrão e Interfaces:**
```bash
firewall-cmd --get-default-zone         # Mostra a zona atual padrão
firewall-cmd --get-active-zones         # Mostra quais interfaces estão em quais zonas
firewall-cmd --list-all --zone=public   # Lista todas as regras, portas e serviços da zona 'public'
```

2. Adicionar um Serviço Comum (Exemplo: HTTP):
```bash
# 🚨 Regra TEMPORÁRIA (só dura até o reboot)
sudo firewall-cmd --zone=public --add-service=http

# ✅ Regra PERMANENTE (Persiste após o reboot)
sudo firewall-cmd --zone=public --add-service=http --permanent
```

3. Adicionar uma Porta Customizada:
```bash
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
```

4. **Adicionar um Comentário (Via XML):** O Firewalld não tem um campo de comentário direto por linha de comando como o UFW. Você deve criar um **serviço customizado** via ficheiro XML ou adicionar uma regra rica (rich rule).

```bash
# Exemplo de Regra Rica (Rich Rule)
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept' --permanent
```

5. **Aplicar Regras Permanentes:** Após adicionar regras com `--permanent`, você deve recarregar o firewall:
```bash
sudo firewall-cmd --reload
```

6. **Bloquear/Remover uma Porta ou Serviço:** Use o comando `--remove-service` ou `--remove-port` seguido de `--permanent` e depois `--reload`.
```bash
sudo firewall-cmd --zone=public --remove-service=http --permanent
sudo firewall-cmd --reload
```

---
### 3. Boas Práticas de Segurança

1. **Zona Padrão Restritiva:** Assim como o UFW, a boa prática é definir a política padrão como restritiva. A zona `drop` descarta o tráfego sem resposta.
```bash
firewall-cmd --set-default-zone=drop
```

2. **Manter a Zona Ativa:** Sempre atribua suas interfaces de rede à zona correta (por exemplo, `eth0` na zona `public`).
```bash
sudo firewall-cmd --zone=public --change-interface=eth0 --permanent
```

---
## 🧱 IPTables: O Firewall Nível Kernel

O `iptables` opera através de **tabelas** (tables), que contêm **cadeias** (chains), que por sua vez contêm **regras** (rules).

- **Tabelas Principais:**
    
    - `filter` (Padrão): Usada para filtrar pacotes (o que o UFW faz primariamente).
    - `nat`: Usada para tradução de endereços de rede (Network Address Translation - NAT).
    - `mangle`: Usada para modificar cabeçalhos de pacotes.
        
- **Cadeias (Chains) Principais na tabela `filter`:**
    
    - **INPUT:** Pacotes **destinados** ao próprio servidor.
    - **OUTPUT:** Pacotes **originados** pelo próprio servidor.
    - **FORWARD:** Pacotes que **atravessam** o servidor (usado em roteadores ou gateways).
        
- **Alvos (Targets) de Ação:**
    
    - **ACCEPT:** Deixa o pacote passar.
    - **DROP:** Descarta o pacote **silenciosamente** (sem notificação).
    - **REJECT:** Descarta o pacote e envia uma mensagem de erro ao remetente.

---
## 🛠️ Comandos IPTables Essenciais

A sintaxe básica é: `iptables -t <tabela> -A <cadeia> <parâmetros de correspondência> -j <alvo>`

### 1. Visualizar Regras

Use a opção `-L` (List) para ver as regras e `-v` (Verbose) para detalhes (contadores de pacotes/bytes) e `-n` (Numeric) para evitar a resolução de nomes de host/serviços.

```bash
# Lista todas as regras na tabela 'filter' (padrão)
sudo iptables -L -v -n
```

### 2. Limpar e Redefinir

É crucial saber como limpar as regras para evitar problemas de conectividade.

- **Zerar contadores** de pacotes/bytes:
```bash
sudo iptables -Z
```

- **Excluir TODAS as regras** de todas as cadeias (Flush):
```bash
sudo iptables -F
```

### 3. Definir Política Padrão (Policy)

A política padrão é o que acontece com um pacote que **não corresponde** a nenhuma regra. Por segurança, o ideal é **DROP** para INPUT e FORWARD, e **ACCEPT** para OUTPUT.

```bash
# Define o padrão para a cadeia INPUT como DROP
sudo iptables -P INPUT DROP
# Define o padrão para a cadeia FORWARD como DROP
sudo iptables -P FORWARD DROP
# Define o padrão para a cadeia OUTPUT como ACCEPT
sudo iptables -P OUTPUT ACCEPT
```

### 4. Adicionar Regras (Allow/Deny)

Use `-A` para **adicionar** no **final** da cadeia ou `-I` para **inserir** em uma posição específica.

- **Permitir tráfego SSH (Porta 22/TCP):**
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

- Permitir tráfego HTTP (Porta 80/TCP):
```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

- Permitir conexões estabelecidas/relacionadas (ESSENCIAL):
```bash
# Permite pacotes pertencentes a conexões já iniciadas (evita que conexões ativas sejam derrubadas)
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

- Bloquear um IP específico na entrada:
```bash
sudo iptables -A INPUT -s 192.168.1.10 -j DROP
```

### 5. Excluir Regras

A exclusão pode ser feita de duas formas:

- **Por Número:** Liste as regras numeradas com `--line-numbers` e use a opção `-D`.
```bash
sudo iptables -L --line-numbers  # 1. Obter o número da linha (Ex: 3)
sudo iptables -D INPUT 3         # 2. Excluir a regra 3 da cadeia INPUT
```

- **Por Sintaxe Completa:** Repita o comando de adição, mas substitua `-A` por `-D`.
```bash
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT
```

### 6. Redirecionamento com REDIRECT e DSTNAT

O redirecionamento pode ser feito de duas maneiras diferentes a primeira através do -j REDIRECT que permite fazer um redirecionamento de portas para o host local. O -j DSTNAT permite fazer um redirecionamento para outro host na mesma e outra rede, atuando como reverse proxy.

**REDIRECT**:

```bash
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-ports 8080
```

**DSTNAT:**

```bash
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to 10.1.0.101:8080
```

---
## 💾 Persistência das Regras

As regras do `iptables` definidas na linha de comando **não são persistentes** por padrão, o que significa que **serão perdidas após a reinicialização**.

No Debian/Ubuntu, você deve instalar um pacote para gerenciar a persistência:
```bash
# Para salvar as regras atuais
sudo apt install iptables-persistent
# O comando de salvar regras (caso precise salvar após alterações manuais)
sudo netfilter-persistent save
```