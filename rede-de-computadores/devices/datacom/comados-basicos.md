# Datacom

> [!INFO]
> Comandos de configuração e gerenciamento de switches **ExtremeXOS**.

---

## 🔎 Comandos de verificação e gerenciamento

| Comando                              | Descrição                                                  |
| ------------------------------------ | ---------------------------------------------------------- |
| `show running-config`                | Verificar a configuração atual                             |
| `show interfaces status`             | Verificar o estado das portas                              |
| `show hardware-status transceivers`  | Verificar módulos/transceptores SFP                        |
| `copy default-config running-config` | Carregar a configuração padrão na configuração em execução |
| `copy running-config startup-config` | Salvar a configuração atual para persistência após reboot  |
| `hostname NOME`                      | Alterar o nome do switch                                   |

> [!WARNING]
> `copy default-config running-config` **não deve ser entendido simplesmente como "resetar o switch"**. Ele carrega a configuração padrão para a configuração em execução. Antes de utilizá-lo, é recomendado fazer um backup da configuração atual.

---

# 🔐 Alterar senha do administrador

Entre no modo de configuração e altere a senha do usuário `admin`:

```text
# configure
(config)# username admin password 0 colocarsenha
```

O `0` indica que a senha está sendo informada em **texto claro no comando**, e não como um hash previamente gerado.

> [!WARNING]
> Evite senhas fracas e não compartilhe senhas reais em scripts, anotações públicas ou repositórios Git.

---

# 🔑 Habilitar acesso SSH

```text
# configure
(config)# ip ssh host-key generate dsa
(config)# ip ssh server
```

* `ip ssh host-key generate dsa` → gera a chave utilizada pelo serviço SSH.
* `ip ssh server` → habilita o servidor SSH.

> [!WARNING]
> **DSA é um algoritmo legado** e não é recomendado para configurações modernas. Em equipamentos/versões do ExtremeXOS que suportem algoritmos mais atuais, prefira uma chave SSH moderna, como **RSA ou Ed25519**, conforme a documentação e suporte da versão utilizada.

---

# 🖥️ Criando VLAN para gerência In-Band

A gerência **In-Band** utiliza uma VLAN da própria rede para permitir o acesso administrativo ao switch.

Exemplo:

```text
# configure
(config)# interface vlan 15
(config-if-vlan-15)# ip address 10.100.100.10/30
(config-if-vlan-15)# set-member tagged ethernet 1/6
(config-if-vlan-15)# exit
(config)# exit
```

### Estrutura

```text
VLAN 15
   │
   ├── IP: 10.100.100.10/30
   │
   └── Porta Ethernet 1/6
          │
          └── Tagged
```

Nesse exemplo:

* **VLAN:** `15`
* **IP de gerenciamento:** `10.100.100.10/30`
* **Porta:** `1/6`
* **Modo:** Tagged

O endereço `10.100.100.9` pertence à mesma rede `/30` e pode ser utilizado como próximo salto/gateway.

---

# 🌐 Configurando o gateway de gerenciamento

```text
# configure
(config)# no remote-devices enable
(config)# ip default-gateway 10.100.100.9
(config)# end
```

O comando:

```text
ip default-gateway 10.100.100.9
```

define o **gateway padrão utilizado pelo switch para tráfego de gerenciamento**.

> [!NOTE]
> Em um switch operando como equipamento predominantemente de **camada 2**, `ip default-gateway` é utilizado para permitir que o próprio switch alcance redes fora da sua rede de gerenciamento.
>
> Isso é diferente de configurar uma **rota padrão em um roteador Layer 3**.

---

# 🔀 Configurando VLAN Tagged / Trunk

```text
# configure
(config)# interface vlan 1000
(config-if-vlan-1000)# set-member tagged ethernet 1/1
(config-if-vlan-1000)# set-member tagged ethernet 1/6
(config-if-vlan-1000)# exit
(config)# exit
```

Nesse caso, a VLAN `1000` será transportada como **tagged** nas portas:

* `1/1`
* `1/6`

### Tagged

Em uma porta tagged, os quadros Ethernet carregam a identificação da VLAN através da **tag 802.1Q**.

É comum em enlaces entre:

```text
Switch ─────── Switch
   │
   ├── VLAN 10
   ├── VLAN 20
   └── VLAN 1000
```

ou:

```text
Switch ─────── Router/Firewall
        Trunk
```

---

# 🔌 Configurando VLAN Access / Untagged

```text
# configure
(config)# interface vlan 1004
(config-if-vlan-1004)# set-member tagged ethernet 1/2
(config-if-vlan-1004)# set-member untagged ethernet 1/5
(config-if-vlan-1004)# exit

(config)# interface ethernet 5
(config-if-eth-1/5)# switchport native vlan 1004
(config-if-eth-1/5)# end
```

Nesse exemplo:

* `1/2` → VLAN `1004` **tagged**
* `1/5` → VLAN `1004` **untagged**

A porta `1/5` funciona como uma porta de acesso para a VLAN `1004`.

### Untagged

Em uma porta untagged, os dispositivos normalmente enviam quadros **sem tag 802.1Q**.

Exemplo:

```text
        VLAN 1004
            │
            │
       ┌────┴────┐
       │ Switch  │
       └────┬────┘
            │
       Ethernet 1/5
         Untagged
            │
            ▼
         Computador
```

O computador não precisa conhecer a VLAN. O switch associa os quadros recebidos nessa porta à VLAN `1004`.

---

# 🧠 Tagged × Untagged

| Característica                    | Tagged          | Untagged                       |
| --------------------------------- | --------------- | ------------------------------ |
| Tag 802.1Q                        | Presente        | Ausente                        |
| Uso comum                         | Trunk           | Access                         |
| Múltiplas VLANs                   | Sim             | Normalmente uma VLAN de acesso |
| Dispositivo precisa entender VLAN | Geralmente sim  | Não                            |
| Exemplo                           | Switch ↔ Switch | Switch ↔ PC                    |

> [!TIP]
> Uma forma simples de memorizar:
>
> **Tagged → carrega a informação da VLAN.**
> **Untagged → o switch determina a VLAN pela porta.**

---

# 💾 Salvando a configuração

Depois das alterações:

```text
# copy running-config startup-config
```

A configuração presente em `running-config` é salva para que possa ser restaurada após uma reinicialização.

### Conceito

```text
running-config
      │
      │ copy
      ▼
startup-config
      │
      ▼
  persistência
```

---

# 📌 Resumo

```text
VER CONFIGURAÇÃO
└── show running-config

VER PORTAS
└── show interfaces status

VER SFP
└── show hardware-status transceivers

SALVAR CONFIGURAÇÃO
└── copy running-config startup-config

NOME DO SWITCH
└── hostname NOME

ALTERAR SENHA
└── username admin password 0 SENHA

HABILITAR SSH
├── ip ssh host-key generate ...
└── ip ssh server

GERÊNCIA IN-BAND
└── interface vlan 15
    └── ip address 10.100.100.10/30

GATEWAY DE GERÊNCIA
└── ip default-gateway 10.100.100.9

VLAN TAGGED
└── set-member tagged ethernet X/X

VLAN UNTAGGED
└── set-member untagged ethernet X/X
```

## 🧩 Conceitos importantes

* **In-Band Management** → gerenciamento utilizando a própria rede de produção.
* **Tagged** → quadro possui identificação 802.1Q.
* **Untagged** → quadro chega sem tag; a porta associa o tráfego à VLAN.
* **Trunk** → enlace utilizado para transportar múltiplas VLANs.
* **Access** → porta normalmente associada a uma VLAN para dispositivos finais.
* **Default Gateway** → permite ao próprio switch alcançar redes externas à sua rede de gerenciamento.
* **Running-config** → configuração atualmente em execução.
* **Startup-config** → configuração persistente utilizada após reinicialização.
