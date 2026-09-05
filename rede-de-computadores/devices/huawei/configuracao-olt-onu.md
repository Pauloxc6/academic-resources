# Huawei OLT — Configuração de ONU

Roteiro básico para configuração de uma **OLT Huawei GPON** e cadastro de ONUs em modo Bridge.

---

# 🏷️ 1. Criando VLAN de Gerência

Criar a VLAN:

```text
vlan 100 smart
 port vlan 100 0/3/0
```

Criar a interface VLANIF:

```text
interface vlanif 100
 ip address 100.127.252.18 255.255.255.252
```

Aplicar:

```text
board confirm 0
```

### Estrutura

```text
                 OLT
                  │
             VLAN 100
                  │
               VLANIF
                  │
          100.127.252.18/30
                  │
                  ▼
             Gerência
```

> [!NOTE]
> A VLAN de gerência é utilizada para permitir a comunicação administrativa com a OLT. A porta `0/3/0` precisa estar corretamente conectada/configurada na rede de gerenciamento.

---

# 🚦 2. Criando DBA Profile

O **DBA Profile (Dynamic Bandwidth Assignment)** define parâmetros de alocação dinâmica de banda para o upstream GPON.

```text
dba-profile add profile-id 500 profile-name "GPON" type4 max 1024000
```

Neste exemplo:

| Parâmetro  | Valor     |
| ---------- | --------- |
| Profile ID | `500`     |
| Nome       | `GPON`    |
| Tipo       | `Type 4`  |
| Máximo     | `1024000` |

### Fluxo

```text
DBA Profile
     │
     ▼
   T-CONT
     │
     ▼
   GEM Port
     │
     ▼
    ONU
```

> [!NOTE]
> O significado exato dos valores de banda depende da unidade utilizada pela versão do VRP. Não trate `1024000` como Mbps sem confirmar a unidade da plataforma.

---

# 🔧 3. Criando Service Profile

O **ONT Service Profile** define características relacionadas às portas e aos serviços da ONU.

```text
ont-srvprofile gpon profile-id 500 profile-name "GPON"
 ont-port ports adaptive 32 eth adaptive 8
 ports vlan eth 1 translation 100 user-vlan 100
```

### Configuração

```text
ont-port ports adaptive 32 eth adaptive 8
```

Define a capacidade/quantidade de portas da ONU conforme o perfil.

```text
ports vlan eth 1 translation 100 user-vlan 100
```

Define o tratamento da VLAN na porta Ethernet `1`.

### Conceito

```text
                 Service Profile
                       │
             ┌─────────┴─────────┐
             │                   │
       Portas da ONU       Regras de VLAN
```

---

# 📡 4. Criando Line Profile

O **ONT Line Profile** define como o tráfego será transportado pela rede GPON, incluindo **T-CONT, GEM e mapeamentos**.

```text
ont-lineprofile gpon profile-id 500 profile-name "GPON"
 tcont 4 dba-profile-id 500
 gem add 37 eth tcont 4
 gem mapping 37 0 eth vlan 100
```

### T-CONT

```text
tcont 4 dba-profile-id 500
```

Cria o T-CONT `4` e associa o DBA Profile `500`.

```text
DBA Profile 500
      │
      ▼
   T-CONT 4
```

### GEM

```text
gem add 37 eth tcont 4
```

Cria a **GEM Port 37** associada ao T-CONT `4`.

```text
T-CONT 4
    │
    ▼
GEM Port 37
```

### GEM Mapping

```text
gem mapping 37 0 eth vlan 100
```

Associa o tráfego da GEM Port `37` à VLAN `100`.

### Fluxo completo

```text
VLAN 100
   │
   ▼
GEM Port 37
   │
   ▼
T-CONT 4
   │
   ▼
DBA Profile 500
   │
   ▼
GPON
```

---

# 🟢 5. Ativando as portas PON

Entrar na interface GPON:

```text
interface gpon 0/1
```

Habilitar o **Auto-Find** das ONUs:

```text
port 0 ont-auto-find enable
port 1 ont-auto-find enable
port 2 ont-auto-find enable
port 3 ont-auto-find enable
port 4 ont-auto-find enable
port 5 ont-auto-find enable
port 6 ont-auto-find enable
port 7 ont-auto-find enable
port 8 ont-auto-find enable
port 9 ont-auto-find enable
port 10 ont-auto-find enable
port 11 ont-auto-find enable
port 12 ont-auto-find enable
port 13 ont-auto-find enable
port 14 ont-auto-find enable
port 15 ont-auto-find enable
```

Nesse exemplo, o Auto-Find está habilitado nas portas PON:

```text
0 → 15
```

### Auto-Find

O Auto-Find permite que a OLT detecte ONUs conectadas à PON e obtenha informações necessárias para o provisionamento, como o **serial number**.

---

# 📟 6. Cadastrando a ONU

Este exemplo considera uma ONU em **modo Bridge**.

Primeiro, utilizar o Auto-Find para descobrir a ONU:

```text
display ont autofind all
```

Depois, cadastrar a ONU utilizando o serial number:

```text
interface gpon 0/1

ont add 0 sn-auth <serial-number> omci \
 ont-lineprofile-id 500 \
 ont-srvprofile-id 500 \
 desc ""
```

Exemplo:

```text
ont add 0 sn-auth HWTC12345678 omci \
 ont-lineprofile-id 500 \
 ont-srvprofile-id 500 \
 desc "Cliente-01"
```

### Associação

```text
ONU
 │
 ├── Serial Number
 │
 ├── Line Profile → 500
 │
 └── Service Profile → 500
```

