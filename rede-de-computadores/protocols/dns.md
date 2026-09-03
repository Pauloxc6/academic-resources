# 🌐 Consulta DNS

**DNS (Domain Name System)** é o sistema responsável por realizar a resolução de nomes em redes IP.

Ele permite associar **nomes de domínio a endereços IP** e, em determinados casos, realizar o processo inverso.

### 🔄 Resolução de nomes

```text
Nome → IP
```

Exemplo:

```text
backbox → 192.168.4.134
```

Também é possível realizar uma consulta reversa:

```text
IP → Nome
```

Exemplo:

```text
192.168.4.134 → backbox
```

> **Obs.:** o nome correto é **Domain Name System**, e não *Domain Name Server*. Um **DNS server** é o servidor que executa o serviço DNS.

---

# 📋 Registros DNS

Os registros DNS armazenam diferentes tipos de informações sobre um domínio ou host.

|  Nº | Registro  | Função                                                       |
| --: | --------- | ------------------------------------------------------------ |
| `1` | **A**     | Associa um nome a um endereço **IPv4**                       |
| `2` | **AAAA**  | Associa um nome a um endereço **IPv6**                       |
| `3` | **CNAME** | Cria um **alias (apelido)** para outro nome                  |
| `4` | **HINFO** | Fornece informações sobre o **host**                         |
| `5` | **MX**    | Define os servidores responsáveis pelo **e-mail** do domínio |
| `6` | **NS**    | Define os **servidores DNS autoritativos** do domínio        |
| `7` | **PTR**   | Utilizado na **resolução reversa** de IP para nome           |
| `8` | **SOA**   | Contém informações de **autoridade da zona DNS**             |

---

## 🔹 A — Address

Relaciona um nome de domínio ou host a um endereço **IPv4**.

```text
backbox.example.com → 192.168.4.134
```

Exemplo:

```dns
backbox    IN    A    192.168.4.134
```

---

## 🔹 AAAA — IPv6 Address

Relaciona um nome a um endereço **IPv6**.

```dns
server    IN    AAAA    2001:db8::10
```

---

## 🔹 CNAME — Canonical Name

Cria um **apelido** para outro nome DNS.

Exemplo:

```text
www.example.com → example.com
```

Registro:

```dns
www    IN    CNAME    example.com.
```

> O `CNAME` aponta para **outro nome**, não diretamente para um endereço IP.

---

## 🔹 HINFO — Host Information

Fornece informações sobre o host, como:

* CPU;
* sistema operacional.

Exemplo conceitual:

```dns
server    IN    HINFO    "Intel"    "Linux"
```

> Esse registro é pouco utilizado atualmente.

---

## 🔹 MX — Mail Exchange

Define quais servidores recebem e-mails destinados ao domínio.

Exemplo:

```dns
example.com.    IN    MX    10    mail.example.com.
```

O número `10` representa a **prioridade** do servidor.

Quanto **menor o número**, maior a prioridade.

Exemplo:

```text
10 → servidor principal
20 → servidor secundário
30 → servidor reserva
```

---

## 🔹 NS — Name Server

Indica quais servidores DNS são **autoritativos** para uma zona.

Exemplo:

```dns
example.com.    IN    NS    ns1.example.com.
example.com.    IN    NS    ns2.example.com.
```

---

## 🔹 PTR — Pointer

É utilizado para **resolução reversa**.

Enquanto o registro `A` realiza:

```text
Nome → IPv4
```

o `PTR` permite:

```text
IPv4 → Nome
```

Exemplo:

```text
192.168.4.134 → backbox.example.com
```

É utilizado em **zonas reversas**.

---

## 🔹 SOA — Start of Authority

O registro `SOA` contém informações importantes sobre a **autoridade e administração de uma zona DNS**.

Exemplo:

```dns
example.com. IN SOA ns1.example.com. admin.example.com. (
    2026090301 ; Serial
    3600       ; Refresh
    1800       ; Retry
    604800     ; Expire
    86400      ; Minimum
)
```

Entre as informações presentes estão:

* servidor DNS principal;
* responsável pela zona;
* número de série (**Serial**);
* intervalo de atualização (**Refresh**);
* intervalo de tentativa (**Retry**);
* tempo de expiração (**Expire**;
* valor relacionado ao cache negativo.

---

# 🔄 DNS direto x DNS reverso

### Consulta direta

Utiliza registros como `A` e `AAAA`.

```text
┌──────────────┐
│     Nome     │
│   backbox    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│      DNS     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│      IP      │
│ 192.168.4.134│
└──────────────┘
```

### Consulta reversa

Utiliza principalmente o registro `PTR`.

```text
┌──────────────┐
│      IP      │
│ 192.168.4.134│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│      DNS     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Nome     │
│   backbox    │
└──────────────┘
```

---

# 🧠 Resumo para memorizar

```text
A       → IPv4
AAAA    → IPv6
CNAME   → Alias
HINFO   → Informações do host
MX      → E-mail
NS      → Servidor DNS autoritativo
PTR     → Consulta reversa
SOA     → Autoridade da zona
```

### 🔑 Associação rápida

```text
A     = Address (IPv4)
AAAA  = IPv6
CNAME = Alias
MX    = Mail
NS    = Name Server
PTR   = Reverse
SOA   = Authority
```
