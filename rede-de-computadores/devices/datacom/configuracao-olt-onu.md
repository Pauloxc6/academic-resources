# Datacom — Configuração OLT e ONU

## 📡 Cenário

Neste cenário será utilizada uma **OLT GPON Datacom** com quatro VLANs de serviço, onde cada **PON** será associada a uma VLAN específica.

Exemplo:

```text
PON 1 → VLAN 30
PON 2 → VLAN 31
PON 3 → VLAN 32
PON 4 → VLAN 33
```

As VLANs serão utilizadas para transportar o tráfego de **PPPoE** dos clientes.

---

# 🏷️ VLANs de serviço PPPoE

Primeiro são criadas as VLANs que serão utilizadas para transportar o tráfego PPPoE:

```text
dot1q vlan 30 name PPPoe interface gigabit-ethernet-1/1/10 tagged
dot1q vlan 31 name PPPoe interface gigabit-ethernet-1/1/10 tagged
dot1q vlan 32 name PPPoe interface gigabit-ethernet-1/1/10 tagged
dot1q vlan 33 name PPPoe interface gigabit-ethernet-1/1/10 tagged
```

Nesse exemplo:

| VLAN | PON associada |
| ---: | ------------- |
|   30 | PON 1         |
|   31 | PON 2         |
|   32 | PON 3         |
|   33 | PON 4         |

A interface:

```text
gigabit-ethernet-1/1/10
```

é utilizada como interface **tagged** para transportar as VLANs em direção à rede de agregação/BNG/servidor PPPoE.

> [!NOTE]
> A associação **PON → VLAN** depende da arquitetura de serviço configurada na OLT. A VLAN não necessariamente representa fisicamente uma única PON; ela pode ser utilizada como identificação do serviço ou domínio de encaminhamento.

---

# 🏠 Service VLAN

As **Service VLANs** definem como o serviço será tratado dentro da OLT.

```text
service vlan 30 type n:1
service vlan 31 type n:1
service vlan 32 type n:1
service vlan 33 type n:1
```

### Tipos de Service VLAN

| Tipo  | Utilização                                                            |
| ----- | --------------------------------------------------------------------- |
| `n:1` | Muitos clientes compartilhando o mesmo domínio de serviço             |
| `1:1` | Associação individual, comum em serviços dedicados                    |
| `tls` | Transporte transparente entre ONUs, permitindo comunicação entre elas |

### N:1

```text
             Service VLAN 30
                    │
        ┌───────────┼───────────┐
        │           │           │
      ONU 1       ONU 2       ONU 3
```

O modelo **N:1** permite que múltiplos clientes/ONUs utilizem o mesmo domínio de serviço.

É bastante comum em serviços residenciais, como:

* Internet;
* PPPoE;
* serviços compartilhados.

### 1:1

No modelo **1:1**, o serviço é associado individualmente, sendo adequado para cenários como:

* Link dedicado;
* Serviços corporativos;
* Clientes que precisam de isolamento específico.

### TLS

O modo **TLS** pode ser utilizado para transporte transparente entre ONUs, dependendo da implementação do equipamento.

Um exemplo de utilização seria permitir comunicação entre equipamentos de clientes na mesma rede de serviço, como determinados cenários de:

* VoIP;
* serviços transparentes;
* aplicações específicas de camada 2.

> [!WARNING]
> Não confunda `TLS` nesse contexto com **Transport Layer Security**. Aqui `tls` é um tipo de serviço da OLT relacionado ao transporte transparente de tráfego.

---

# 🚦 Controle de banda — Bandwidth Profile

Um **Bandwidth Profile** define parâmetros de largura de banda utilizados pelos T-CONTs.

Exemplo:

```text
profile gpon bandwidth-profile PPPoe
traffic type-4 max-bw 1106944
```

O valor:

```text
max-bw 1106944
```

define o limite máximo de banda conforme a unidade utilizada pela implementação/versão do equipamento.

> [!WARNING]
> `max-bw` não significa necessariamente "a velocidade máxima da porta Ethernet". Ele é um parâmetro do **perfil de banda GPON**, utilizado no controle do tráfego associado ao T-CONT.

