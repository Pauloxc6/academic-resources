# 🖥️ SMB

**SMB (Server Message Block)** é um protocolo de rede da **camada de aplicação** utilizado principalmente para permitir o compartilhamento de recursos entre computadores em uma rede.

Ele é muito associado a ambientes **Windows**, mas também pode ser utilizado em sistemas Linux e Unix por meio de implementações como o **Samba**.

> **CIFS (Common Internet File System)** é uma implementação/variante antiga do SMB, baseada no SMB 1.0. Atualmente, o termo SMB é mais utilizado para as versões modernas do protocolo.

---

# 📌 Para que serve o SMB?

O SMB permite compartilhar diversos tipos de recursos pela rede:

* 📁 Arquivos e diretórios;
* 🖨️ Impressoras;
* 🔌 Portas e dispositivos;
* 🔐 Recursos autenticados;
* 💻 Comunicação entre processos (**IPC — Inter-Process Communication**).

Exemplo:

```text
              Rede
                │
        ┌───────┴───────┐
        │               │
      Cliente         Servidor
      Windows           SMB
        │               │
        └───────┬───────┘
                │
          Pasta compartilhada
```

O cliente pode acessar uma pasta compartilhada no servidor como se fosse um recurso de rede.

---

# 🌐 Funcionamento

De forma simplificada:

```text
Cliente
   │
   │ Solicitação SMB
   ▼
Servidor SMB
   │
   ├── Autenticação
   ├── Verificação de permissões
   └── Acesso ao recurso
```

O servidor controla quais recursos estão disponíveis e quais usuários possuem permissão para acessá-los.

---

# 🔌 Portas

As portas mais importantes relacionadas ao SMB são:

| Porta       | Protocolo | Uso                               |
| ----------- | --------- | --------------------------------- |
| **445/TCP** | TCP       | SMB diretamente sobre TCP/IP      |
| **139/TCP** | TCP       | SMB sobre NetBIOS Session Service |
| **137/UDP** | UDP       | NetBIOS Name Service              |
| **138/UDP** | UDP       | NetBIOS Datagram Service          |

### ⭐ Porta mais importante

Em redes modernas, a porta mais relevante é:

```text
TCP/445
```

Ela permite o uso do **SMB diretamente sobre TCP/IP**, sem depender do NetBIOS.

---

# 📦 Versões do SMB

O SMB passou por diversas versões.

```text
SMB 1.0
   ↓
SMB 2.0
   ↓
SMB 2.1
   ↓
SMB 3.0
   ↓
SMB 3.0.2
   ↓
SMB 3.1.1
```

## SMB 1.0

É uma versão antiga e atualmente considerada **insegura/obsoleta**.

Um dos motivos mais conhecidos para evitar SMBv1 foi a existência de vulnerabilidades graves em implementações do protocolo.

> **SMBv1 deve ser desabilitado quando não houver necessidade de compatibilidade com sistemas legados.**

---

## SMB 2.x

Trouxe diversas melhorias em relação ao SMBv1, incluindo:

* redução de operações;
* melhor desempenho;
* melhorias no gerenciamento de conexões;
* maior eficiência em redes de alta latência.

---

## SMB 3.x

Introduziu recursos importantes para ambientes modernos, como:

* **SMB Encryption**;
* **SMB Multichannel**;
* **SMB Direct**;
* melhorias de segurança;
* melhorias de desempenho;
* suporte a cenários de alta disponibilidade.

---

# 🔐 Autenticação

O SMB pode utilizar mecanismos de autenticação para controlar o acesso aos recursos.

Em ambientes Windows, é comum encontrar:

```text
Cliente
   │
   │ Credenciais
   ▼
Servidor / Active Directory
   │
   ▼
Autenticação
   │
   ▼
Acesso ao compartilhamento
```

Em ambientes corporativos, o SMB pode estar integrado ao **Active Directory**.

---

# 📂 Compartilhamentos SMB

Um recurso compartilhado pode ser acessado utilizando um caminho UNC:

```text
\\SERVIDOR\COMPARTILHAMENTO
```

Exemplo:

```text
\\192.168.1.10\documentos
```

Onde:

```text
192.168.1.10 → servidor
documentos   → nome do compartilhamento
```

---

