# OLT — Configuração GPON com PPPoE

Exemplo de configuração de uma **OLT Datacom GPON** para entregar um serviço PPPoE através da VLAN `1000`.

### Topologia lógica

```text
                    OLT Datacom
                        │
                    GPON 1/1/1
                        │
                       ONU
                        │
                  Cliente PPPoE
                        │
                        ▼
                    VLAN 1000
                        │
                        ▼
              Gigabit-Ethernet 1/1/10
                        │
                        ▼
                  Rede PPPoE / BNG
```

---

## 🏷️ Configuração da VLAN

Criar a VLAN `1000` e associá-la à interface de uplink:

```text
dot1q vlan 1000 name PPPoE interface gigabit-ethernet-1/1/10
service vlan 1000 type n:1
commit
```

### O que está sendo configurado?

```text
VLAN 1000
   │
   ├── Nome: PPPoE
   │
   ├── Service VLAN: N:1
   │
   └── Uplink:
       Gigabit-Ethernet 1/1/10
```

A VLAN será utilizada para transportar o tráfego PPPoE entre a ONU e a rede de agregação.

> [!NOTE]
> O `type n:1` permite que múltiplos clientes utilizem o mesmo domínio de serviço, sendo um modelo comum para serviços residenciais.

---

# 🚦 Configuração do Bandwidth Profile

Criar o perfil de largura de banda:

```text
profile gpon bandwidth-profile PPPoE-BW
    traffic type-4 max-bw 1106944
    commit
```

O perfil:

```text
PPPoE-BW
```

será posteriormente associado a um **T-CONT** no Line Profile.

### Relação

```text
Bandwidth Profile
       │
       ▼
     T-CONT
       │
       ▼
      GEM
```

> [!NOTE]
> O `max-bw` é um parâmetro do controle de banda GPON. Não deve ser interpretado simplesmente como a velocidade máxima física da porta Ethernet.

---

# 📡 Configuração do Line Profile

Criar o Line Profile que será utilizado pela ONU:

```text
profile gpon line-profile PPPoE-LP
    tcont 1 bandwidth-profile PPPoE-BW
    gem 1 tcont 1
    map PPPoE ethernet 1 vlan 1000 cos any
```

### Estrutura

```text
PPPoE-LP
   │
   ├── T-CONT 1
   │      │
   │      └── PPPoE-BW
   │
   └── GEM 1
          │
          └── Ethernet 1
                 │
                 └── VLAN 1000
```

### Componentes

| Componente                   | Função                                 |
| ---------------------------- | -------------------------------------- |
| `tcont 1`                    | Controle/alocação de banda no upstream |
| `bandwidth-profile PPPoE-BW` | Define os parâmetros de banda          |
| `gem 1`                      | Canal lógico de transporte GPON        |
| `ethernet 1`                 | Interface Ethernet da ONU              |
| `vlan 1000`                  | VLAN do serviço PPPoE                  |
| `cos any`                    | Aceita qualquer valor de CoS           |

---

# 🔌 Ativação da PON

Ativar a interface GPON:

```text
interface gpon 1/1/1
    no shutdown
    commit
```

A PON `1/1/1` ficará operacional para receber ONUs.

---

# 🔎 Descobrindo ONUs

Depois de ativar a PON, verificar as ONUs detectadas:

```text
do show interface gpon discovered-onus
```

Esse comando permite identificar ONUs que foram detectadas pela OLT e obter informações como o **serial number**, que será utilizado no provisionamento.

---

# 📟 Cadastro da ONU

Exemplo de cadastro:

```text
interface gpon 1/1/1
    onu 0
        serial-number DACM00000525
        line-profile PPPoE-LP

        ethernet 1
            native vlan vlan-id 1000
```

Nesse exemplo:

| Parâmetro     | Valor          |
| ------------- | -------------- |
| PON           | `1/1/1`        |
| ONU ID        | `0`            |
| Serial Number | `DACM00000525` |
| Line Profile  | `PPPoE-LP`     |
| Ethernet      | `1`            |
| VLAN nativa   | `1000`         |

A ONU passa a utilizar o Line Profile criado anteriormente.

---

# 🔗 Configuração do Service Port

Depois de associar a ONU ao perfil, criar o Service Port:

```text
service-port 1 gpon 1/1/1 onu 0 gem 1 match vlan vlan-id 1000 action vlan replace vlan-id 1000
```

### Associação

```text
Service Port 1
      │
      ├── PON: 1/1/1
      ├── ONU: 0
      ├── GEM: 1
      ├── Match VLAN: 1000
      └── Action: Replace VLAN 1000
```

O Service Port estabelece a associação do tráfego entre a **ONU, GEM e VLAN de serviço**.

Depois:

```text
commit
```

> [!WARNING]
> No comando original havia `acation`; o correto é `action`.

---

# 🔄 Fluxo do PPPoE

O caminho lógico do tráfego pode ser representado assim:

```text
┌──────────┐
│ Cliente  │
└────┬─────┘
     │
     │ PPPoE
     ▼
┌──────────┐
│   ONU    │
└────┬─────┘
     │
     │ Ethernet / VLAN 1000
     ▼
┌──────────┐
│ OLT GPON │
└────┬─────┘
     │
     │ GEM 1
     │
     │ Service Port 1
     ▼
┌──────────────────┐
│ VLAN 1000        │
│ Gigabit-Eth 1/1/10│
└────────┬─────────┘
         │
         ▼
    Rede PPPoE/BNG
```

---

# 🔍 Verificando sessões PPPoE

Para verificar o PPPoE Intermediate Agent na interface GPON:

```text
show pppoe intermediate-agent sessions interface gpon 1/1/1
```

Esse comando permite verificar as sessões relacionadas ao **PPPoE Intermediate Agent** na PON.

> [!NOTE]
> No comando original havia `intermadiate-agent`; a grafia correta é `intermediate-agent`.

---

# 🧠 Sequência para memorizar

A configuração segue esta ordem:

```text
1. VLAN
      ↓
2. Service VLAN
      ↓
3. Bandwidth Profile
      ↓
4. Line Profile
      ↓
5. Ativar PON
      ↓
6. Descobrir ONU
      ↓
7. Cadastrar ONU
      ↓
8. Associar Line Profile
      ↓
9. Criar Service Port
      ↓
10. Commit
      ↓
11. Verificar PPPoE
```

---

# 📌 Resumo dos principais elementos

| Elemento          | Exemplo    | Função                        |
| ----------------- | ---------- | ----------------------------- |
| VLAN              | `1000`     | Identificação do serviço      |
| Service VLAN      | `n:1`      | Domínio de serviço            |
| Bandwidth Profile | `PPPoE-BW` | Controle de banda             |
| T-CONT            | `1`        | Alocação de banda GPON        |
| GEM               | `1`        | Transporte lógico GPON        |
| Line Profile      | `PPPoE-LP` | Define T-CONT/GEM/mapeamentos |
| ONU               | `0`        | Identificação da ONU na PON   |
| PON               | `1/1/1`    | Porta GPON                    |
| Service Port      | `1`        | Associação do serviço         |
| Uplink            | `1/1/10`   | Saída para a rede PPPoE       |

## 🧩 Para memorizar

> **VLAN** identifica o serviço → **Bandwidth Profile** define banda → **T-CONT** recebe a política de banda → **GEM** transporta o tráfego → **Line Profile** organiza esses elementos → **ONU** recebe o perfil → **Service Port** amarra o serviço à VLAN.