---

# 🌉 Line Profile — ONU em Bridge

O **Line Profile** define a estrutura de transporte do tráfego entre a OLT e a ONU.

Exemplo:

```text
profile gpon line-profile PPPoe-INTERNET

upstream-fec

tcont 1 bandwidth-profile PPPoe
tcont 2 bandwidth-profile PPPoe
tcont 3 bandwidth-profile PPPoe
tcont 4 bandwidth-profile PPPoe

gem 1
 tcont 1 priority 0
   map PPPoe-Bridge-30 ethernet 1 vlan 30 cos any

gem 2
 tcont 2 priority 0
   map PPPoe-Bridge-31 ethernet 1 vlan 31 cos any

gem 3
 tcont 3 priority 0
   map PPPoe-Bridge-32 ethernet 1 vlan 32 cos any

gem 4
 tcont 4 priority 0
   map PPPoe-Bridge-33 ethernet 1 vlan 33 cos any
```

---

## 🔹 T-CONT

O **T-CONT (Transmission Container)** é utilizado para controlar a largura de banda no sentido **upstream** da rede GPON.

Neste exemplo:

```text
tcont 1 bandwidth-profile PPPoe
tcont 2 bandwidth-profile PPPoe
tcont 3 bandwidth-profile PPPoe
tcont 4 bandwidth-profile PPPoe
```

Cada T-CONT utiliza o `bandwidth-profile` definido anteriormente.

### Relação

```text
Bandwidth Profile
        │
        ▼
      T-CONT
        │
        ▼
       GEM
        │
        ▼
    VLAN / Serviço
```

---

# 🔹 GEM

**GEM (GPON Encapsulation Method)** é utilizado para transportar os dados do cliente dentro da rede GPON.

Exemplo:

```text
gem 1
 tcont 1 priority 0
   map PPPoe-Bridge-30 ethernet 1 vlan 30 cos any
```

Aqui temos:

```text
GEM 1
 │
 ├── T-CONT 1
 │
 ├── Ethernet 1
 │
 ├── VLAN 30
 │
 └── CoS: any
```

O `map` associa o tráfego recebido pela interface da ONU ao serviço/VLAN correspondente.

---

# 🌐 Line Profile — ONU em Router

Quando a ONU/ONT funciona como **roteador**, o tráfego pode ser entregue através de uma interface virtual de Ethernet, como `VEIP`.

Exemplo:

```text
profile gpon line-profile PPPoe-INTERNET-ONT

tcont 1 bandwidth-profile PPPoe

gem 1 tcont 1 priority 0
map PPPoe-ONT veip 1 vlan 30 cos any
```

Nesse cenário:

```text
Cliente
   │
   ▼
ONU/ONT
(Router)
   │
   │ VEIP
   ▼
GEM
   │
   ▼
VLAN 30
   │
   ▼
Rede de agregação
```

A diferença principal em relação ao modo bridge é o ponto onde ocorre a terminação/processamento do serviço.

---

# 🔀 Line Profile — múltiplas VLANs usando VEIP

Para transportar várias VLANs pelo mesmo perfil, pode-se utilizar um mapeamento mais genérico, quando suportado pela configuração do equipamento:

```text
profile gpon line-profile PPPoe-INTERNET-ONT

upstream-fec

tcont 1 bandwidth-profile PPPoe
tcont 2 bandwidth-profile PPPoe
tcont 3 bandwidth-profile PPPoe
tcont 4 bandwidth-profile PPPoe

gem 1
 tcont 1 priority 0
   map PPPoe-ONT-30 veip 1 vlan 30 cos any

gem 2
 tcont 2 priority 0
   map PPPoe-ONT-31 veip 1 vlan 31 cos any

gem 3
 tcont 3 priority 0
   map PPPoe-ONT-32 veip 1 vlan 32 cos any

gem 4
 tcont 4 priority 0
   map PPPoe-ONT-33 veip 1 vlan 33 cos any
```

---

# 🧩 Utilizando `vlan any`

