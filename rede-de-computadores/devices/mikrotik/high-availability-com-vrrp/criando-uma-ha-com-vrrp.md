# criando-uma-ha-com-vrrp

# 🔄 VRRP (Virtual Router Redundancy Protocol)

O **VRRP (Virtual Router Redundancy Protocol)** é um protocolo utilizado para fornecer **redundância de gateway**.

A ideia é utilizar dois ou mais roteadores para formar um **roteador virtual**, permitindo que os clientes continuem utilizando o mesmo gateway caso o roteador principal apresente uma falha.

---

# 🗺️ Topologia

```text
                         ISP1
                       /      \
                      /        \
                     /          \
        192.168.0.16/24          \192.168.0.24/24
                   /              \
                ┌─────┐          ┌─────┐
                │ R1  │          │ R2  │
                │MASTER│         │BACKUP│
                └──┬──┘          └──┬──┘
                   │                │
                   └───────┬────────┘
                           │
                    VRRP Virtual IP
                    192.168.0.254/24
                           │
                       Gateway
```

Temos:

| Equipamento | IP real            | Função     |
| ----------- | ------------------ | ---------- |
| R1          | `192.168.0.16/24`  | Master     |
| R2          | `192.168.0.24/24`  | Backup     |
| VRRP        | `192.168.0.254/24` | IP virtual |

Os clientes utilizam:

```text
Gateway = 192.168.0.254
```

Eles não precisam saber se o tráfego está sendo encaminhado pelo R1 ou pelo R2.

---

# 🖥️ R1 — Master

Criamos a interface VRRP:

```bash
/interface vrrp
add name=vrrp1 \
    interface=ether1 \
    vrid=49 \
    priority=200 \
    authentication=none \
    preemption-mode=yes \
    interval=1s
```

Depois configuramos o IP virtual:

```bash
/ip address
add address=192.168.0.254/24 \
    interface=vrrp1 \
    comment="VRRP Network"
```

---

# 🖥️ R2 — Backup

No R2:

```bash
/interface vrrp
add name=vrrp2 \
    interface=ether1 \
    vrid=49 \
    priority=100 \
    authentication=none \
    preemption-mode=yes \
    interval=1s
```

E configuramos o mesmo IP virtual:

```bash
/ip address
add address=192.168.0.254/24 \
    interface=vrrp2 \
    comment="VRRP Network"
```

⚠️ O endereço `192.168.0.254` é propositalmente igual nos dois roteadores porque é o **IP virtual VRRP**. Não devemos configurar esse endereço diretamente na `ether1` de ambos.

---

# 🏆 Eleição do Master

O VRRP utiliza uma **prioridade** para determinar qual roteador será o Master.

No R1:

```text
priority=200
```

No R2:

```text
priority=100
```

Como:

```text
200 > 100
```

o R1 será eleito como **Master**.

```text
R1
priority 200
    │
    ▼
 MASTER
```

```text
R2
priority 100
    │
    ▼
 BACKUP
```

---

# 🔄 Funcionamento do Failover

Enquanto o R1 estiver funcionando:

```text
                  VRRP
                   │
             Virtual IP
           192.168.0.254
                   │
              ┌────┴────┐
              │         │
          R1 MASTER   R2 BACKUP
           200          100
              │
              ▼
          Encaminha
```

Se o R1 falhar:

```text
             R1
             ❌
             │
             │
             ▼
       R2 assume
       o Virtual IP
             │
             ▼
          MASTER
```

O gateway dos clientes continua sendo:

```text
192.168.0.254
```

Portanto, não é necessário alterar a configuração dos clientes.

---

# ⏱️ `interval=1s`

```text
interval=1s
```

Define o intervalo utilizado para os anúncios VRRP.

Conceitualmente:

```text
R1 ── Advertisement ──► R2
    1 segundo depois
R1 ── Advertisement ──► R2
    1 segundo depois
R1 ── Advertisement ──► R2
```

Se o Backup deixar de receber os anúncios dentro do período esperado, ele poderá assumir a função de Master conforme as regras do protocolo.

---

# 🔢 `vrid=49`

```text
vrid=49
```

O **VRID (Virtual Router Identifier)** identifica o grupo VRRP.

Os roteadores que participam do mesmo grupo precisam utilizar o mesmo VRID.

Neste laboratório:

```text
R1 → VRID 49
R2 → VRID 49
```

