# Subnetting

| CIDR | Mascára de SubRede | Mascára Coringa | Nº Total de IPs | Nº Real de Ips |
| ---- | ------------------ | --------------- | --------------- | -------------- |
| /32  | 255.255.255.255    | 0.0.0.0         | 1               | 1              |
| /31  | 255.255.255.254    | 0.0.0.1         | 2               | 2*             |
| /30  | 255.255.255.252    | 0.0.0.3         | 4               | 2              |
| /29  | 255.255.255.248    | 0.0.0.7         | 8               | 6              |
| /28  | 255.255.255.240    | 0.0.0.15        | 16              | 14             |
| /27  | 255.255.255.224    | 0.0.0.31        | 32              | 30             |
| /26  | 255.255.255.192    | 0.0.0.63        | 64              | 62             |
| /25  | 255.255.255.128    | 0.0.0.127       | 128             | 126            |
| /24  | 255.255.255.0      | 0.0.0.255       | 256             | 254            |
| /23  | 255.255.254.0      | 0.0.1.255       | 512             | 510            |
| /22  | 255.255.252.0      | 0.0.3.255       | 1.024           | 1.022          |
| /21  | 255.255.248.0      | 0.0.7.255       | 2.048           | 2.046          |
| /20  | 255.255.240.0      | 0.0.15.255      | 4.096           | 4.094          |
| /19  | 255.255.224.0      | 0.0.31.255      | 8.192           | 8.910          |
| /18  | 255.255.192.0      | 0.0.63.255      | 16.384          | 16.382         |
| /17  | 255.255.128.0      | 0.0.127.255     | 32.768          | 32.766         |
| /16  | 255.255.0.0        | 0.0.255.255     | 65.536          | 65.534         |
| /15  | 255.254.0.0        | 0.1.255.255     | 131.072         | 131.070        |
| /14  | 255.252.0.0        | 0.3.255.255     | 262.144         | 262.142        |
| /13  | 255.248.0.0        | 0.7.255.255     | 524.288         | 524.286        |
| /12  | 255.240.0.0        | 0.15.255.255    | 1.048.576       | 1.048.574      |
| /11  | 255.224.0.0        | 0.31.255.255    | 2.097.152       | 2.097.150      |
| /10  | 255.192.0.0        | 0.63.255.255    | 4.194.304       | 4.194.302      |
| /9   | 255.128.0.0        | 0.127.255.255   | 8.388.608       | 8.388.606      |
| /8   | 255.0.0.0          | 0.255.255.255   | 16.777.216      | 16.777.214     |
| /7   | 254.0.0.0          | 1.255.255.255   | 33.554.432      | 33.554.430     |
| /6   | 252.0.0.0          | 3.255.255.255   | 67.108.864      | 67.108.862     |
| /5   | 248.0.0.0          | 7.255.255.255   | 134.217.728     | 134.217.726    |
| /4   | 240.0.0.0          | 15.255.255.255  | 268.435.456     | 268.435.454    |
| /3   | 224.0.0.0          | 31.255.255.255  | 536.870.912     | 536.870.910    |
| /2   | 192.0.0.0          | 63.255.255.255  | 1.073.741.824   | 1.073.741.822  |
| /1   | 128.0.0.0          | 127.255.255.255 | 2.147.483.648   | 2.147.483.646  |
| /0   | 0.0.0.0            | 255.255.255.255 | 4.294.967.296   | 4.294.967.294  |
### Fórmulas Rápidas de Validação

- **Máscara Coringa (Wildcard):** `255.255.255.255 - Máscara de Sub-rede`
- **Nº Total de IPs:** $2^{(32 - \text{CIDR})}$
- **Nº Real de IPs:** $\text{Nº Total de IPs} - 2$ _(1 para Endereço de Rede + 1 para Broadcast)_

---

# Entendendo CIDR, Máscaras e Sub-redes

Aqui está o seu texto explicativo e diagramas organizados em Markdown, mantendo a sua estrutura didática, comparações em binário e visualizações de rede:

## 1. O que é CIDR e Notação CIDR?

**CIDR** é a sigla para **Classless Inter-Domain Routing** (_Roteamento Interdomínios sem Classe_).

