# 🌐 Restrições de Banda por URL

O **Mangle** pode ser utilizado para identificar determinados tráfegos e aplicar uma política de banda específica por meio de **marcação de conexão**, **marcação de pacotes** e **Queues**.

Neste exemplo, o objetivo é identificar tráfego relacionado ao termo `globo` e limitar sua velocidade a **10 Mbps**.

---

## 🔄 Fluxo

```text
                    Tráfego
                       │
                       ▼
                  PREROUTING
                       │
                       ▼
                 content=globo
                       │
                       ▼
              connection-mark
                  GloboCON
                       │
                       ▼
                packet-mark
                  Globo-PAC
                       │
                       ▼
                Simple Queue
                       │
                       ▼
                 10 Mbps
```

---

# 1. Marcando a conexão

```routeros
/ip firewall mangle add \
    chain=prerouting \
    action=mark-connection \
    new-connection-mark=GloboCON \
    passthrough=yes \
    content=globo
```

Essa regra procura o conteúdo `globo` nos pacotes processados pelo `prerouting`.

Quando encontra uma correspondência, a conexão recebe:

```text
connection-mark=GloboCON
```

### Principais parâmetros

| Parâmetro                      | Função                                                           |
| ------------------------------ | ---------------------------------------------------------------- |
| `chain=prerouting`             | Processa os pacotes antes da decisão de roteamento               |
| `content=globo`                | Procura o texto `globo` no conteúdo do pacote                    |
| `action=mark-connection`       | Marca a conexão                                                  |
| `new-connection-mark=GloboCON` | Nome da marca criada                                             |
| `passthrough=yes`              | Permite que o pacote continue sendo processado por outras regras |

---

# 2. Marcando os pacotes

Depois de identificar a conexão, podemos marcar os pacotes pertencentes a ela:

```routeros
/ip firewall mangle add \
    chain=prerouting \
    action=mark-packet \
    new-packet-mark=Globo-PAC \
    passthrough=no \
    connection-mark=GloboCON
```

Agora:

```text
Conexão
   │
   └── GloboCON
          │
          ▼
       Pacotes
          │
          └── Globo-PAC
```

A marca `Globo-PAC` será utilizada pela Queue.

---

# 3. Aplicando o limite

```routeros
/queue simple add \
    name="Retricao globo.com" \
    target=ether1,ether4 \
    packet-marks=Globo-PAC \
    max-limit=10M/10M
```

A Simple Queue procura os pacotes que possuem:

```text
packet-mark=Globo-PAC
```

e limita a banda a:

```text
Download: 10 Mbps
Upload:   10 Mbps
```

---

# ⚠️ Atenção ao `content`

Apesar do nome da anotação ser **"Restrições de Banda por URL"**, o parâmetro:

```routeros
content=globo
```

**não é um filtro de URL propriamente dito**.

Ele procura uma sequência de caracteres no conteúdo dos pacotes.

Antigamente isso podia funcionar em determinados acessos HTTP, por exemplo:

```text
GET /noticias HTTP/1.1
Host: globo.com
```

Mas atualmente grande parte do tráfego web utiliza **HTTPS**, o que impede o roteador de enxergar o conteúdo HTTP criptografado.

Portanto:

```text
HTTP
 │
 └── conteúdo pode ser inspecionado
          ↓
       content=globo
```

Enquanto:

```text
HTTPS
 │
 └── conteúdo criptografado
          ↓
       content=globo
       pode não encontrar
```

Além disso, `content` pode consumir bastante processamento, especialmente quando usado em grande quantidade de tráfego.

---

# 🌐 Não confundir com bloqueio por domínio

Esta regra:

```routeros
content=globo
```

não significa:

```text
"qualquer acesso a globo.com"
```

Ela significa aproximadamente:

```text
"procure a sequência 'globo' no conteúdo visível do pacote"
```

Para políticas modernas baseadas em domínio, existem abordagens diferentes, como **listas de endereços/IPs**, **DNS**, **TLS SNI quando aplicável** ou mecanismos específicos de classificação de tráfego.

---

# 🧠 Funcionamento completo

```text
┌───────────────────────┐
│       Cliente         │
└───────────┬───────────┘
            │
            ▼
      Firewall Mangle
            │
            │ content=globo
            ▼
      ┌──────────────┐
      │ GloboCON     │
      │ Connection   │
      │ Mark         │
      └──────┬───────┘
             │
             ▼
      ┌──────────────┐
      │ Globo-PAC    │
      │ Packet Mark  │
      └──────┬───────┘
             │
             ▼
      ┌──────────────┐
      │ Simple Queue │
      │              │
      │ 10 Mbps      │
      └──────────────┘
```

---

# 📌 Resumo

| Etapa | Configuração             | Função                               |
| ----- | ------------------------ | ------------------------------------ |
| 1     | `content=globo`          | Identifica o conteúdo correspondente |
| 2     | `GloboCON`               | Marca a conexão                      |
| 3     | `Globo-PAC`              | Marca os pacotes                     |
| 4     | `packet-marks=Globo-PAC` | Seleciona os pacotes na Queue        |
| 5     | `max-limit=10M/10M`      | Limita a banda                       |

### Para memorizar

```text
CONTENT
   ↓
Connection Mark
   ↓
Packet Mark
   ↓
Queue
   ↓
Limitação de banda
```

> 💡 **Importante:** para um laboratório didático, `content=globo` é ótimo para demonstrar a ideia de classificação. Para controlar tráfego web moderno por domínio, porém, não é uma solução confiável por causa principalmente do **HTTPS e da criptografia**.
