# Conhecendo o Protocolo OSPF e Preparando o Ambiente

O **OSPF (Open Shortest Path First)** é um protocolo de roteamento dinâmico do tipo **IGP (Interior Gateway Protocol)** utilizado para trocar informações de roteamento dentro de um mesmo sistema autônomo.

Antes de iniciar a configuração do OSPF, vamos preparar o ambiente criando interfaces de **loopback** e atribuindo endereços IP aos roteadores MikroTik.

---

# Topologia

O laboratório possui dois roteadores:

```text
       MK1                         MK2
        │                           │
   ┌────┴────┐                 ┌────┴────┐
   │         │                 │         │
 Loopback1 Loopback2        Loopback1 Loopback2
   │         │                 │         │
1.1.1.1   1.1.2.1          2.2.1.2   2.2.2.2
```

As loopbacks serão utilizadas para representar redes internas de cada roteador.

---

# MK1

## Criando as Loopbacks

No MikroTik, uma forma comum de criar uma interface lógica para loopback é utilizar uma `bridge` sem portas:

```bash
/interface bridge
add name=loopback1
add name=loopback2
```

> **Correção:** no comando original, `loopback1` havia sido criado duas vezes. Para utilizar `loopback2`, é necessário criá-lo separadamente.

## Configurando os endereços IP

```bash
/ip address
add address=1.1.1.1/24 interface=loopback1
add address=1.1.2.1/24 interface=loopback2
```

Resultado:

```text
MK1

loopback1 → 1.1.1.1/24
loopback2 → 1.1.2.1/24
```

---

# MK2

## Criando as Loopbacks

```bash
/interface bridge
add name=loopback1
add name=loopback2
```

## Configurando os endereços IP

```bash
/ip address
add address=2.2.1.2/24 interface=loopback1
add address=2.2.2.2/24 interface=loopback2
```

Resultado:

```text
MK2

loopback1 → 2.2.1.2/24
loopback2 → 2.2.2.2/24
```

---

# Endereçamento

| Roteador | Interface   | Endereço     |
| -------- | ----------- | ------------ |
| MK1      | `loopback1` | `1.1.1.1/24` |
| MK1      | `loopback2` | `1.1.2.1/24` |
| MK2      | `loopback1` | `2.2.1.2/24` |
| MK2      | `loopback2` | `2.2.2.2/24` |

---

# O que é uma Loopback?

Uma **loopback** é uma interface lógica que não depende diretamente de uma interface física específica.

Em laboratórios de roteamento, ela é bastante utilizada para:

* representar redes internas;
* testar conectividade;
* fornecer um endereço estável para identificação do roteador;
* utilizar como **Router ID** em protocolos como OSPF e BGP.

Por exemplo:

```text
MK1
 │
 ├── loopback1 → 1.1.1.1/24
 └── loopback2 → 1.1.2.1/24
```

---

# Por que utilizar Loopback no OSPF?

O OSPF precisa identificar cada roteador através de um **Router ID**.

Uma loopback é uma boa candidata porque permanece disponível enquanto houver alguma conectividade no roteador, independentemente de uma interface física específica.

Exemplo:

```text
MK1
Router ID → 1.1.1.1

MK2
Router ID → 2.2.1.2
```

> O Router ID e o endereço da loopback são conceitos diferentes, embora seja comum utilizar o endereço da loopback como Router ID.

---

# Preparação para o OSPF

Até aqui, temos somente o endereçamento das interfaces lógicas:

```text
             MK1
          /        \
   1.1.1.1/24   1.1.2.1/24
       │             │
       └─────┐ ┌─────┘
             │ │
            OSPF
             │ │
       ┌─────┘ └─────┐
       │             │
   2.2.1.2/24   2.2.2.2/24
          \        /
             MK2
```

Ainda será necessário configurar uma **rede de trânsito** entre MK1 e MK2.

Por exemplo:

```text
MK1 ───────────── MK2
      rede de
      trânsito
```

Essa rede será utilizada para que os roteadores consigam formar a **vizinhança OSPF**.

Depois disso, o OSPF poderá anunciar as redes:

```text
MK1 → 1.1.1.0/24
      1.1.2.0/24

MK2 → 2.2.1.0/24
      2.2.2.0/24
```

Assim, MK1 poderá aprender as redes de MK2 e vice-versa.

---

# 🧠 Para memorizar

```text
Loopback
   ↓
Interface lógica
   ↓
Não depende diretamente de uma porta física
   ↓
Pode representar redes internas
   ↓
Pode ser utilizada como Router ID
```

E o funcionamento que será construído no laboratório:

```text
        MK1                         MK2
         │                           │
    Redes locais                Redes locais
         │                           │
         └────── Rede de ────────────┘
                 trânsito
                    │
                   OSPF
                    │
             Vizinhança
                    │
              Troca de rotas
```

> **Resumo:** nesta etapa o ambiente foi preparado com duas interfaces de loopback em cada MikroTik. As loopbacks representam redes locais e poderão ser utilizadas no estudo do OSPF, inclusive como base para definição do Router ID.
