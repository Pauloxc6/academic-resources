# 06 — DMZ

Uma **DMZ (Demilitarized Zone)** é uma rede separada destinada principalmente a hospedar serviços que precisam ser acessíveis por outras redes, especialmente pela Internet.

Exemplos de serviços que podem ficar em uma DMZ:

* Servidor Web
* Servidor DNS
* Servidor de e-mail
* Servidor FTP
* APIs e aplicações públicas

---

# 🌐 Topologia

Um cenário simples:

```text
                 INTERNET
                     │
                     ▼
              ┌─────────────┐
              │   MikroTik  │
              │   Firewall  │
              └──────┬──────┘
                     │
                    DMZ
                     │
                     ▼
              ┌─────────────┐
              │ Web Server  │
              │ 192.168.4.1 │
              └─────────────┘
```

A ideia é evitar colocar um servidor exposto diretamente dentro da rede interna.

---

# 🔓 Liberando todas as portas

Em um laboratório, podemos criar uma regra permitindo todo o tráfego encaminhado para um servidor da DMZ:

```routeros
/ip/firewall/filter
add chain=forward \
    dst-address=192.168.4.1 \
    action=accept \
    comment="Permite todo tráfego para servidor DMZ"
```

Essa regra permite tráfego **encaminhado (`forward`) destinado ao servidor `192.168.4.1`**, independentemente da porta ou protocolo.

Em outras palavras:

```text
Internet/LAN
     │
     │ qualquer porta
     ▼
 Firewall
     │
     │ ACCEPT
     ▼
192.168.4.1
```

---

# ⚠️ "Todas as portas" não significa todas as direções

A regra:

```routeros
dst-address=192.168.4.1
```

identifica o **destino**.

Ela não significa:

```text
DMZ → Internet
DMZ → LAN
```

automaticamente.

Por exemplo:

```text
INTERNET ───► DMZ       ✅ regra pode permitir
LAN ────────► DMZ       ✅ regra pode permitir
DMZ ────────► INTERNET  ❌ depende de outras regras
DMZ ────────► LAN       ❌ depende de outras regras
```

O firewall continua avaliando o tráfego de acordo com suas regras e sua ordem.

---

# 🔀 DMZ + DNAT

Se o servidor possui um IP privado, normalmente será necessário utilizar **DST-NAT** para publicá-lo na Internet.

Por exemplo:

```routeros
/ip/firewall/nat
add chain=dstnat \
    action=dst-nat \
    in-interface=ether1-WAN \
    protocol=tcp \
    dst-port=80 \
    to-addresses=192.168.4.1 \
    to-ports=80 \
    comment="Publica HTTP da DMZ"
```

Fluxo:

```text
              INTERNET
                  │
                  │ TCP/80
                  ▼
             IP público
                  │
                DNAT
                  │
                  ▼
          192.168.4.1:80
             Web Server
```

Depois disso, o `filter/forward` pode decidir se essa conexão será permitida.

---

# 🛡️ DMZ não é "liberar tudo"

Em um laboratório, liberar todas as portas pode ser útil para entender o funcionamento.

Porém, em produção, o ideal é permitir **somente os serviços necessários**.

Por exemplo, se o servidor é apenas Web:

```routeros
/ip/firewall/filter
add chain=forward \
    in-interface=ether1-WAN \
    dst-address=192.168.4.1 \
    protocol=tcp \
    dst-port=80,443 \
    action=accept \
    comment="Permite HTTP/HTTPS para DMZ"
```

Assim:

```text
TCP/80   → ACCEPT
TCP/443  → ACCEPT

TCP/22   → DROP
TCP/25   → DROP
TCP/3389 → DROP
...
```

Isso reduz a superfície de ataque.

---

# 🧱 DMZ x LAN

Uma das principais vantagens da DMZ é poder controlar o acesso entre o servidor público e a rede interna.

Exemplo:

```text
                 INTERNET
                     │
                     ▼
                ┌────────┐
                │ Router │
                └───┬────┘
                    │
              ┌─────┴─────┐
              │            │
             DMZ          LAN
              │            │
              ▼            ▼
         Web Server      PCs
        192.168.4.1   192.168.10.0/24
```

Uma política comum é:

```text
Internet → DMZ    permitido conforme necessidade
Internet → LAN    bloqueado
DMZ → LAN          bloqueado/restrito
LAN → DMZ          permitido somente quando necessário
LAN → Internet     permitido
```

Por exemplo, para impedir que a DMZ acesse a LAN:

```routeros
/ip/firewall/filter
add chain=forward \
    src-address=192.168.4.0/24 \
    dst-address=192.168.10.0/24 \
    action=drop \
    comment="Bloqueia DMZ para LAN"
```

---

# 🔍 Verificando as regras

Visualizar o firewall:

```routeros
/ip/firewall/filter/print
```

Ver os contadores:

```routeros
/ip/firewall/filter/print stats
```

Visualizar NAT:

```routeros
/ip/firewall/nat/print
```

---

# 🧠 Resumo

```text
DMZ
 ↓
Rede destinada a serviços que precisam ser publicados/acessados
```

No laboratório:

```routeros
/ip/firewall/filter
add chain=forward \
    dst-address=192.168.4.1 \
    action=accept
```

significa:

> **Permitir tráfego encaminhado cujo destino seja o servidor `192.168.4.1`, independentemente da porta/protocolo.**

Mas em produção:

```text
❌ Liberar todas as portas
        ↓
✅ Liberar somente os serviços necessários
```

---

## 🧩 Para memorizar

```text
DNAT
 ↓
"Para qual servidor interno devo enviar?"

FILTER
 ↓
"Esse tráfego pode passar?"

DMZ
 ↓
"Esse servidor pode ficar separado da LAN?"
```

Exemplo:

```text
Internet
   │
   │ TCP/443
   ▼
[ MikroTik ]
   │
   │ DNAT
   ▼
[ DMZ ]
192.168.4.1
   │
   │
   X──────► LAN
           192.168.10.0/24
```