- **Surgimento:** Criado em 1993 para desacelerar o esgotamento dos endereços IPv4.
- **Objetivo:** Substituir o antigo sistema de endereçamento IP baseado em classes fixas (A, B e C), permitindo uma alocação de endereços muito mais flexível e eficiente.
- **Notação CIDR:** É a representação simplificada da máscara, indicada por uma barra (`/`) seguida do número de bits ligados (em nível `1`) dedicados à rede (exemplo: `/24`, `/16`, `/8`).

## 2. Como Funcionam as Máscaras de Sub-rede

A máscara de sub-rede funciona como um **filtro** para o endereço IP. Ela permite que os dispositivos identifiquem exatamente:

1. Quais bits pertencem à **Rede (Network)**.
2. Quais bits pertencem aos **Hosts (Máquinas)**.

Assim como os endereços IPv4, as máscaras possuem **32 bits** divididos em 4 octetos:

|**Formato**|**Endereço / Máscara**|**Representação em Binário**|
|---|---|---|
|**IP**|`192.168.0.101`|`11000000.10101000.00000000.01100101`|
|**Máscara**|`255.255.255.0`|`11111111.11111111.11111111.00000000`|

## 3. O que é uma Sub-rede e sua Importância

O uso de sub-redes cumpre dois papéis fundamentais na arquitetura de redes:

- **Divisão de Redes:** Permite segmentar redes grandes em redes menores (sub-redes) e gerenciáveis.
- **Identificação do Tráfego Local:** Permite que um dispositivo determine se o destino de um pacote está na mesma rede local ou se precisa passar pelo roteador para sair.
- **Economia de IPs Públicos:** Em uma rede de roteador Wi-Fi doméstico, por exemplo, apenas o roteador possui um endereço **IP Público** (atribuído pelo ISP), enquanto as máquinas internas compartilham essa conexão utilizando IPs privados na sub-rede.

## 4. Comparativo de Alinhamento (IP vs. Máscara)

```Plaintext
+--------------+-------------------------------------------------------------+
| IP           | 192.168.0.101  == 11000000.10101000.00000000.01100101        |
+--------------+-------------------------------------------------------------+
| Subnet Mask  | 255.255.255.0  == 11111111.11111111.11111111.00000000        |
+--------------+-------------------------------------------------------------+
| Divisão CIDR |                  [---- 24 Bits REDE ----] [ 8 Bits HOST ]    |
+--------------+-------------------------------------------------------------+
```


---
# RFC 1918: Endereços Privados, Públicos e NAT

Aqui está a sua anotação e esquema visual organizados e formatados em Markdown, mantendo exatamente a sua estrutura de raciocínio, mapas conceituais e definições:

## 1. Mapeamento e Topologia de Rede


```Plaintext
               /--- Google (8.8.8.8)
              /
        [INTERNET] BGP / NAT
       /                  \    
  () 2.2.2.2          () 1.1.1.1  (IPs Públicos)
   |                   |
  [ ]                 [ ]
   |                   |
  [ ]                 [ ]
  ---                 ---
192.168.10.1        192.168.10.1  (IPs Privados)
```

## 2. Tradução de Endereços (NAT - Header IP)

Na comunicação com a Internet, os pacotes têm seus endereços privados traduzidos para o IP público correspondente:

- **Pacote de Envio (Origem $\rightarrow$ Destino):** `[ 2.2.2.2 | 8.8.8.8 ]`
- **Pacote de Retorno (Origem $\rightarrow$ Destino):** `[ 8.8.8.8 | 2.2.2.2 ]`

## 3. Distribuição de Endereçamento (Hierarquia IANA)

|**Tipo de IP**|**Gerenciamento**|
|---|---|
|**Privado**|Não gerenciado pela IANA (Uso interno livre)|
|**Público**|Gerenciado globalmente pela IANA|

### Fluxo de Delegação (Exemplo Américas/Brasil)

$$\text{IANA} \longrightarrow \text{LACNIC} \longrightarrow \text{Registro.br} \longrightarrow \text{AS} \longrightarrow \text{Telecom} \longrightarrow \text{ISP}$$

- **RIRs (Regional Internet Registries):**
    - **ARIN:** América do Norte
    - **LACNIC:** América Latina e Caribe _(que delega para o Registro.br)_
    - **AFRINIC:** África
    - **RIPE NCC:** Europa, Oriente Médio e Ásia Central
    - **APNIC:** Ásia-Pacífico

## 4. Intervalos de IPs Privados (RFC 1918)

