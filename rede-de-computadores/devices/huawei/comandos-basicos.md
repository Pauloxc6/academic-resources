# Huawei — Comandos

> [!INFO]
> Comandos básicos de configuração e administração de equipamentos **Huawei** utilizando a CLI.

---

# 🧭 Hierarquia do sistema operacional

A CLI Huawei possui diferentes níveis de configuração.

```text
<Huawei>
   │
   └── User View
          │
          │ system-view
          ▼
[Huawei]
   │
   ├── System View
   │      │
   │      ├── interface GigabitEthernet0/0/0
   │      │       └── Interface View
   │      │
   │      └── ospf 1
   │              └── Protocol View
   │
   └── ...
```

### Principais modos

| Prompt                          | Modo           | Função                                          |
| ------------------------------- | -------------- | ----------------------------------------------- |
| `<Huawei>`                      | User View      | Comandos de consulta e administração            |
| `[Huawei]`                      | System View    | Configuração global                             |
| `[Huawei-GigabitEthernet0/0/0]` | Interface View | Configuração de uma interface                   |
| `[Huawei-mpls]`                 | Protocol View  | Configuração de protocolos/recursos específicos |

Para entrar no modo de configuração:

```text
<Huawei> system-view
```

Também pode ser utilizado:

```text
<Huawei> sys
```

Para sair do modo atual:

```text
[Huawei] quit
```

ou:

```text
[Huawei] q
```

---

# ⚙️ Comandos básicos

## Verificar versão

```text
<Huawei> display version
```

Exibe informações sobre a versão do sistema operacional, hardware e outras informações do equipamento.

---

## Verificar horário

```text
<Huawei> display clock
```

Exibe data e hora configuradas no equipamento.

---

## Configurar timezone

```text
[Huawei] clock timezone UTC-3 minus 3
```

Configura o fuso horário.

> [!NOTE]
> A sintaxe disponível pode variar conforme a versão do VRP. Em equipamentos reais, confirme a sintaxe aceita pelo `?`.

---

## Configurar data e hora

```text
<Huawei> clock datetime 16:35:00 2023-08-22
```

Define manualmente:

```text
HH:MM:SS YYYY-MM-DD
```

Exemplo:

```text
16:35:00 2023-08-22
```

---

# 🏷️ Alterar nome do equipamento

Entrar no System View:

```text
<Huawei> system-view
```

Alterar o nome:

```text
[Huawei] sysname R1
```

O prompt passará a ser:

```text
[R1]
```

---

# 📋 Visualizar configurações

### Configuração atual

```text
[Huawei] display current-configuration
```

Exibe a configuração atualmente carregada no equipamento.

### Configuração salva

```text
[Huawei] display saved-configuration
```

Exibe a configuração armazenada para ser utilizada após uma reinicialização.

> [!NOTE]
> Dependendo da versão do VRP, o nome exato do comando pode variar. Use `display ?` para confirmar.

---

# 💾 Salvar configuração

No User View:

```text
<Huawei> save
```

O comando `save` grava a configuração atual no arquivo de configuração persistente.

Também pode aparecer em alguns contextos:

```text
[Huawei] run save
```

`run` permite executar um comando do User View a partir de determinados modos de configuração.

> [!IMPORTANT]
> Não confunda:
>
> **Configuração atual** → `current-configuration`
> **Configuração salva** → `saved-configuration`
>
> Alterar a configuração não significa automaticamente que ela ficará persistente após reboot.

---

# 🔌 Configuração de interface

Entrar em uma interface:

```text
[Huawei] interface Ethernet 1/0/0
```

O prompt será:

```text
[Huawei-Ethernet1/0/0]
```

Visualizar a configuração da interface:

```text
[Huawei-Ethernet1/0/0] display this
```

O `display this` mostra a configuração relacionada ao contexto atual.

---

# 🌐 Configuração de endereço IP

Exemplo:

```text
[Huawei] interface Ethernet1/0/0
[Huawei-Ethernet1/0/0] ip address 10.1.1.2 30
[Huawei-Ethernet1/0/0] commit
```