Outra possibilidade é utilizar:

```text
gem 1
 tcont 1 priority 0
 map PPPoe-ONT-11
  veip 1 vlan any cos any
 !
!
```

O:

```text
vlan any
```

indica que o mapeamento pode aceitar **qualquer VLAN que corresponda às regras permitidas pelo serviço/configuração**, em vez de especificar uma VLAN individual nesse ponto do perfil.

Isso pode permitir o reaproveitamento do mesmo **Line Profile** para diferentes VLANs.

### Vantagem

Sem `vlan any`:

```text
VLAN 30 → Profile A
VLAN 31 → Profile B
VLAN 32 → Profile C
VLAN 33 → Profile D
```

Com um perfil genérico:

```text
              ┌── VLAN 30
              ├── VLAN 31
Line Profile ─┼── VLAN 32
              └── VLAN 33
```

Isso reduz a quantidade de perfis que precisam ser criados e pode simplificar a integração com sistemas de provisionamento/autenticação, como um **IXC**.

> [!WARNING]
> `vlan any` não significa que absolutamente qualquer VLAN da OLT será automaticamente aceita. O comportamento final depende das regras de serviço, VLANs criadas e demais configurações da OLT.

---

# 📟 Registro da ONU

Depois da criação dos perfis, a ONU pode ser registrada na interface GPON.

Exemplo:

```text
config

interface gpon 1/1/1

 onu [X]
  name NomeCliente
  serial-number DACM0001049C
  line-profile NOME-DO-PROFILE

  ethernet 1
   negotiation
   no shutdown
   native vlan vlan-id [Y]

  top

 service-port [Z] gpon 1/1/1 onu [X] gem 1 match vlan vlan-id [Y] action vlan replace vlan-id [Y]

commit
```

---

## 🔢 Identificadores utilizados

Existem alguns identificadores importantes nessa configuração:

| Identificador | Função                                  |
| ------------- | --------------------------------------- |
| `[X]`         | ID da ONU dentro da PON                 |
| `[Y]`         | VLAN utilizada pelo serviço             |
| `[Z]`         | ID do Service Port                      |
| `gem 1`       | GEM utilizado pelo serviço              |
| `1/1/1`       | Interface/PON onde a ONU está conectada |

Exemplo:

```text
PON:       1/1/1
ONU ID:    10
VLAN:      30
GEM:       1
Service:   100
```

---

# 🔌 Ethernet da ONU

```text
ethernet 1
 negotiation
 no shutdown
 native vlan vlan-id [Y]
```

### `negotiation`

Habilita a negociação da interface Ethernet.

### `no shutdown`

Coloca a interface em estado operacional.

### `native vlan`

Define a VLAN nativa/associada ao tráfego não tagueado nessa interface, conforme o modo de serviço configurado.

---

# 🔗 Service Port

O **Service Port** realiza a associação entre os elementos do serviço:

```text
Service Port
     │
     ├── PON
     ├── ONU
     ├── GEM
     └── VLAN
```

Exemplo:

```text
service-port 100 gpon 1/1/1 onu 10 gem 1 match vlan vlan-id 30 action vlan replace vlan-id 30
```

Nesse caso:

```text
Service Port 100
       │
       ├── PON: 1/1/1
       ├── ONU: 10
       ├── GEM: 1
       └── VLAN: 30
```

A ação:

```text
action vlan replace vlan-id 30
```

define o tratamento da VLAN conforme a regra configurada.

---

# ⚠️ Atenção aos Service Ports

Cada **Service Port** deve possuir um identificador apropriado e exclusivo dentro do escopo exigido pelo equipamento.

Também é importante controlar os IDs das ONUs.

Exemplo:

```text
ONU 1 → Service Port 100
ONU 2 → Service Port 101
ONU 3 → Service Port 102
```

Evite reutilizar IDs sem antes verificar as associações existentes.

> [!WARNING]
> Em configurações de provisionamento, a reutilização de um `service-port` ou de um ID de ONU que já esteja associado a outro serviço pode causar alteração ou remoção da associação anterior, dependendo da implementação/versão do software da OLT. Sempre valide antes de reutilizar identificadores.