# 🐧 SMB no Linux

Em Linux, uma das implementações mais conhecidas é o **Samba**.

O Samba permite que um sistema Linux:

* forneça compartilhamentos SMB;
* acesse compartilhamentos Windows;
* participe de ambientes Active Directory;
* funcione como servidor de arquivos;
* forneça serviços de impressão.

Exemplo:

```text
Windows
   │
   │ SMB
   ▼
Linux + Samba
   │
   └── /srv/arquivos
```

---

# 🔎 SMB em Pentest

O SMB é um protocolo extremamente interessante durante um **pentest interno**, principalmente porque pode revelar informações sobre a infraestrutura.

A primeira coisa normalmente observada é:

```text
TCP/445
```

Exemplo de enumeração básica:

```bash
nmap -p 445 192.168.1.10
```

Para identificar informações do serviço:

```bash
nmap -p 445 --script smb-protocols 192.168.1.10
```

Para verificar informações sobre o servidor:

```bash
nmap -p 445 --script smb-os-discovery 192.168.1.10
```

Para enumerar compartilhamentos:

```bash
nmap -p 445 --script smb-enum-shares 192.168.1.10
```

---

# 📋 Informações que podem ser encontradas

Dependendo da configuração do servidor, a enumeração SMB pode revelar:

* nome do computador;
* domínio;
* grupo de trabalho;
* versão/protocolo SMB;
* sistema operacional;
* compartilhamentos;
* usuários;
* políticas de acesso;
* informações sobre o servidor.

```text
                 SMB
                  │
        ┌─────────┴─────────┐
        │                   │
     Serviço             Recursos
        │                   │
   ┌────┴────┐        ┌─────┴─────┐
   │         │        │           │
 Versão     SO     Shares       IPC
```

---

# ⚠️ SMB e segurança

Uma configuração SMB inadequada pode resultar em problemas como:

* compartilhamentos públicos;
* permissões excessivas;
* autenticação fraca;
* exposição de informações;
* uso de SMBv1;
* credenciais comprometidas;
* movimentação lateral em redes internas.

Um dos riscos mais conhecidos historicamente foi o conjunto de vulnerabilidades associado ao **SMBv1**, incluindo o **EternalBlue**.

> A existência da porta **445 aberta não significa automaticamente que o servidor está vulnerável**. É necessário identificar a versão, configuração e vulnerabilidades específicas.

---

# 🧠 SMB vs CIFS

| SMB                                                     | CIFS                                             |
| ------------------------------------------------------- | ------------------------------------------------ |
| Nome utilizado para o protocolo e suas versões modernas | Variante/implementação antiga baseada no SMB 1.0 |
| Utilizado atualmente                                    | Legado                                           |
| SMB 2.x/3.x                                             | SMB 1.0                                          |
| Melhor desempenho e segurança                           | Mais limitado e inseguro                         |

---

# 🔗 SMB e NetBIOS

É importante não confundir os dois.

### SMB

É o protocolo responsável pelo **compartilhamento de recursos**.

### NetBIOS

É um conjunto de serviços/protocolos de rede historicamente utilizado para comunicação e descoberta de nomes em redes Windows.

Em sistemas antigos:

```text
SMB
 ↓
NetBIOS
 ↓
TCP/IP
```

Em redes modernas:

```text
SMB
 ↓
TCP/IP
 ↓
TCP/445
```

---

# 🧠 Para memorizar

> **SMB = compartilhamento de recursos em rede.**

```text
SMB
│
├── 📁 Arquivos
├── 🖨️ Impressoras
├── 🔄 IPC
├── 🔐 Autenticação
└── 🌐 Compartilhamentos de rede
```

### Portas importantes

```text
445/TCP → SMB direto sobre TCP/IP ⭐
139/TCP → SMB sobre NetBIOS
137/UDP → NetBIOS Name Service
138/UDP → NetBIOS Datagram Service
```

### No pentest

```text
445 aberto
    ↓
Identificar SMB
    ↓
Descobrir versão
    ↓
Enumerar informações
    ↓
Enumerar shares
    ↓
Verificar permissões
    ↓
Avaliar vulnerabilidades
```

> **Regra prática:** encontrou `445/TCP` em uma rede interna? **SMB merece ser enumerado.**