| **Classe** | **Intervalo de IPs**                | **CIDR** |
| ---------- | ----------------------------------- | -------- |
| **A**      | `10.0.0.0` até `10.255.255.255`     | **/8**   |
| **B**      | `172.16.0.0` até `172.31.255.255`   | **/12**  |
| **C**      | `192.168.0.0` até `192.168.255.255` | **/16**  |

---
# Classes de IP, Máscaras e Tipos de Envio

Aqui está o seu resumo organizado e formatado em Markdown, preservando a sua estrutura de raciocínio, desmistificação e esquemas visuais:

## 1. O Erro Comum: IP vs. Máscara de Sub-rede


```Plaintext
10.1.1.1        = Classe A
255.255.255.0   = Classe C  <-- ERRADO!
```

> **Atenção:** **Máscara de sub-rede NÃO tem classe!**
> Quem determina a Classe de um endereço IP é o seu **primeiro octeto**. A máscara apenas define a divisão de **N**etwork (Rede) e **H**ost (Máquina).

## 2. Máscaras Padrão (Padrão Classful)

- **Máscara /24:**

```Plaintext
255.255.255.0
----------- -
24N         8H
```

- **Máscara /16:** 

```Plaintext
255.255.0.0
------- ----
16N     16H
```

- **Máscara /8:**

```Plaintext
255.0.0.0
--- -----
8N   24H
```

## 3. Intervalo das Classes de IP (1º Octeto)

|**Intervalo**|**Classe**|**Porte / Utilização**|
|---|---|---|
|**0 – 127**|**A**|Grande porte|
|**128 – 191**|**B**|Médio porte|
|**192 – 223**|**C**|Pequeno porte|
|**224 – 239**|**D**|Multicast|
|**240 – 255**|**E**|Pesquisa / Reservado (Research)|

## 4. Tipos de Transmissão (Modos de Envio)

- **Unicast:** Comunicação direta de um ponto para outro ponto individual.

```Plaintext
[ ] --------> [ ]
```

- **Multicast:** Comunicação de um ponto para múltiplos destinos selecionados (um para vários).

```Plaintext
    /-------> [ ]
[ ]+------->  [ ]
    \-------> [ ]
```

---
# Subnetting em Classe C

**Rede base:** `192.168.10.0`
**Requisitos:** 4 Departamentos | 50 Hosts por departamento

### Cálculo de Bits e Máscara

Pela quantidade de bits conseguimos definir a quantidade de segmentações que podemos fazer:

Plaintext

```Plaintext
network ----------|--- hosts
192.168.10.0   0  | 0  0  0 0 0 0
           128 64 | 32 16 8 4 2 1
```

- **Bits tomados para a rede (2 bits):**
    - `.0` = `0 0`
    - `.64` = `0 1`
    - `.128` = `1 0`
    - `.192` = `1 1`
- **Endereço de rede (Máscara):** `255.255.255.192` ou **`/26`**

### Fórmulas e Regras de Contas

- **Network (Salto de Rede):**
    - $256 / 4 = 64$ → Primeiro endereço de rede (Tamanho do bloco/salto)
    - $256 - 64 = 192$ → Último endereço de rede
- **Broadcast:**
    - $\text{net} - 1$ = endereço de broadcast _(Ex: $64 - 1 = 63$)_
- **First Host (FH):**
    - $\text{net} + 1$ = endereço do primeiro host _(Ex: $0 + 1 = 1$ / $64 + 1 = 65$)_
- **Last Host (LH):**
    - $\text{ba} - 1$ = endereço do último host _(Ex: $63 - 1 = 62$)_

### Tabela da Rede

**Legenda:**

- **Net:** Network (Endereço de Rede)
- **FH:** First Host (Primeiro Host Válido)
- **LH:** Last Host (Último Host Válido)
- **Ba:** Broadcast (Endereço de Broadcast)

|**Sub-rede**|**Net**|**FH**|**LH**|**Ba**|
|---|---|---|---|---|
|**Rede 1**|0|1|62|63|
|**Rede 2**|64|65|126|127|
|**Rede 3**|128|129|190|191|
|**Rede 4**|192|193|254|255|

> **Caminho dos saltos:** $0 \xrightarrow{+64} 64 \xrightarrow{+64} 128 \xrightarrow{+64} 192$
## Dicas Práticas