---

# 🔌 VLAN nativa da ONU

Depois de cadastrar a ONU:

```text
ont port native-vlan 0 0 eth 1 vlan 100 priority 0
```

Nesse exemplo:

| Parâmetro      | Valor |
| -------------- | ----- |
| PON            | `0/1` |
| ONU ID         | `0`   |
| Porta Ethernet | `1`   |
| VLAN           | `100` |
| Priority       | `0`   |

A VLAN `100` será utilizada como VLAN nativa da porta Ethernet da ONU.

---

# 🔗 7. Criando o Service Port

O **Service Port** associa a ONU/GEM ao serviço VLAN.

```text
service-port 1 vlan 100 gpon 0/1/0 ont 0 gemport 37 multi-service user-vlan 100 tag-transform translate
```

### Estrutura

```text
Service Port 1
      │
      ├── VLAN: 100
      ├── PON: 0/1/0
      ├── ONU: 0
      ├── GEM: 37
      ├── User VLAN: 100
      └── Transform: translate
```

### Fluxo

```text
                 OLT
                  │
             GPON 0/1/0
                  │
                ONU 0
                  │
               GEM 37
                  │
                  ▼
             VLAN 100
                  │
                  ▼
             Service Port
                  │
                  ▼
             Rede Ethernet
```

---

# 💾 8. Salvando a configuração

Após finalizar a configuração:

```text
save
```

Isso salva a configuração para que ela permaneça após uma reinicialização.

> [!IMPORTANT]
> Em equipamentos Huawei, é importante diferenciar a configuração **em execução** da configuração **salva**. Alterar uma configuração não significa necessariamente que ela ficará persistente após reboot.

---

# 🗑️ Excluindo uma ONU

Para remover uma ONU:

```text
ont delete 1 0
```

Os números representam a posição/identificação da ONU conforme o contexto do equipamento.

> [!WARNING]
> Antes de remover uma ONU, confirme o `frame/slot/port` e o `ONT ID`. Uma remoção incorreta pode afetar outro assinante.

---

# 🔎 9. Comandos de verificação

## Ver configuração atual

```text
display current-configuration
```

Exibe a configuração atualmente carregada.

---

## Ver ONUs detectadas pelo Auto-Find

```text
display ont autofind all
```

Útil para descobrir ONUs que estão conectadas à PON, mas ainda não foram cadastradas.

---

## Resumo das ONUs

```text
display ont info summary 0
```

Exibe um resumo das ONUs relacionadas ao contexto especificado.

---

# 🧠 Conceitos principais

## DBA Profile

Controla parâmetros de **alocação dinâmica de banda**.

```text
DBA Profile
     ↓
T-CONT
```

---

## T-CONT

É utilizado para controlar/alocar recursos de banda no **upstream GPON**.

```text
T-CONT 4
    │
    ▼
DBA Profile 500
```

---

## GEM Port

É o canal lógico utilizado para transportar os dados dentro da rede GPON.

```text
GEM 37
   │
   ▼
T-CONT 4
```

---

## Line Profile

Define a estrutura de transporte da ONU:

```text
Line Profile
     │
     ├── T-CONT
     │
     ├── GEM
     │
     └── GEM Mapping
```

---

## Service Profile

Define características de portas e serviços da ONU:

```text
Service Profile
       │
       ├── Portas
       ├── Ethernet
       └── VLAN
```

---

## Service Port

Faz a associação do serviço entre:

```text
ONU
 │
 ▼
GEM
 │
 ▼
VLAN
 │
 ▼
Rede de serviço
```

---

# 🔄 Fluxo completo da configuração

```text
                  OLT
                   │
                   │
             ┌─────┴─────┐
             │   GPON    │
             └─────┬─────┘
                   │
                ONU 0
                   │
          ┌────────┴────────┐
          │                 │
   Service Profile    Line Profile
       500                  500
                           │
                    ┌──────┴──────┐
                    │             │
                 T-CONT 4      GEM 37
                    │             │
                    └──────┬──────┘
                           │
                       VLAN 100
                           │
                           ▼
                     Service Port 1
                           │
                           ▼
                       Uplink/Rede
```

---

# 📋 Ordem para memorizar

```text
1. Criar VLAN
       ↓
2. Criar DBA Profile
       ↓
3. Criar Service Profile
       ↓
4. Criar Line Profile
       ↓
5. Habilitar Auto-Find
       ↓
6. Descobrir ONU
       ↓
7. Cadastrar ONU
       ↓
8. Associar Line Profile
       ↓
9. Associar Service Profile
       ↓
10. Configurar VLAN da ONU
       ↓
11. Criar Service Port
       ↓
12. save
       ↓
13. Validar
```

---

# 📌 Resumo dos comandos

| Etapa            | Comando principal               |
| ---------------- | ------------------------------- |
| VLAN             | `vlan 100 smart`                |
| VLANIF           | `interface vlanif 100`          |
| DBA              | `dba-profile add ...`           |
| Service Profile  | `ont-srvprofile gpon ...`       |
| Line Profile     | `ont-lineprofile gpon ...`      |
| Auto-Find        | `port X ont-auto-find enable`   |
| Descobrir ONU    | `display ont autofind all`      |
| Cadastrar ONU    | `ont add ...`                   |
| VLAN da ONU      | `ont port native-vlan ...`      |
| Service Port     | `service-port ...`              |
| Salvar           | `save`                          |
| Remover ONU      | `ont delete ...`                |
| Ver configuração | `display current-configuration` |
| Resumo ONUs      | `display ont info summary ...`  |
