# 🔄 Efetuando um Peer Refresh

O **Peer Refresh** é utilizado para solicitar que uma sessão BGP **reavalie ou atualize as rotas**, sendo útil após alterações em políticas de roteamento, filtros ou outros parâmetros que afetem os anúncios.

Com isso, podemos atualizar o processamento das rotas sem necessariamente reiniciar a sessão BGP.

---

## ⚙️ Comando

```bash
/routing bgp session refresh numbers=0 address-family=ip
```

### Parâmetros

| Parâmetro           | Função                                         |
| ------------------- | ---------------------------------------------- |
| `session`           | Trabalha com as sessões BGP estabelecidas      |
| `refresh`           | Solicita o refresh da sessão                   |
| `numbers=0`         | Seleciona a sessão BGP de índice `0`           |
| `address-family=ip` | Realiza o refresh da família de endereços IPv4 |

---

## 🧠 Para que serve?

Imagine que você alterou um filtro:

```text
Antes:

BGP
 │
 ├── Rede A → ACCEPT
 ├── Rede B → ACCEPT
 └── Rede C → ACCEPT
```

Depois você altera a política:

```text
BGP
 │
 ├── Rede A → ACCEPT
 ├── Rede B → REJECT
 └── Rede C → ACCEPT
```

Em vez de derrubar a sessão BGP:

```text
BGP SESSION
     │
     ├── DOWN
     │
     └── UP
```

podemos utilizar o **refresh** para solicitar a atualização das rotas:

```text
BGP SESSION
     │
     ▼
   REFRESH
     │
     ▼
Reprocessamento das rotas
     │
     ▼
Novas políticas aplicadas
```

---

## 🔄 Hard Reset × Peer Refresh

É importante diferenciar os dois.

### Hard Reset

A sessão é encerrada e estabelecida novamente:

```text
ESTABLISHED
     │
     ▼
   DOWN
     │
     ▼
   OPEN
     │
     ▼
ESTABLISHED
```

Isso interrompe temporariamente a sessão e pode causar impacto no roteamento.

### Peer Refresh

A sessão permanece estabelecida e ocorre uma atualização das informações:

```text
ESTABLISHED
     │
     ▼
  REFRESH
     │
     ▼
Atualização das rotas
     │
     ▼
ESTABLISHED
```

Por isso, o refresh é geralmente preferível quando a alteração realizada permite esse mecanismo.

---

## 📌 Quando utilizar?

O Peer Refresh pode ser útil após alterações como:

* filtros BGP;
* políticas de importação;
* políticas de exportação;
* atributos de rotas;
* anúncios de prefixos;
* outras políticas que precisem ser reaplicadas.

Por exemplo:

```text
Alterou filtro
      ↓
Peer Refresh
      ↓
BGP reprocessa/atualiza
      ↓
Novas políticas entram em efeito
```

---

## 🧪 Exemplo

Primeiro verificamos as sessões:

```bash
/routing bgp session print
```

Depois executamos o refresh na sessão `0`:

```bash
/routing bgp session refresh numbers=0 address-family=ip
```

E podemos verificar novamente:

```bash
/routing bgp session print
```

---

# 🧠 Para memorizar

```text
Peer Refresh
     ↓
Atualiza a sessão BGP
     ↓
Sem precisar fazer um hard reset
```

```text
Hard Reset
→ derruba a sessão
→ estabelece novamente
```

```text
Peer Refresh
→ mantém a sessão
→ atualiza/reprocessa informações
```

> ⚠️ O efeito exato do refresh depende do mecanismo de route refresh suportado pela sessão e pela família de endereços. Em BGP, **Route Refresh** é justamente o mecanismo padronizado para permitir que um peer solicite novamente as rotas sem reiniciar a sessão.
