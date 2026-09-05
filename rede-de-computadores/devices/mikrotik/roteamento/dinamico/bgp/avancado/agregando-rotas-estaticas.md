# 🧩 Agregando rotas estáticas

A **agregação de rotas** consiste em representar várias redes menores através de um único prefixo maior.

Neste laboratório utilizaremos uma rota mais específica para `Null0` e uma rota agregada `/23` apontando para o outro roteador.

---

# 📚 Conceito

Imagine que temos duas redes:

```text
100.100.100.0/24
100.100.101.0/24
```

Podemos agregá-las em:

```text
100.100.100.0/23
```

Porque:

```text
100.100.100.0/23
        │
        ├── 100.100.100.0/24
        └── 100.100.101.0/24
```

A máscara `/23` possui:

```text
255.255.254.0
```

Portanto, ela cobre os terceiros octetos:

```text
100
101
```

---

# 🖥️ R1

Endereço utilizado:

```text
100.100.100.1
```

Criamos uma interface lógica chamada `null0`:

```bash id="2xg1mx"
/interface bridge add name=null0
```

Depois criamos uma rota para a rede específica:

```bash id="c8v6nw"
/ip route add dst-address=100.100.100.0/24 gateway=null0
```

E a rota agregada:

```bash id="9r4k2m"
/ip route add dst-address=100.100.100.0/23 gateway=192.168.122.5
```

---

# 🖥️ R2

Endereço utilizado:

```text
100.100.100.2
```

Criamos também a interface lógica:

```bash id="q7x5sp"
/interface bridge add name=null0
```

Rota específica:

```bash id="v8m2za"
/ip route add dst-address=100.100.100.0/24 gateway=null0
```

Rota agregada:

```bash id="k4n6yp"
/ip route add dst-address=100.100.100.0/23 gateway=192.168.122.2
```

---

# 🕳️ Por que utilizar Null0?

A interface `Null0` é utilizada como uma espécie de **"interface de descarte"**.

Quando um pacote é encaminhado para ela, ele é descartado.

```text
                Null0
                  │
                  ▼
               DESCARTE
```

Isso pode ser útil na agregação para evitar **loops de roteamento**.

Por exemplo, o roteador possui:

```text
100.100.100.0/23 → 192.168.122.5
```

mas também possui:

```text
100.100.100.0/24 → Null0
```

Como `/24` é mais específico que `/23`, um pacote destinado a:

```text
100.100.100.X
```

corresponderá primeiro à rota `/24`.

```text
Destino
   │
   ▼
100.100.100.0/24
   │
   ▼
 Null0
   │
   ▼
Descarte
```

Já destinos pertencentes à outra metade do `/23`, por exemplo:

```text
100.100.101.X
```

podem utilizar a rota agregada:

```text
100.100.100.0/23
        │
        ▼
192.168.122.5
```

---

# 🎯 Longest Prefix Match

Esse exemplo também demonstra um conceito fundamental do roteamento:

> **A rota mais específica vence.**

Considere:

```text
100.100.100.0/24
100.100.100.0/23
```

Para um destino:

```text
100.100.100.10
```

as duas rotas podem corresponder.

Porém:

```text
/24 > /23
```

Então o roteador escolhe:

```text
100.100.100.0/24
```

e não:

```text
100.100.100.0/23
```

Visualmente:

```text
              Destino
                 │
                 ▼
       ┌──────────────────┐
       │ 100.100.100.10   │
       └────────┬─────────┘
                │
        ┌───────┴────────┐
        │                │
      /24              /23
        │                │
        ▼                ▼
      Null0          Gateway
```

A rota `/24` ganha por ser mais específica.

---

# 🔄 Topologia

```text
                 192.168.122.0/24
          ┌──────────────────────────┐
          │                          │
          ▼                          ▼
     ┌─────────┐                ┌─────────┐
     │   R1    │                │   R2    │
     │         │                │         │
     │100.100. │                │100.100. │
     │100.1    │                │100.2    │
     └─────────┘                └─────────┘
          │                          │
          │                          │
     Null0                      Null0
```

As rotas agregadas apontam uma para a outra:

```text
R1
100.100.100.0/23
        │
        ▼
192.168.122.5
        │
        ▼
       R2
```

E:

```text
R2
100.100.100.0/23
        │
        ▼
192.168.122.2
        │
        ▼
       R1
```

---

# ⚠️ Um detalhe importante do exemplo

Existe uma particularidade nessa configuração:

Os próprios roteadores possuem endereços:

```text
R1 → 100.100.100.1
R2 → 100.100.100.2
```

e ambos criam:

```text
100.100.100.0/24 → Null0
```

Isso significa que o tráfego destinado a esses endereços pode ser afetado pela rota `/24` de descarte.

Em um cenário real, normalmente a agregação seria feita sobre **prefixos que não são simultaneamente utilizados como rede diretamente conectada no próprio roteador**, ou a configuração seria desenhada cuidadosamente para evitar esse conflito.

---

# 🧠 Para memorizar

```text
Agregação
    ↓
Várias redes
    ↓
Um prefixo maior
```

Exemplo:

```text
100.100.100.0/24
100.100.101.0/24
          ↓
100.100.100.0/23
```

```text
Null0
    ↓
Interface de descarte
    ↓
Ajuda a evitar loops em determinados cenários
```

```text
/24
 ↓
Mais específico

/23
 ↓
Menos específico
```

### Regra principal

```text
Quanto maior o prefixo,
mais específica é a rota.

/32 → mais específico
/24
/23
/16
/8
/0  → menos específico
```

---

# 📋 Configuração completa

## R1

```bash id="p3j8lw"
/interface bridge add name=null0

/ip route add \
    dst-address=100.100.100.0/24 \
    gateway=null0

/ip route add \
    dst-address=100.100.100.0/23 \
    gateway=192.168.122.5
```

## R2

```bash id="x6r2nc"
/interface bridge add name=null0

/ip route add \
    dst-address=100.100.100.0/24 \
    gateway=null0

/ip route add \
    dst-address=100.100.100.0/23 \
    gateway=192.168.122.2
```

---

# 🔎 Verificação

Podemos verificar as rotas com:

```bash id="e8m5ks"
/ip route print
```

Ou especificamente:

```bash id="d3v9qa"
/ip route print where dst-address in 100.100.100.0/23
```

Também podemos testar a conectividade:

```bash id="n7c4wf"
/ping 100.100.100.1
/ping 100.100.100.2
```

> **Resumo:** agregação reduz a quantidade de prefixos que precisam ser anunciados ou mantidos, enquanto o `Null0` pode ser utilizado como rota de descarte para o prefixo agregado ou para evitar loops em determinadas arquiteturas. A escolha da rota é feita pelo princípio de **Longest Prefix Match**.