Verificar as interfaces:

```text
[Huawei] display ip interface brief
```

### Resultado esperado conceitualmente

```text
Interface          IP Address      State
Ethernet1/0/0      10.1.1.2       up
```

> [!TIP]
> `display ip interface brief` é um dos comandos mais úteis para verificar rapidamente o estado e os endereços IP das interfaces.

---

# 📡 DHCP Client

Para obter um endereço IP automaticamente através de DHCP:

```text
[Huawei] interface Ethernet1/0/0
[Huawei-Ethernet1/0/0] ip address dhcp-alloc
[Huawei-Ethernet1/0/0] commit
```

Verificar:

```text
[Huawei] display ip interface brief
```

E verificar a tabela de roteamento:

```text
[Huawei] display ip routing-table
```

### Fluxo

```text
DHCP Server
     │
     │ DHCP
     ▼
Huawei
     │
     └── Ethernet1/0/0
             │
             └── IP recebido automaticamente
```

---

# 🌎 DNS Client

Configurar servidores DNS:

```text
[Huawei] dns server 1.1.1.1
[Huawei] dns server 8.8.8.8
```

Habilitar resolução de nomes:

```text
[Huawei] dns resolve
```

Aplicar:

```text
[Huawei] commit
```

Verificar:

```text
[Huawei] display dns-server
```

---

# 📦 DHCP Server

Primeiro, configurar o endereço da interface que será o gateway da rede:

```text
[Huawei] interface Ethernet1/0/1
[Huawei-Ethernet1/0/1] ip address 172.16.10.1 24
```

Criar o pool:

```text
[Huawei] ip pool dhcp-rede server
```

Entrar no pool:

```text
[Huawei-ip-pool-dhcp-rede]
```

Configurar o gateway:

```text
[Huawei-ip-pool-dhcp-rede] gateway-list 172.16.10.1
```

Definir a faixa:

```text
[Huawei-ip-pool-dhcp-rede] section 0 172.16.10.100 172.16.10.200
```

Excluir um endereço:

```text
[Huawei-ip-pool-dhcp-rede] excluded-ip-address 172.16.10.150
```

Configurar DNS:

```text
[Huawei-ip-pool-dhcp-rede] dns-list 8.8.8.8
```

Configurar o período de concessão:

```text
[Huawei-ip-pool-dhcp-rede] lease day 1 hour 12 minute 30
```

Aplicar:

```text
[Huawei] commit
```

Verificar estatísticas:

```text
[Huawei] display dhcp server statistics
```

Salvar:

```text
<Huawei> save
```

> [!WARNING]
> A sintaxe exata de DHCP varia entre versões do Huawei VRP. Os comandos `gateway`, `dns-server`, `exclude-ip-address` e `lease` encontrados em materiais de estudo podem aparecer com sintaxes diferentes em outras versões. Sempre confirme com `?` no equipamento.

---

# 🔀 NAT

Criar uma ACL básica para identificar a rede que será traduzida:

```text
[Huawei] acl 2000
[Huawei-acl-basic-2000] rule 5 permit source 192.168.4.0 0.0.0.255
```

A ACL `2000` identifica:

```text
192.168.4.0/24
```

Depois, na interface de saída:

```text
[Huawei] interface GigabitEthernet0/0/1
[Huawei-GigabitEthernet0/0/1] nat outbound 2000
```

### Fluxo

```text
Rede interna
192.168.4.0/24
      │
      ▼
   Huawei
      │
      │ NAT
      ▼
GigabitEthernet0/0/1
      │
      ▼
   Internet
```

> [!NOTE]
> O `nat outbound 2000` associa a ACL ao NAT de saída. A forma exata de NAT disponível depende do modelo e da versão do VRP.

---

# 👤 Usuários locais

Entrar na configuração AAA:

```text
[Huawei] aaa
```

Criar usuário:

```text
[Huawei-aaa] local-user paulocezar password irreversible-cipher Test123@
```

Definir serviço SSH:

```text
[Huawei-aaa] local-user paulocezar service-type ssh
```

Definir nível:

