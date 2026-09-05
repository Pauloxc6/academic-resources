# 🌐 Criando uma Default Route e removendo AS privados no BGP

Nesta configuração vamos trabalhar com:

* criação de uma **rota default**;
* anúncio da rota default via **BGP**;
* remoção de **AS privados** do `AS_PATH` antes do anúncio.

---

# 📌 Criando a Default Route

## MK1

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1
```

## MK2

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1
```

A rota:

```text
0.0.0.0/0
```

é a **rota default**.

Ela representa:

> "Se não existir uma rota mais específica para o destino, utilize este caminho."

A estrutura é:

```text
dst-address=0.0.0.0/0
        │
        └── qualquer destino IPv4

gateway=192.168.122.1
        │
        └── próximo salto
```

---

# 📢 Anunciando a Default Route pelo BGP

Depois de criar a rota default, podemos configurar o BGP para anunciá-la:

```bash
/routing bgp connection set 0 output.default-originate=always
```

O parâmetro:

```text
output.default-originate=always
```

faz com que a sessão BGP **origine/anuncie uma rota default (`0.0.0.0/0`) para o vizinho**, mesmo que não exista uma rota default instalada na tabela de roteamento.

Portanto, o comando da rota default:

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1
```

e:

```bash
/routing bgp connection set 0 output.default-originate=always
```

têm funções diferentes.

### Rota default

```text
/ip route
     ↓
Cria a rota no próprio roteador
```

### `default-originate`

```text
/routing bgp connection
     ↓
Anuncia uma rota default ao vizinho BGP
```

---

# 🔐 Removendo AS privados

```bash
/routing bgp connection set 0 output.remove-private-as=yes
```

Esse parâmetro faz o BGP **remover números de AS privados do `AS_PATH` quando anuncia rotas para o vizinho**, conforme as regras do RouterOS/BGP.

Isso é útil quando uma infraestrutura utiliza AS privados internamente, mas essas informações não devem ser propagadas para fora do domínio de roteamento.

---

# 🏢 AS públicos x AS privados

Existem faixas reservadas para utilização privada em BGP.

Historicamente, para 16-bit:

```text
64512 – 65534
```

E no espaço de 32-bit:

```text
4200000000 – 4294967294
```

Esses AS são destinados a ambientes privados e não devem ser utilizados como identificadores públicos de Internet.

Exemplo:

```text
AS privado
    ↓
64512
```

Quando uma rota percorre vários AS, o BGP registra essa sequência no atributo:

```text
AS_PATH
```

Exemplo:

```text
AS_PATH = 64512 65001 65002
```

Com:

```text
output.remove-private-as=yes
```

o roteador pode remover os AS privados aplicáveis antes de anunciar a rota ao vizinho.

---

# 🔄 Exemplo do fluxo

Imagine:

```text
              Default Route
             0.0.0.0/0
                  │
                  ▼
           ┌─────────────┐
           │    MK1      │
           │             │
           │ AS privado  │
           └──────┬──────┘
                  │
                  │ BGP
                  │
                  ▼
           ┌─────────────┐
           │   Vizinho   │
           │    BGP      │
           └─────────────┘
```

O MK1 possui:

```text
0.0.0.0/0
```

e anuncia essa rota através do BGP:

```text
MK1
 │
 │ 0.0.0.0/0
 ▼
Vizinho BGP
```

Ao mesmo tempo:

```text
output.remove-private-as=yes
```

controla a remoção de AS privados presentes no caminho BGP anunciado.

---

# ⚠️ `always` é importante

Existe uma diferença importante entre anunciar a default somente quando ela existe e utilizar:

```text
output.default-originate=always
```

Com `always`, o BGP é configurado para **originar a default independentemente da existência de uma rota default na tabela IP**.

Por isso, neste laboratório temos:

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1
```

mas o anúncio BGP com:

```bash
output.default-originate=always
```

não depende dessa rota para ser originado.

---

# 🧠 Resumo

```text
0.0.0.0/0
    ↓
Default Route
    ↓
Caminho utilizado quando não há rota mais específica
```

```text
output.default-originate=always
    ↓
Anuncia 0.0.0.0/0 via BGP
```

```text
output.remove-private-as=yes
    ↓
Remove AS privados aplicáveis do AS_PATH
    ↓
Antes do anúncio ao vizinho
```

---

# 📋 Configuração completa

## MK1

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1

/routing bgp connection set 0 \
    output.default-originate=always \
    output.remove-private-as=yes
```

## MK2

```bash
/ip route add dst-address=0.0.0.0/0 gateway=192.168.122.1

/routing bgp connection set 0 \
    output.default-originate=always \
    output.remove-private-as=yes
```

---

# 🧠 Para memorizar

| Comando                    | Função                                              |
| -------------------------- | --------------------------------------------------- |
| `dst-address=0.0.0.0/0`    | Define uma rota default                             |
| `gateway=192.168.122.1`    | Define o próximo salto                              |
| `default-originate=always` | Origina/anuncia default via BGP                     |
| `remove-private-as=yes`    | Remove AS privados aplicáveis do `AS_PATH` de saída |
| `AS_PATH`                  | Registra os AS percorridos pela rota                |

> **Importante:** `default-originate=always` e a rota `0.0.0.0/0` são conceitos diferentes. A primeira controla o **anúncio BGP** da default; a segunda cria uma **rota de encaminhamento local** no roteador.
