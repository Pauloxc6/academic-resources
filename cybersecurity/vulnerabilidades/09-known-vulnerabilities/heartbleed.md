🔐 **Heartbleed (CVE-2014-0160)**

### 🧠 O que é Heartbleed?

**Heartbleed** foi uma vulnerabilidade na biblioteca criptográfica **OpenSSL**, causada por uma falha na implementação da extensão **Heartbeat** do protocolo TLS.

A vulnerabilidade permitia que um atacante enviasse uma requisição especialmente criada e fizesse o servidor retornar **dados além dos limites esperados da memória**.

Esses dados poderiam conter informações sensíveis, como:

- Cookies de sessão;
- Credenciais;
- Tokens;
- Dados de requisições;
- Informações de outros usuários;
- Fragmentos de chaves privadas em determinadas condições.

⚠️ O Heartbleed **não é uma falha de quebra da criptografia TLS**. O problema estava na leitura indevida da memória pelo OpenSSL.

---

## ⚙️ Como funciona?

O Heartbeat permite que um cliente envie uma mensagem informando o tamanho de um bloco de dados.

Em uma implementação vulnerável, o OpenSSL não verificava corretamente se o tamanho declarado correspondia ao tamanho real dos dados enviados.

Exemplo conceitual:

```text
Dados enviados:
[ "AAAA" ]

Tamanho declarado:
[ 64 bytes ]

                ↓

OpenSSL vulnerável

                ↓

Retorna:
[ "AAAA" + dados existentes na memória ]
```

💥 Assim, o atacante poderia receber conteúdo que deveria permanecer na memória do processo.

---

## 🎯 Impacto

O impacto dependia do conteúdo presente na memória no momento da exploração.

Um ataque bem-sucedido poderia revelar:

```text
Memória do processo
        │
        ├── Cookies
        ├── Senhas
        ├── Tokens
        ├── Dados de requisições
        └── Possíveis informações criptográficas
```

A possibilidade de recuperação de **chaves privadas TLS** foi uma das maiores preocupações relacionadas ao Heartbleed.

---

## 🔎 Identificação

Uma forma de verificar um servidor autorizado é utilizar ferramentas de teste de TLS que possuam verificação para Heartbleed.

```bash
sslyze --heartbleed <alvo>
```

Por exemplo:

```bash
sslyze --heartbleed 192.168.1.100:443
```

---

## 🧪 Exploração

Existiam ferramentas e PoCs que automatizavam o envio da requisição Heartbeat malformada.

Exemplo:

```bash
python heartbleed.py <alvo>
```

Algumas implementações de PoC permitem alterar o tamanho utilizado no teste, por exemplo:

```text
0x40
0x10
0x20
0xff
```

📌 O tamanho utilizado depende da implementação da ferramenta e do objetivo do teste. Não é necessário aumentar arbitrariamente o valor para confirmar a vulnerabilidade.

---

## 🧩 Informações importantes

**CVE:** `CVE-2014-0160`

**Software afetado:** versões vulneráveis do **OpenSSL**

**Categoria:** falha de leitura de memória / divulgação de informações

**Apelido:** Heartbleed

---

## 🔐 Correção

A correção consiste em:

1. Atualizar o OpenSSL para uma versão corrigida;
2. Reiniciar os serviços que utilizam a biblioteca;
3. Invalidar/renovar certificados quando houver possibilidade de comprometimento da chave privada;
4. Revogar certificados antigos quando apropriado;
5. Alterar credenciais e tokens potencialmente expostos;
6. Verificar logs e indicadores de exploração.

📌 **Resumo:**

> **Heartbleed = leitura indevida da memória de processos que utilizavam uma versão vulnerável do OpenSSL, podendo expor informações sensíveis.**