- A última rede é sempre o valor final da máscara de sub-rede (Ex: **192**).
- Os saltos são sempre a soma do valor do último bit retido para a rede (Ex: **64**).
- Sempre os saltos entre redes, hosts e broadcasts serão iguais ao último bit da rede (Ex: **64**).

---

# Subnetting em Classe C

**Rede base:** `192.168.10.0`
**Requisitos:** 8 Departamentos | 20 Hosts por departamento

### Tabela de Bits e Sub-redes

|**Bits Tomados**|**Quantidade de Redes (2n)**|
|---|---|
|1|2|
|2|4|
|**3**|**8**|
|4|16|
|5|32|

### Divisão dos Octetos e Máscara

Pela quantidade de bits (3 bits emprestados para a rede), dividimos o octeto final:

```Plaintext
network                 hosts
---------------------|-----------------
192.168.10.0   0  0  | 0  0 0 0 0
           128 64 32 | 16 8 4 2 1
```

- **Soma dos bits de rede:** $128 + 64 + 32 = 224$
- **Endereço de rede (Máscara):** `255.255.255.224` ou **`/27`**
- **Tamanho do salto:** 32 _(valor do último bit de rede)

### Tabela da Rede

**Legenda:**

- **Net:** Network (Endereço de Rede)
- **FH:** First Host (Primeiro Host Válido)
- **LH:** Last Host (Último Host Válido)
- **Ba:** Broadcast (Endereço de Broadcast)

|**Sub-rede**|**Net**|**FH**|**LH**|**Ba**|
|---|---|---|---|---|
|**Rede 1**|0|1|30|31|
|**Rede 2**|32|33|62|63|
|**Rede 3**|64|65|94|95|
|**Rede 4**|96|97|126|127|
|**Rede 5**|128|129|158|159|
|**Rede 6**|160|161|190|191|
|**Rede 7**|192|193|222|223|
|**Rede 8**|224|225|254|255|

### Dicas Práticas

1. **Contagem de bits:** Identifique quantos bits precisa tomar emprestado para atender o número de redes (neste caso, 3 bits = 8 redes).
2. **Regra do +1, -1, -1:**  
    - $\text{FH} = \text{Net} + 1$
    - $\text{Ba} = \text{Próxima Net} - 1$
    - $\text{LH} = \text{Ba} - 1$
3. **Criar a tabela:** Monte a estrutura ordenando os intervalos com base no salto fixo (32).
4. **Validação:** A última rede sempre coincide exatamente com o valor final da máscara de sub-rede (**224**).

---

#  Subnetting em Classe B

**Rede base:** `172.16.0.0`
**Requisitos:** 4 Departamentos | 500 Hosts por departamento

## Tabela de Bits e Sub-redes

|**Bits Tomados**|**Quantidade de Redes (2n)**|
|---|---|
|1|2|
|**2**|**4**|
|3|8|
|4|16|
|5|32|

## Divisão dos Octetos e Máscara

Pela quantidade de bits (2 bits emprestados para a rede no 3º octeto), dividimos os octetos de host/rede:

```plaintext
network        | hosts
---------------+-------------------------------------
172.16.   0  0 | 0  0  0 0 0 0 . 0   0  0  0  0 0 0 0
        128 64 | 32 16 8 4 2 1   128 64 32 16 8 4 2 1
```

- **Soma dos bits de rede no 3º octeto:** $128 + 64 = 192$
- **Endereço de rede (Máscara):** `255.255.192.0` ou **`/18`**
- **Tamanho do salto:** 64 no 3º octeto _(valor do último bit de rede)_

## Tabela da Rede

**Legenda:**

- **Net:** Network (Endereço de Rede)
- **FH:** First Host (Primeiro Host Válido)
- **LH:** Last Host (Último Host Válido)
- **Ba:** Broadcast (Endereço de Broadcast)

|**Sub-rede**|**Net**|**FH**|**LH**|**Ba**|
|---|---|---|---|---|
|**Rede 1**|172.16.0.0|172.16.0.1|172.16.63.254|172.16.63.255|
|**Rede 2**|172.16.64.0|172.16.64.1|172.16.127.254|172.16.127.255|
|**Rede 3**|172.16.128.0|172.16.128.1|172.16.191.254|172.16.191.255|
|**Rede 4**|172.16.192.0|172.16.192.1|172.16.255.254|172.16.255.255|

