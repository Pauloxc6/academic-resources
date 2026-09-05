# Implementando o OSPF na Prática

Agora vamos implementar o **OSPF** no MikroTik utilizando a configuração de:

1. Instância OSPF;
2. Área Backbone;
3. `interface-template`;
4. Redes que serão executadas pelo OSPF;
5. Tipo de rede OSPF.

---

# Criando a instância OSPF

```bash
/routing ospf instance
add disabled=no name=ospf-instance-1
```

Esse comando cria uma nova **instância OSPF**.

```text
ospf-instance-1
      │
      ↓
Processo OSPF
```

A instância representa o processo OSPF que será utilizado pelo roteador.

---

# Criando a área Backbone

```bash
/routing ospf area
add disabled=no \
    instance=ospf-instance-1 \
    name=backbone
```

Aqui criamos a área:

```text
Area 0.0.0.0
```

que é a **Backbone Area** do OSPF.

A estrutura fica:

```text
OSPF Instance
      │
      ↓
  Backbone
      │
      ↓
Interface Templates
```

> A área Backbone é normalmente identificada pelo `area-id` `0.0.0.0`. Dependendo da versão/configuração do RouterOS, quando a área é criada sem especificar explicitamente o `area-id`, o valor padrão pode ser utilizado.

---

# Configurando o Interface Template

```bash
/routing ospf interface-template
add area=backbone \
    disabled=no \
    interfaces=all \
    type=broadcast \
    networks=1.1.2.0/24,1.2.2.0/24,192.168.122.0/24,10.1.1.0/16
```

O **interface-template** determina em quais interfaces/redes o OSPF será ativado e qual será o comportamento dessas interfaces.

---

# `area=backbone`

```text
area=backbone
```

Define que as interfaces correspondentes ao template participarão da:

```text
Area 0 → Backbone
```

---

# `interfaces=all`

```text
interfaces=all
```

Indica que o template pode corresponder a **todas as interfaces que satisfaçam os demais critérios do template**.

Isso não significa necessariamente que absolutamente todas as interfaces do roteador entrarão no OSPF, pois o campo `networks` também participa da correspondência.

Para laboratórios, entretanto, é comum ser mais claro especificar diretamente as interfaces ou redes desejadas.

---

# `type=broadcast`

```text
type=broadcast
```

Define o tipo de rede OSPF como **Broadcast**.

Esse é um comportamento típico de redes Ethernet.

Em uma rede broadcast:

```text
             Ethernet
                 │
       ┌─────────┼─────────┐
       │         │         │
      R1        R2        R3
       │         │         │
       └─────────┼─────────┘
               OSPF
```

O OSPF pode utilizar multicast para descobrir os vizinhos.

Além disso, em redes broadcast existe a possibilidade de eleição de:

```text
DR → Designated Router
BDR → Backup Designated Router
```

---

# `networks`

O comando original possui:

```text
networks=1.1.2.0/24,1.2.2.0/24,192.168.122.0/24,10.1.1.0/16
```

Cada prefixo indica uma rede que poderá ser correspondida pelo template.

Porém, existe um possível erro:

```text
1.2.2.0/24
```

No laboratório anterior, a rede configurada era:

```text
1.1.2.0/24
```

Portanto, provavelmente o correto seria:

```text
1.1.2.0/24
```

ficando:

```bash
networks=1.1.2.0/24,1.1.2.0/24,192.168.122.0/24,10.1.1.0/16
```

Mas nesse caso também haveria uma duplicação. Se a intenção era incluir redes diferentes, é necessário conferir o prefixo original.

---

# ⚠️ Atenção ao `10.1.1.0/16`

Existe outro detalhe importante:

```text
10.1.1.0/16
```

Em termos de rede canônica, um `/16` nessa faixa corresponde a:

```text
10.1.0.0/16
```

Portanto, se a intenção é representar uma rede `/16`, normalmente deve-se utilizar:

```text
10.1.0.0/16
```

e não:

```text
10.1.1.0/16
```

---

# Exemplo baseado nas loopbacks anteriores

No laboratório anterior, tínhamos:

### MK1

```text
1.1.1.1/24
1.1.2.1/24
```

Portanto:

```text
1.1.1.0/24
1.1.2.0/24
```

### MK2

```text
2.2.1.2/24
2.2.2.2/24
```

Portanto:

```text
2.2.1.0/24
2.2.2.0/24
```

Se quisermos anunciar essas quatro redes pelo OSPF:

```bash
/routing ospf interface-template
add area=backbone \
    disabled=no \
    type=broadcast \
    networks=1.1.1.0/24,1.1.2.0/24,2.2.1.0/24,2.2.2.0/24
```

Entretanto, **cada roteador deve anunciar apenas as redes que realmente possui**, e a rede de trânsito entre os roteadores também precisa participar do OSPF para que a vizinhança seja formada.

---

# Fluxo da configuração

```text
/routing ospf instance
        │
        ↓
ospf-instance-1
        │
        ↓
/routing ospf area
        │
        ↓
    backbone
        │
        ↓
/routing ospf interface-template
        │
        ├── networks
        ├── interfaces
        └── type
        │
        ↓
Interfaces participam do OSPF
        │
        ↓
Descoberta de vizinhos
        │
        ↓
Adjacência OSPF
        │
        ↓
Troca de LSAs
        │
        ↓
LSDB
        │
        ↓
SPF
        │
        ↓
Rotas OSPF
```

---

# Verificando a configuração

Depois de configurar o OSPF:

```bash
/routing ospf instance print
```

Ver as áreas:

```bash
/routing ospf area print
```

Ver os templates:

```bash
/routing ospf interface-template print
```

Ver as interfaces OSPF:

```bash
/routing ospf interface print
```

Ver os vizinhos:

```bash
/routing ospf neighbor print
```

Ver as rotas:

```bash
/routing ospf route print
```

E a tabela geral:

```bash
/ip route print
```

---

# 🧠 Para memorizar

```text
INSTANCE
   ↓
Processo OSPF

AREA
   ↓
Organização lógica

INTERFACE-TEMPLATE
   ↓
Onde o OSPF será aplicado

TYPE
   ↓
Comportamento da rede

NETWORKS
   ↓
Quais redes correspondem ao template
```

### Estrutura

```text
             OSPF
              │
       ospf-instance-1
              │
              ↓
          Backbone
              │
              ↓
    Interface Template
              │
       ┌──────┴──────┐
       ↓             ↓
   Broadcast       Redes
       │             │
       └──────┬──────┘
              ↓
          Vizinhança
              ↓
             LSDB
              ↓
             SPF
              ↓
            Rotas
```

> **Resumo:** a configuração cria uma instância OSPF, associa essa instância à área Backbone e utiliza um `interface-template` para determinar quais interfaces/redes participarão do OSPF e qual será o tipo de rede utilizado. Para o laboratório anterior, é importante revisar os prefixos `1.2.2.0/24` e `10.1.1.0/16`, pois ambos aparentam conter erros de endereçamento.