---

# 🧠 Fluxo completo

A configuração pode ser entendida seguindo esta sequência:

```text
                    OLT
                     │
          ┌──────────┴──────────┐
          │                     │
      Service VLAN        Bandwidth Profile
          │                     │
          │                     ▼
          │                   T-CONT
          │                     │
          │                     ▼
          │                    GEM
          │                     │
          └──────────┬──────────┘
                     │
                Line Profile
                     │
                     ▼
                    ONU
                     │
              ┌──────┴──────┐
              │             │
            Bridge        Router
              │             │
              ▼             ▼
          Ethernet        VEIP
              │             │
              └──────┬──────┘
                     │
                     ▼
                Service Port
                     │
                     ▼
                   VLAN
                     │
                     ▼
                Rede PPPoE
```

---

# 📌 Bridge × Router

| Característica       | ONU Bridge                                       | ONU Router                                     |
| -------------------- | ------------------------------------------------ | ---------------------------------------------- |
| Roteamento           | Equipamento do cliente/BNG                       | ONU/ONT                                        |
| Interface de serviço | Ethernet                                         | VEIP                                           |
| PPPoE                | Cliente pode estabelecer PPPoE através da ONU    | Pode ser terminado/processado pela própria ONU |
| NAT                  | Normalmente não                                  | Pode existir                                   |
| IP público           | Normalmente entregue ao equipamento atrás da ONU | Pode ser configurado na ONU                    |
| Uso comum            | Cliente utiliza roteador próprio                 | ONU/ONT fornece funções de roteamento          |

> [!TIP]
> Para memorizar:
>
> **Bridge:** a ONU transporta o tráfego.
> **Router:** a ONU participa do processamento de camada 3.

---

# 📚 Conceitos para memorizar

### OLT

Equipamento responsável por concentrar e controlar as conexões GPON das ONUs/ONTs.

### ONU

Equipamento localizado no lado do assinante que converte o acesso óptico GPON para interfaces de cliente.

### ONT

É uma ONU voltada especificamente para terminação na residência/cliente. Na prática, os termos **ONU** e **ONT** muitas vezes são utilizados de forma intercambiável em redes de acesso.

### T-CONT

Controla/organiza a alocação de banda no **upstream** GPON.

### GEM

Transporta os dados dos serviços dentro da rede GPON.

### Line Profile

Define características do transporte GPON associado à ONU, incluindo T-CONTs e GEMs.

### Service VLAN

Define o domínio/forma de tratamento do serviço na rede.

### Service Port

Faz a associação entre a ONU, PON, GEM e VLAN/regras de serviço.

### Bandwidth Profile

Define parâmetros de largura de banda utilizados pelos T-CONTs.

---

# 🚀 Ordem lógica de configuração

```text
1. Criar VLANs
       ↓
2. Criar Service VLAN
       ↓
3. Criar Bandwidth Profile
       ↓
4. Criar Line Profile
       ↓
5. Registrar ONU
       ↓
6. Associar Line Profile
       ↓
7. Configurar Ethernet/VEIP
       ↓
8. Criar Service Port
       ↓
9. Associar GEM ↔ VLAN
       ↓
10. Commit
       ↓
11. Validar o serviço
```

---

# 🔍 Checklist de validação

Após a configuração, verificar:

```text
✓ ONU registrada
✓ Serial Number correto
✓ ONU associada à PON correta
✓ Line Profile correto
✓ T-CONT configurado
✓ GEM configurado
✓ VLAN criada
✓ Service VLAN configurada
✓ Service Port criado
✓ VLAN corretamente associada
✓ Interface Ethernet/VEIP operacional
✓ Tráfego chegando ao equipamento de agregação
✓ PPPoE realizando autenticação
```

> [!TIP]
> Em troubleshooting GPON, é útil separar o problema em camadas:
>
> **ONU → PON → GEM → Service Port → VLAN → uplink → BNG/PPPoE**
>
> Assim fica muito mais fácil descobrir em qual ponto o tráfego está sendo interrompido.