## Dicas Práticas

1. **Contagem de bits:** Identifique quantos bits precisa tomar emprestado no 3º octeto (neste caso, 2 bits = 4 redes).
2. **Regra do +1, -1, -1 para Classe B:**
    - $\text{FH} = \text{Net} + 1$ no último octeto _(Ex: $0.0 \rightarrow 0.1$)_
    - $\text{Ba} = \text{Próxima Net} - 1$ _(Ex: $64.0 - 1 = 63.255$)_
    - $\text{LH} = \text{Ba} - 1$ no último octeto _(Ex: $63.255 - 1 = 63.254$)_
3. **Criar a tabela:** Monte a estrutura fazendo os saltos de 64 em 64 no 3º octeto.
4. **Validação:** A última rede sempre coincide exatamente com o valor correspondente na máscara de sub-rede (**192.0**).

---

# Subnetting em Classe A

**Rede base:** `10.0.0.0`
**Requisitos:** 8 Departamentos | 10.000 Hosts por departamento
## Tabela de Bits e Sub-redes

|**Bits Tomados**|**Quantidade de Redes (2n)**|
|---|---|
|1|2|
|2|4|
|**3**|**8**|
|4|16|
|5|32|

## Divisão dos Octetos e Máscara

Pela quantidade de bits (3 bits emprestados no 2º octeto para a rede), dividimos os octetos:

```Plaintext
network  | hosts
---------+----------------------------------------------------------------------
10.      | 0   0   0  | 0  0 0 0 0 . 0   0  0  0  0 0 0 0 . 0   0  0  0  0 0 0 0
         | 128 64  32 | 16 8 4 2 1   128 64 32 16 8 4 2 1   128 64 32 16 8 4 2 1
```

- **Cálculo da Máscara / Notação CIDR:** $8 \text{ (bits do 1º octeto)} + 3 \text{ (bits tomados)} = \mathbf{/11}$
- **Soma dos bits no 2º octeto:** $128 + 64 + 32 = 224$
- **Endereço de rede (Máscara):** `255.224.0.0` ou **`/11`**
- **Tamanho do salto:** 32 no 2º octeto _(valor do último bit de rede)_
## Tabela da Rede (Corrigida)

**Legenda:**

- **Net:** Network (Endereço de Rede)
- **FH:** First Host (Primeiro Host Válido)
- **LH:** Last Host (Último Host Válido)
- **Ba:** Broadcast (Endereço de Broadcast)

|**Sub-rede**|**Net**|**FH**|**LH**|**Ba**|
|---|---|---|---|---|
|**Rede 1**|10.0.0.0|10.0.0.1|10.31.255.254|10.31.255.255|
|**Rede 2**|10.32.0.0|10.32.0.1|10.63.255.254|10.63.255.255|
|**Rede 3**|10.64.0.0|10.64.0.1|10.95.255.254|10.95.255.255|
|**Rede 4**|10.96.0.0|10.96.0.1|10.127.255.254|10.127.255.255|
|**Rede 5**|10.128.0.0|10.128.0.1|10.159.255.254|10.159.255.255|
|**Rede 6**|10.160.0.0|10.160.0.1|10.191.255.254|10.191.255.255|
|**Rede 7**|10.192.0.0|10.192.0.1|10.223.255.254|10.223.255.255|
|**Rede 8**|10.224.0.0|10.224.0.1|10.255.255.254|10.255.255.255|

## Dicas Práticas

1. **Contagem de bits:** Identifique quantos bits precisa tomar emprestado no 2º octeto (neste caso, 3 bits = 8 redes).
2. **Regra do +1, -1, -1 para Classe A:**  
    - $\text{FH} = \text{Net} + 1$ no último octeto _(Ex: $0.0.0 \rightarrow 0.0.1$)_
    - $\text{Ba} = \text{Próxima Net} - 1$ _(Ex: $32.0.0 - 1 = 31.255.255$)_
    - $\text{LH} = \text{Ba} - 1$ no último octeto _(Ex: $31.255.255 - 1 = 31.255.254$)_
3. **Criar a tabela:** Monte a estrutura fazendo os saltos de 32 em 32 no 2º octeto.
4. **Validação:** A última rede sempre coincide exatamente com o valor correspondente na máscara de sub-rede (**224.0.0**).