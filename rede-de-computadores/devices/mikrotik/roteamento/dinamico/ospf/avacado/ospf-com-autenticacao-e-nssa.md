# OSPF com Autenticação e NSSA

O OSPF permite utilizar **autenticação** para proteger a formação das adjacências entre roteadores.

Também é possível configurar uma área como **NSSA (Not-So-Stubby Area)**, permitindo que a área mantenha características de uma Stub Area, mas ainda consiga **originar rotas externas**.

Neste exemplo:

```text
Área → NSSA
Autenticação → MD5
Tipo de rede → Broadcast
```

---

# NSSA

A **NSSA (Not-So-Stubby Area)** é uma variação de Stub Area.

A principal diferença é que uma Stub Area não permite que um roteador interno origine determinadas rotas externas para dentro do domínio OSPF.

A NSSA permite isso através de **LSA Tipo 7**.

```text
NSSA
 │
 ├── características de Stub
 │
 └── permite rotas externas
          ↓
       LSA Type 7
```

Quando necessário, o ABR pode converter essas informações para **LSA Tipo 5** ao propagá-las para outras áreas.

---

# Autenticação OSPF

A autenticação permite que os roteadores verifiquem se os pacotes OSPF recebidos pertencem a um vizinho autorizado.

Neste exemplo será utilizada:

```text
MD5
```

A configuração precisa ser compatível nos dois lados da adjacência:

```text
R2
 │
 │ MD5
 │ chave compartilhada
 │
R3
```

Se a autenticação não coincidir, a vizinhança OSPF não será formada corretamente.

---

# R2

## Configurando a área como NSSA

```bash
/routing ospf area
set [find area-id=0.0.0.1] type=nssa
```

Nesse exemplo, a:

```text
Area 0.0.0.1
```

é configurada como:

```text
NSSA
```

---

## Configurando autenticação

```bash
/routing ospf interface-template
add \
    area=local-1 \
    instance-id=instance-0 \
    auth=md5 \
    auth-key="12345678abc" \
    type=broadcast
```

Os parâmetros principais são:

| Parâmetro                | Função                             |
| ------------------------ | ---------------------------------- |
| `area=local-1`           | Área onde o template será aplicado |
| `instance-id=instance-0` | Instância OSPF utilizada           |
| `auth=md5`               | Habilita autenticação MD5          |
| `auth-key`               | Chave compartilhada                |
| `type=broadcast`         | Define o tipo de rede OSPF         |

---

# R3

R3 precisa utilizar a mesma área e os parâmetros de autenticação compatíveis.

```bash
/routing ospf area
set [find area-id=0.0.0.1] type=nssa
```

Interface/template:

```bash
/routing ospf interface-template
add \
    area=local-1 \
    instance-id=instance-0 \
    auth=md5 \
    auth-key="12345678abc" \
    type=broadcast
```

Assim:

```text
R2
 │
 │ Area 1 / NSSA
 │ MD5
 │
R3
```

---

# ⚠️ A chave precisa coincidir

R2:

```text
auth-key="12345678abc"
```

R3:

```text
auth-key="12345678abc"
```

Se estiver diferente:

```text
R2 → 12345678abc
R3 → 987654321
```

a autenticação falhará e a adjacência poderá não ser estabelecida.

---

# ⚠️ NSSA é propriedade da área

Não basta colocar:

```bash
auth=md5
```

na interface.

São configurações diferentes:

```text
Área
 ↓
NSSA

Interface OSPF
 ↓
Autenticação MD5
```

Portanto:

```text
/routing ospf area
    ↓
type=nssa
```

e:

```text
/routing ospf interface-template
    ↓
auth=md5
auth-key="..."
```

possuem funções distintas.

---

# Broadcast

O:

```bash
type=broadcast
```

indica que a interface OSPF está em uma rede do tipo **broadcast**, típica de Ethernet.

Em redes broadcast, o OSPF pode utilizar:

```text
DR → Designated Router
BDR → Backup Designated Router
```

para otimizar a formação das adjacências em segmentos compartilhados.

Em um enlace Ethernet ponto a ponto, dependendo da topologia, pode ser mais apropriado utilizar:

```text
type=ptp
```

Portanto, o tipo deve corresponder ao cenário real da interface.

---

# NSSA e LSA Tipo 7

Uma das características mais importantes da NSSA é permitir a injeção de rotas externas através de **LSA Tipo 7**.

Exemplo:

```text
                 OSPF
                  │
          ┌───────┴───────┐
          │               │
       Area 0          Area 1
                       NSSA
                         │
                        R3
                         │
                    Rede externa
```

Uma rota externa originada dentro da NSSA pode ser representada como:

```text
Rota externa
     ↓
LSA Type 7
     ↓
NSSA
     ↓
ABR
     ↓
LSA Type 5
     ↓
outras áreas
```

Essa conversão é uma das funções importantes do **ABR**.

---

# Diferença entre Stub e NSSA

| Característica               | Stub | NSSA |
| ---------------------------- | ---: | ---: |
| Reduz LSAs externos          |    ✅ |    ✅ |
| Pode originar rotas externas |    ❌ |    ✅ |
| LSA Tipo 7                   |    ❌ |    ✅ |
| Pode usar rota default       |    ✅ |    ✅ |
| Utiliza ABR                  |    ✅ |    ✅ |

---

# Fluxo da configuração

```text
                 R2
                  │
          ┌───────┴────────┐
          │                │
       Area 0          Area 1
                       NSSA
                          │
                         R3
                          │
                     MD5 Auth
```

A autenticação protege a adjacência:

```text
R2
 │
 ├── OSPF
 ├── MD5
 └── chave compartilhada
 │
R3
```

Enquanto a NSSA define o comportamento de roteamento da área:

```text
Area 1
   ↓
 NSSA
   ↓
LSA Type 7
   ↓
 ABR
   ↓
LSA Type 5
```

---

# 🧠 Para memorizar

```text
NSSA
 ↓
Not-So-Stubby Area
 ↓
Stub + possibilidade de rotas externas
 ↓
LSA Type 7
```

```text
MD5
 ↓
Autenticação OSPF
 ↓
Chave compartilhada
 ↓
Protege a formação da adjacência
```

### Regra principal

> **NSSA define o comportamento da área; MD5 define a autenticação da interface OSPF.**

```text
/routing ospf area
        ↓
    type=nssa

/routing ospf interface-template
        ↓
     auth=md5
        ↓
     auth-key
```
