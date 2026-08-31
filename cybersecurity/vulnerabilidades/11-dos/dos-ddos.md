# 🌐 DDoS — Distributed Denial of Service

### 🧠 O que é um ataque DDoS?

**DDoS (Distributed Denial of Service)** é um ataque cujo objetivo é **sobrecarregar um serviço, servidor, aplicação ou rede com uma grande quantidade de requisições ou tráfego**, impedindo que usuários legítimos consigam utilizá-lo normalmente.

Em um DDoS, o tráfego geralmente vem de **múltiplos dispositivos**, frequentemente integrantes de uma **botnet**.

> **DoS:** geralmente utiliza uma ou poucas origens.  
> **DDoS:** utiliza diversas origens distribuídas.

---

## ⚙️ Como funciona

O atacante primeiro compromete diversos dispositivos, como:

```text
Computadores
Servidores
Roteadores
Dispositivos IoT
Smartphones
```

Esses dispositivos podem formar uma **botnet**:

```text
                 ┌── Bot 1
                 │
Atacante ────────┼── Bot 2 ──────┐
                 │                │
                 ├── Bot 3 ───────┼──> Servidor alvo
                 │                │
                 └── Bot 4 ──────┘
```

Cada dispositivo envia tráfego para o alvo, fazendo com que os recursos disponíveis sejam consumidos.

---

## 💥 O que pode ser afetado?

Um ataque pode atingir diferentes camadas:

```text
🌐 Rede
   ↓
🔥 Firewall
   ↓
⚖️ Load Balancer
   ↓
🖥️ Servidor Web
   ↓
⚙️ Aplicação
   ↓
🗄️ Banco de dados
```

O resultado pode ser:

- indisponibilidade do serviço;
- aumento de latência; 
- consumo excessivo de CPU;
- consumo de memória;
- saturação de banda;
- esgotamento de conexões;
- indisponibilidade de aplicações e APIs.

---

# 📚 Principais tipos

|Método|Alvo|Descrição|
|---|---|---|
|**SYN Flood**|IP:PORT|Explora o processo de estabelecimento de conexões TCP|
|**UDP Flood**|IP:PORT|Envia grande quantidade de pacotes UDP|
|**ICMP Flood**|IP|Sobrecarrega o alvo com requisições ICMP|
|**HTTP Flood**|URL|Envia grande quantidade de requisições HTTP|
|**Slowloris**|IP:PORT|Mantém diversas conexões HTTP abertas por longos períodos|
|**NTP Amplification**|IP|Utiliza servidores NTP para amplificar tráfego|
|**Memcached Amplification**|IP|Explora servidores Memcached expostos para amplificação|
|**Ping of Death**|IP|Utiliza pacotes ICMP malformados ou excessivamente grandes|
|**SMS Flood**|Telefone|Envia grande quantidade de mensagens para um número|
|**E-mail Flood**|E-mail|Envia grande quantidade de mensagens para uma caixa postal|

---

## 🔀 DoS × DDoS

### DoS

```text
Atacante
   │
   ├───────────────► Alvo
```

Uma origem gera o ataque.

### DDoS

```text
             ┌──► Bot 1 ──┐
             ├──► Bot 2 ──┤
Atacante ────┼──► Bot 3 ──┼──► Alvo
             ├──► Bot 4 ──┤
             └──► Bot 5 ──┘
```

Múltiplas origens dificultam a filtragem baseada apenas no endereço IP.

---

# 🧪 Exemplos em laboratório

> ⚠️ Execute ferramentas de geração de tráfego **somente contra máquinas, redes ou ambientes de laboratório que você controla ou tem autorização explícita para testar**.

### hping3

Exemplo de geração de tráfego para um laboratório:

```bash
sudo hping3 -S -V -p 80 192.168.4.1 -c 10000 -I enp3s0
```

O `-c 10000` limita a quantidade de pacotes enviados.

---

### Slowloris

```bash
perl slowloris.pl -dns www.example.com
```

Em laboratório, substitua pelo domínio/IP do ambiente autorizado.

---

### GoldenEye

```bash
./goldeneye.py -w 10 -s 500 -m get
```

---

### Fork Bomb

A **fork bomb** é diferente de um DDoS de rede. Ela provoca **exaustão de processos/recursos localmente**:

```bash
:(){ :|: & };:
```

⚠️ **Não execute isso em uma máquina que você não possa reiniciar ou recuperar.**

---

# 🔎 Como visualizar o tráfego

Uma maneira simples de observar pacotes ICMP com `tcpdump`:

```bash
sudo tcpdump -i enp3s0 icmp -n
```

Filtrando origem e destino:

```bash
sudo tcpdump \
-i enp3s0 \
src 192.168.4.134 \
and dst 192.168.4.1 \
and icmp -n
```

Você poderá observar algo semelhante a:

```text
IP 192.168.4.134 > 192.168.4.1: ICMP echo request
IP 192.168.4.134 > 192.168.4.1: ICMP echo request
IP 192.168.4.134 > 192.168.4.1: ICMP echo request
```

---

# 🛡️ Como se proteger

Algumas medidas comuns:

- Rate limiting;
- Firewall e ACLs;
- CDN e proteção anti-DDoS;
- Load balancing;
- Filtragem de tráfego;
- Anycast;
- Limitação de conexões;
- Monitoramento de tráfego;
- Proteção contra amplificação;
- Configuração adequada de servidores DNS/NTP/Memcached;
- Detecção de padrões anormais.

Em aplicações HTTP, também é importante implementar **rate limiting por IP, usuário, sessão ou API key**, dependendo do cenário.

---

## 🎯 Resumo

```text
DDoS
 │
 ├── Múltiplas origens
 │
 ├── Grande volume de tráfego/requisições
 │
 ├── Consumo de recursos
 │
 └──► Indisponibilidade do serviço
```

**Ideia principal:**

> **DDoS não busca necessariamente invadir o servidor; o objetivo principal é impedir que ele consiga atender usuários legítimos.**