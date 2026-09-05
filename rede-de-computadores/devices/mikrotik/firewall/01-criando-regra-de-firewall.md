# 01 — Criando regra de Firewall

O **Firewall** do MikroTik é responsável por controlar o tráfego que passa pelo roteador, permitindo, bloqueando ou modificando pacotes de acordo com regras definidas pelo administrador.

No RouterOS, as regras de firewall ficam organizadas principalmente em:

```routeros
/ip/firewall
```

A partir desse menu existem diferentes mecanismos, como:

```routeros
/ip/firewall/filter
/ip/firewall/nat
/ip/firewall/mangle
/ip/firewall/raw
```

---

## 🔥 Firewall Filter

O **Filter** é utilizado principalmente para **permitir ou bloquear tráfego**.

```routeros
/ip/firewall/filter
```

Uma regra básica pode ser criada com:

```routeros
/ip/firewall/filter/add chain=forward action=accept
```

Nesse exemplo:

| Parâmetro       | Função                                           |
| --------------- | ------------------------------------------------ |
| `chain=forward` | Analisa tráfego que está atravessando o roteador |
| `action=accept` | Permite o pacote                                 |
| `add`           | Cria uma nova regra                              |

---

## 📌 Chains principais

O RouterOS possui três chains principais no firewall filter:

### `input`

Trata tráfego **destinado ao próprio roteador**.

```text
PC ───────► ROUTER
             ↑
           INPUT
```

Exemplo:

```routeros
/ip/firewall/filter/add chain=input protocol=icmp action=accept
```

Permite ICMP destinado ao próprio roteador.

---

### `forward`

Trata tráfego que **passa através do roteador**.

```text
PC ─────► ROUTER ─────► INTERNET
              ↑
           FORWARD
```

Exemplo:

```routeros
/ip/firewall/filter/add chain=forward src-address=192.168.10.0/24 action=accept
```

Permite tráfego originado da rede `192.168.10.0/24` que esteja sendo encaminhado pelo roteador.

---

### `output`

Trata tráfego **gerado pelo próprio roteador**.

```text
ROUTER ─────► INTERNET
   ↑
 OUTPUT
```

Exemplo:

```routeros
/ip/firewall/filter/add chain=output protocol=icmp action=accept
```

Permite ICMP gerado pelo próprio roteador.

---

# 🧱 Criando uma regra de bloqueio

Para bloquear o acesso de uma rede:

```routeros
/ip/firewall/filter/add \
    chain=forward \
    src-address=192.168.10.0/24 \
    action=drop
```

### Funcionamento

```text
192.168.10.0/24
       │
       ▼
   [ FIREWALL ]
       │
       X DROP
```

O tráfego dessa rede será descartado quando estiver passando pelo roteador.

---

# 🎯 Bloqueando uma porta

Também podemos filtrar por porta.

Exemplo: bloquear HTTP:

```routeros
/ip/firewall/filter/add \
    chain=forward \
    protocol=tcp \
    dst-port=80 \
    action=drop
```

A regra procura:

* protocolo `TCP`;
* porta de destino `80`;
* tráfego na chain `forward`;
* e descarta o pacote.

> ⚠️ Isso não significa necessariamente bloquear todo acesso web. HTTPS normalmente utiliza TCP/443 e HTTP moderno pode envolver outras tecnologias, como HTTP/3 sobre UDP/443.

---

# 🌐 Bloqueando uma rede de acessar outra

Exemplo:

```text
LAN 1
192.168.10.0/24
       │
       │
       ▼
    ROUTER
       │
       X
       │
       ▼
LAN 2
192.168.20.0/24
```

Regra:

```routeros
/ip/firewall/filter/add \
    chain=forward \
    src-address=192.168.10.0/24 \
    dst-address=192.168.20.0/24 \
    action=drop
```

Nesse caso:

```text
Origem  →  Destino
LAN 1   →  LAN 2
```

é bloqueado.

O tráfego no sentido contrário:

```text
LAN 2   →  LAN 1
```

não é automaticamente bloqueado por essa regra.

---

# 🔢 Ordem das regras

As regras do firewall são avaliadas **de cima para baixo**.

```text
1. accept
2. drop
3. accept
4. drop
```

Quando uma regra corresponde ao pacote e sua ação determina o processamento, o resultado pode impedir que regras posteriores sejam consideradas.

Por isso, a ordem é extremamente importante.

Para visualizar as regras:

```routeros
/ip/firewall/filter/print
```

Com detalhes:

```routeros
/ip/firewall/filter/print detail
```

---

# 🏷️ Adicionando comentário

É recomendável documentar as regras:

```routeros
/ip/firewall/filter/add \
    chain=forward \
    src-address=192.168.10.0/24 \
    dst-address=192.168.20.0/24 \
    action=drop \
    comment="Bloqueia LAN10 para LAN20"
```

Isso facilita a manutenção do firewall.

---

# 🧠 Conceito importante

Antes de criar uma regra, pergunte:

```text
1. Qual tráfego quero analisar?
2. Quem é a origem?
3. Qual é o destino?
4. Qual protocolo?
5. Qual porta?
6. O tráfego é INPUT, FORWARD ou OUTPUT?
7. Quero ACCEPT ou DROP?
```

Exemplo:

> Quero bloquear computadores da rede `192.168.10.0/24` de acessar a rede `192.168.20.0/24`.

Transformando em regra:

```routeros
/ip/firewall/filter/add \
    chain=forward \
    src-address=192.168.10.0/24 \
    dst-address=192.168.20.0/24 \
    action=drop \
    comment="Bloqueia LAN10 -> LAN20"
```

---

## 📋 Resumo

| Chain     | Tráfego                                 |
| --------- | --------------------------------------- |
| `input`   | Internet/LAN → próprio roteador         |
| `forward` | Rede → através do roteador → outra rede |
| `output`  | Próprio roteador → rede/Internet        |

### Ações comuns

| Action   | Função                        |
| -------- | ----------------------------- |
| `accept` | Permite                       |
| `drop`   | Descarta silenciosamente      |
| `reject` | Recusa informando o remetente |
| `log`    | Registra o pacote no log      |

### Estrutura básica

```routeros
/ip/firewall/filter/add \
    chain=<chain> \
    <condições> \
    action=<ação> \
    comment="<descrição>"
```

> 💡 **Para memorizar:**
> `input` = **entra no roteador**
> `forward` = **atravessa o roteador**
> `output` = **sai do roteador**