Isso permite que os dois participem do mesmo grupo virtual.

Outro grupo poderia utilizar outro VRID:

```text
VRID 49 → Grupo A
VRID 50 → Grupo B
```

---

# 🏅 `priority`

```text
R1 → priority=200
R2 → priority=100
```

Quanto maior a prioridade, maior a preferência para se tornar Master.

```text
Prioridade

200 ─────► R1
             │
             ▼
          MASTER

100 ─────► R2
             │
             ▼
          BACKUP
```

---

# 🔙 `preemption-mode=yes`

```text
preemption-mode=yes
```

Permite que o roteador com maior prioridade volte a assumir o papel de Master quando retornar à operação.

Exemplo:

```text
R1 = 200
R2 = 100
```

Inicialmente:

```text
R1 → MASTER
R2 → BACKUP
```

R1 falha:

```text
R1 → DOWN
R2 → MASTER
```

R1 retorna:

```text
R1 → 200
R2 → 100
```

Com preempção habilitada:

```text
R1 → MASTER
R2 → BACKUP
```

---

# 🔐 `authentication=none`

```text
authentication=none
```

Indica que não está sendo utilizada autenticação VRRP nessa configuração.

```text
VRRP
 │
 └── authentication=none
```

Em ambientes reais, a segurança deve ser analisada considerando a versão do VRRP, a plataforma e os mecanismos disponíveis.

---

# 🌐 IP virtual

O grande benefício do VRRP é o **Virtual IP**:

```text
192.168.0.254/24
```

Os clientes podem simplesmente utilizar:

```text
Gateway:
192.168.0.254
```

Sem VRRP:

```text
Cliente
   │
   ├── Gateway R1
   │
   └── Se R1 falhar → problema
```

Com VRRP:

```text
Cliente
   │
   ▼
192.168.0.254
   │
   ├── R1 MASTER
   │
   └── R2 BACKUP
```

---

# 🧠 VRRP não é balanceamento

É importante não confundir **VRRP** com mecanismos de load balancing.

VRRP fornece principalmente:

```text
REDUNDÂNCIA
     +
ALTA DISPONIBILIDADE
```

Não significa:

```text
50% do tráfego → R1
50% do tráfego → R2
```

Normalmente existe:

```text
R1 → MASTER
R2 → BACKUP
```

A função do R2 é assumir quando o Master não estiver disponível.

---

# 🧪 Testando o failover

Podemos testar a comunicação com o IP virtual:

```bash
/ping 192.168.0.254
```

Depois podemos verificar o estado das interfaces VRRP:

```bash
/interface vrrp print
```

Durante o funcionamento normal:

```text
R1 → MASTER
R2 → BACKUP
```

Ao desligar ou interromper o R1:

```text
R1 → DOWN
R2 → MASTER
```

Quando R1 retornar:

```text
R1 → MASTER
R2 → BACKUP
```

considerando `preemption-mode=yes`.

---

# 🔄 Fluxo completo

```text
                    VRRP GROUP
                     VRID 49
                        │
              ┌─────────┴─────────┐
              │                   │
              ▼                   ▼
           R1                      R2
       Priority 200           Priority 100
          MASTER                 BACKUP
              │                   │
              └─────────┬─────────┘
                        │
                        ▼
                 192.168.0.254
                   Virtual IP
                        │
                        ▼
                     Clientes
```

Falha:

```text
             R1 ❌
               │
               ▼
        R2 assume MASTER
               │
               ▼
        192.168.0.254
               │
               ▼
           Clientes
```

---

# 🧠 Para memorizar

```text
VRRP
 ↓
Redundância de gateway
```

```text
VRID
 ↓
Identifica o grupo VRRP
```

```text
Priority
 ↓
Define preferência para MASTER
```

```text
Virtual IP
 ↓
Gateway utilizado pelos clientes
```

```text
Preemption
 ↓
Permite ao roteador de maior prioridade
retomar o MASTER quando voltar
```

### Resumo

```text
R1
192.168.0.16
Priority 200
     ↓
  MASTER
     │
     │
     ▼
Virtual IP
192.168.0.254
     ▲
     │
     │
  BACKUP
     ↑
Priority 100
192.168.0.24
R2
```

**Ideia principal:** os clientes enxergam apenas `192.168.0.254` como gateway. O VRRP decide qual roteador será responsável por esse endereço virtual naquele momento.
