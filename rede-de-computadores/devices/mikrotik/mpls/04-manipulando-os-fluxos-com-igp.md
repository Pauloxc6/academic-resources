# 04 — Manipulando os Fluxos com IGP

Nesta etapa vamos utilizar o **custo do OSPF** para influenciar o caminho escolhido pelo protocolo IGP.

O **OSPF (Open Shortest Path First)** utiliza o custo das interfaces para calcular o melhor caminho até determinado destino.

---

# 🧠 Conceito

O OSPF procura o caminho com o **menor custo total**.

Por exemplo:

```text
PE1 ── 2 ── P1 ── 10 ── P2
 │
 └──── 20 ───────────── P2
```

Para chegar ao P2:

```text
PE1 → P1 → P2
2 + 10 = 12
```

Caminho direto:

```text
PE1 → P2
20
```

O OSPF escolherá:

```text
12 < 20

PE1 → P1 → P2
```

---

# 📌 Alterando o custo no PE1

No PE1:

```routeros
/routing ospf interface-template set 0 cost=2
```

Esse comando altera o **custo OSPF** associado ao `interface-template` de índice `0`.

### Parâmetros

| Parâmetro                         | Função                                    |
| --------------------------------- | ----------------------------------------- |
| `routing ospf interface-template` | Acessa os templates de interfaces do OSPF |
| `set 0`                           | Modifica o template de índice `0`         |
| `cost=2`                          | Define o custo OSPF como `2`              |

> ⚠️ O `0` é o **índice do template**, não necessariamente uma interface. Em configurações reais, é mais seguro conferir primeiro com `print` para garantir que o índice corresponde ao enlace desejado.

```routeros
/routing ospf interface-template print
```

---

# 🔀 Manipulando o fluxo

O custo pode ser utilizado para fazer o OSPF preferir um caminho em relação a outro.

Imagine:

```text
                 P1
                /  \
               /    \
             10      10
             /        \
           PE1         P2
             \        /
              \      /
                30
```

Se o caminho PE1 → P1 → P2 possui:

```text
10 + 10 = 20
```

e o caminho direto possui:

```text
30
```

o OSPF prefere:

```text
PE1 → P1 → P2
```

Se aumentarmos o custo do enlace PE1 → P1:

```text
PE1 ── 50 ── P1
```

teremos:

```text
50 + 10 = 60
```

Nesse caso:

```text
30 < 60
```

e o caminho direto passa a ser preferido.

---

# 🎯 O objetivo

Alterando o custo OSPF, podemos **influenciar o caminho utilizado pelo tráfego dentro do domínio IGP**.

Isso é útil para:

* preferir determinados enlaces;
* evitar enlaces congestionados;
* controlar o caminho utilizado pelo tráfego;
* criar caminhos primários e alternativos;
* realizar engenharia básica de tráfego dentro do IGP.

---

# 🔍 Verificando

Antes de alterar:

```routeros
/routing ospf interface-template print
```

Depois:

```routeros
/routing ospf interface-template print detail
```

Também podemos verificar as rotas calculadas:

```routeros
/ip route print
```

E os vizinhos OSPF:

```routeros
/routing ospf neighbor print
```

---

# ⚠️ Atenção ao cenário

No material desta etapa, apenas o PE1 possui uma alteração explícita:

```routeros
/routing ospf interface-template set 0 cost=2
```

Não há configuração adicional informada para P1 e P2.

Isso **não significa que P1 e P2 precisem necessariamente de um comando**. O custo pode ser alterado apenas no enlace que queremos influenciar.

Entretanto, é importante identificar exatamente qual interface/template corresponde ao índice `0` antes de aplicar a alteração:

```routeros
/routing ospf interface-template print
```

---

# 🧠 IGP x MPLS

É importante separar os papéis:

```text
                OSPF
                  │
                  ▼
          Calcula o caminho IP
                  │
                  ▼
             LDP / MPLS
                  │
                  ▼
        Distribuição/uso de labels
```

O **OSPF decide o caminho IP** que será utilizado como base para a infraestrutura.

O **MPLS/LDP utiliza essa infraestrutura para estabelecer o encaminhamento baseado em labels**.

Portanto, ao modificar o custo OSPF, você pode alterar indiretamente o caminho utilizado pelo tráfego MPLS.

---

# 📌 Resumo

```text
Custo menor
     ↓
Maior preferência

Custo maior
     ↓
Menor preferência
```

Exemplo:

```text
Caminho A = 10
Caminho B = 30

OSPF → prefere A
```

Se alterarmos:

```text
Caminho A = 40
Caminho B = 30

OSPF → prefere B
```

### Para memorizar

> **OSPF escolhe o caminho de menor custo.**

E no contexto deste laboratório:

```text
IGP (OSPF)
     ↓
Define o melhor caminho
     ↓
MPLS/LDP
     ↓
Utiliza a infraestrutura para o encaminhamento por labels
```