```text
[Huawei-aaa] local-user paulocezar privilege level 3
```

Aplicar:

```text
[Huawei-aaa] commit
```

Verificar:

```text
[Huawei-aaa] display this
```

> [!WARNING]
> Nunca utilize senhas reais em anotações públicas, scripts ou repositórios Git.

---

# 🔐 Habilitando SSH

Primeiro, gerar o par de chaves RSA:

```text
[Huawei] rsa local-key-pair create
```

Habilitar o servidor SSH:

```text
[Huawei] stelnet server enable
```

Configurar o usuário:

```text
[Huawei] ssh user paulocezar authentication-type password
[Huawei] ssh user paulocezar service-type stelnet
```

Configurar as linhas VTY:

```text
[Huawei] user-interface vty 0 4
[Huawei-ui-vty0-4] authentication-mode aaa
[Huawei-ui-vty0-4] protocol inbound ssh
```

Verificar:

```text
[Huawei-ui-vty0-4] display this
```

Aplicar:

```text
[Huawei] commit
```

Salvar:

```text
<Huawei> save
```

Verificar interfaces:

```text
<Huawei> display ip interface brief
```

Verificar usuários/conexões:

```text
<Huawei> display users
```

---

# 🔑 Fluxo do SSH

```text
                  SSH
PC ─────────────────────────► Huawei
                               │
                               ▼
                              AAA
                               │
                               ▼
                       Usuário local
                       paulocezar
```

Para o acesso funcionar, normalmente é necessário ter:

```text
✓ Interface com IP
✓ Conectividade IP
✓ Chave RSA
✓ Servidor STelnet habilitado
✓ Usuário configurado
✓ Serviço SSH associado ao usuário
✓ VTY configurada
✓ AAA configurado
✓ SSH permitido nas VTY
```

---

# 🛰️ OSPF

Entrar na configuração do OSPF:

```text
[Huawei] ospf 1
```

O `1` representa o **process ID** local do processo OSPF.

Exemplo:

```text
[Huawei] ospf 1
[Huawei-ospf-1]
```

A partir desse modo podem ser configurados elementos como:

* Router ID;
* áreas;
* redes;
* interfaces;
* autenticação;
* parâmetros específicos do OSPF.

---

# 🧠 Resumo

| Objetivo                           | Comando                         |
| ---------------------------------- | ------------------------------- |
| Ver versão                         | `display version`               |
| Ver horário                        | `display clock`                 |
| Entrar no System View              | `system-view`                   |
| Sair                               | `quit`                          |
| Alterar hostname                   | `sysname R1`                    |
| Ver configuração atual             | `display current-configuration` |
| Ver configuração salva             | `display saved-configuration`   |
| Salvar                             | `save`                          |
| Entrar na interface                | `interface Ethernet...`         |
| Ver configuração atual do contexto | `display this`                  |
| Ver interfaces/IPs                 | `display ip interface brief`    |
| Ver tabela de rotas                | `display ip routing-table`      |
| Criar pool DHCP                    | `ip pool NOME server`           |
| Criar ACL                          | `acl 2000`                      |
| Entrar no AAA                      | `aaa`                           |
| Criar chave RSA                    | `rsa local-key-pair create`     |
| Habilitar SSH                      | `stelnet server enable`         |
| Configurar OSPF                    | `ospf 1`                        |

---

# 📌 Para memorizar

```text
<Huawei>
     │
     │ system-view
     ▼
[Huawei]
     │
     ├── interface ...
     │       └── Interface View
     │
     ├── aaa
     │
     ├── acl 2000
     │
     ├── ip pool ...
     │
     ├── ospf 1
     │       └── OSPF View
     │
     └── ...
```

### Comandos que você mais vai usar

```text
display version
display clock
display current-configuration
display ip interface brief
display ip routing-table
display this
system-view
interface ...
commit
save
```

> **Regra mental:**
>
> `display` → **verificar**
> `system-view` → **configurar**
> `interface` → **configurar interface**
> `commit` → **aplicar** (em plataformas/versões que usam configuração candidata)
> `save` → **persistir**
