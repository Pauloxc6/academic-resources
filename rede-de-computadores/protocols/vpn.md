# 🔐 VPN — Virtual Private Network

**VPN (Virtual Private Network)**, ou **Rede Privada Virtual**, é uma tecnologia utilizada para criar uma **conexão lógica e protegida através de uma rede não confiável**, como a Internet.

Ela permite que dispositivos ou redes se comuniquem como se estivessem conectados a uma rede privada, mesmo estando fisicamente separados.

```text
Rede local A                         Rede local B

┌──────────┐                         ┌──────────┐
│ Cliente  │                         │ Servidor │
└────┬─────┘                         └────▲─────┘
     │                                    │
     │          Internet                  │
     │     ┌─────────────────┐            │
     └────►│   Túnel VPN     │────────────┘
           └─────────────────┘
```

O tráfego entre os pontos da VPN pode ser **encapsulado e criptografado**, dependendo do protocolo e da configuração utilizados.

---

# 🧠 Para que serve uma VPN?

Uma VPN pode ser utilizada para:

* 🔐 proteger o tráfego contra interceptação;
* 🌐 conectar redes remotas;
* 🏢 permitir acesso remoto a redes corporativas;
* 👤 permitir acesso remoto de usuários;
* 🔒 proteger dados em redes não confiáveis;
* 🌍 acessar serviços através de uma rede remota;
* 🔗 conectar diferentes filiais de uma empresa.

Um dos principais objetivos em redes corporativas é permitir:

```text
Filial A
   │
   │
   ▼
Internet
   │
   │ Túnel VPN
   ▼
Filial B
```

---

# 🔒 VPN não é sinônimo de anonimato

É comum encontrar a ideia:

> "VPN deixa você anônimo na Internet."

Isso é uma simplificação.

Uma VPN normalmente altera o caminho pelo qual o tráfego passa e pode ocultar seu **IP público original dos destinos**, mas o provedor VPN passa a ser um ponto importante de confiança.

```text
Sem VPN:

Você → ISP → Internet → Site

Com VPN:

Você → ISP → VPN → Internet → Site
```

O ISP pode observar que você está se comunicando com um servidor VPN, enquanto o destino normalmente verá o endereço IP do servidor VPN em vez do seu IP público original.

> **VPN aumenta a privacidade em determinados cenários, mas não fornece anonimato absoluto.**

---

# 🏗️ Funcionamento

Uma VPN normalmente cria um **túnel lógico** entre dois pontos.

```text
Dados originais
      │
      ▼
┌──────────────┐
│ Encapsulamento│
│ + Criptografia│
└───────┬──────┘
        │
        ▼
     Internet
        │
        ▼
┌──────────────┐
│ Desencapsular│
│ + Descriptografar
└───────┬──────┘
        │
        ▼
Dados originais
```

O tráfego pode ser encapsulado dentro de outro protocolo para atravessar a rede pública.

---

# 🔗 VPN Site-to-Site

É utilizada para conectar **duas ou mais redes**.

Exemplo:

```text
       Empresa A
    192.168.1.0/24
          │
     ┌────▼────┐
     │ Router A│
     └────┬────┘
          │
       Internet
          │
     ┌────▼────┐
     │ Router B│
     └────┬────┘
          │
    192.168.2.0/24
       Empresa B
```

Os usuários podem acessar recursos da outra rede através do túnel.

```text
192.168.1.10
     │
     │ VPN
     ▼
192.168.2.10
```

---

# 👤 VPN Remote Access

Também conhecida como **Client-to-Site**.

Permite que um usuário remoto se conecte à rede de uma organização.

```text
Notebook
   │
   │ VPN
   ▼
Internet
   │
   ▼
VPN Gateway
   │
   ▼
Rede corporativa
```

Exemplo:

Um funcionário em casa pode conectar seu computador à rede da empresa através de uma VPN.

---

# 🔐 VPN e criptografia

Uma VPN pode utilizar criptografia para proteger os dados durante o transporte.

```text
Cliente
   │
   │ Dados criptografados
   ▼
Internet
   │
   ▼
Servidor VPN
   │
   │ Dados decifrados
   ▼
Rede/Internet
```

A segurança real depende de:

* protocolo utilizado;
* algoritmos criptográficos;
* autenticação;
* configuração;
* gerenciamento das chaves;
* implementação do software.

---

# 📡 Protocolos e tecnologias VPN

Existem diversas tecnologias utilizadas para criar VPNs.

## IPsec

O **IPsec** é um conjunto de protocolos utilizado para proteger comunicações na camada IP.

É muito utilizado em:

* VPN Site-to-Site;
* VPN Remote Access;
* redes corporativas.

Principais componentes/modos relacionados:

```text
IPsec
├── AH
└── ESP
```

O **ESP (Encapsulating Security Payload)** é amplamente utilizado para fornecer confidencialidade, integridade e autenticação dos dados.

---

# 🔑 IKE

O **IKE (Internet Key Exchange)** é utilizado para negociar parâmetros de segurança e estabelecer chaves para o IPsec.

Versões comuns:

```text
IKEv1
IKEv2
```

O **IKEv2** é uma opção moderna e bastante utilizada.

---

# 🟢 WireGuard

O **WireGuard** é um protocolo VPN moderno, projetado para ser:

* simples;
* rápido;
* moderno;
* relativamente pequeno em termos de código;
* baseado em criptografia moderna.

Funcionamento simplificado:

```text
Cliente
   │
   │ WireGuard
   ▼
Servidor VPN
```

É bastante utilizado em:

* servidores;
* redes domésticas;
* acesso remoto;
* Site-to-Site;
* ambientes de laboratório.

---

# 🔵 OpenVPN

O **OpenVPN** é uma solução VPN amplamente utilizada.

Pode funcionar utilizando:

```text
OpenVPN
   │
   ├── UDP
   └── TCP
```

É comum em cenários de:

* acesso remoto;
* redes corporativas;
* servidores;
* laboratórios.

---

# 🟠 L2TP/IPsec

O **L2TP** pode ser combinado com **IPsec** para fornecer uma VPN.

```text
L2TP
  +
IPsec
  ↓
VPN
```

O L2TP sozinho **não fornece criptografia forte**, por isso tradicionalmente é combinado com IPsec.

---

# ⚠️ PPTP

O **PPTP (Point-to-Point Tunneling Protocol)** é uma tecnologia VPN antiga.

Atualmente é considerado **obsoleto e inseguro**.

```text
PPTP
 ↓
❌ Evitar em novos projetos
```

---

# 🌐 VPN e Wi-Fi público

Uma VPN pode ser útil em redes Wi-Fi públicas porque cria um túnel protegido entre o dispositivo e o servidor VPN.

Sem VPN:

```text
Notebook
   │
   ▼
Wi-Fi público
   │
   ▼
Internet
```

Com VPN:

```text
Notebook
   │
   ▼
Wi-Fi público
   │
   │ tráfego protegido
   ▼
Servidor VPN
   │
   ▼
Internet
```

Porém, o uso de HTTPS continua importante.

> Uma VPN **não substitui HTTPS, autenticação forte ou outras medidas de segurança**.

---

# 💰 VPN e economia

Uma VPN pode, em alguns casos, alterar a região aparente de origem da conexão.

Porém, não é correto afirmar que uma VPN **sempre economiza dinheiro**.

Preços de serviços podem depender de:

* país;
* impostos;
* moeda;
* conta do usuário;
* localização real;
* método de pagamento;
* políticas do serviço.

Portanto:

```text
VPN ≠ garantia de preço menor
```

---

# 🚦 VPN e velocidade

Uma VPN **não deve ser utilizada como solução geral para Internet lenta**.

Na realidade, ela pode até diminuir a velocidade devido a:

* criptografia;
* encapsulamento;
* distância até o servidor VPN;
* congestionamento do servidor;
* qualidade da rota.

Por outro lado, existem situações específicas em que uma VPN pode contornar problemas de roteamento ou determinadas formas de gerenciamento de tráfego.

```text
Internet direta
   ↓
Rota A

Internet via VPN
   ↓
Rota B
```

Se a rota B for melhor, o desempenho pode eventualmente melhorar.

---

# 📋 Quando usar uma VPN?

A necessidade depende do cenário.

### Pode fazer sentido quando:

1. 🔐 Você precisa proteger o tráfego em uma rede não confiável;
2. 🏢 Precisa acessar uma rede corporativa remotamente;
3. 🔗 Precisa conectar duas redes através da Internet;
4. 🌐 Precisa acessar recursos disponíveis somente através de uma determinada rede;
5. 🛡️ Precisa criar um túnel protegido entre dois pontos.

### Não significa que:

```text
VPN
 ↓
Segurança absoluta ❌
Anonimato absoluto ❌
Internet mais rápida sempre ❌
```

---

# 🛡️ VPN em redes corporativas

Um exemplo bastante comum:

```text
               INTERNET
                   │
          ┌────────┴────────┐
          │                 │
       Filial A           Filial B
          │                 │
      ┌───▼───┐         ┌───▼───┐
      │Router │=========│Router │
      │ VPN   │  IPsec  │ VPN   │
      └───┬───┘         └───┬───┘
          │                 │
     Rede A             Rede B
10.10.1.0/24         10.10.2.0/24
```

O `=====` representa o **túnel VPN** através da Internet.

---

# 🧪 VPN em laboratório

No seu próprio laboratório, uma arquitetura bastante interessante é:

```text
┌──────────────┐
│   Cliente    │
└──────┬───────┘
       │
       │ VPN
       ▼
┌──────────────┐
│ VPN Gateway  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Rede interna │
└──────────────┘
```

Isso permite estudar:

* roteamento;
* NAT;
* firewall;
* criptografia;
* túneis;
* autenticação;
* acesso remoto;
* Site-to-Site.

---

# 🧠 Comparação rápida

| Tecnologia      | Característica                        |
| --------------- | ------------------------------------- |
| **IPsec**       | Muito utilizado em redes corporativas |
| **IKEv2/IPsec** | Negociação moderna para IPsec         |
| **WireGuard**   | Simples, moderno e rápido             |
| **OpenVPN**     | Flexível e amplamente utilizado       |
| **L2TP/IPsec**  | Tecnologia legada                     |
| **PPTP**        | Obsoleto e inseguro                   |

---

# 🧠 Para memorizar

```text
VPN
│
├── 🔐 Túnel
│
├── 🔒 Criptografia
│
├── 👤 Remote Access
│
├── 🔗 Site-to-Site
│
└── 🌐 Rede pública
        ↓
   Rede privada
```

### Principais tecnologias

```text
IPsec
WireGuard
OpenVPN
L2TP/IPsec
```

### Fluxo

```text
Dados
 ↓
Encapsulamento
 ↓
Criptografia
 ↓
Túnel VPN
 ↓
Internet
 ↓
Servidor VPN
 ↓
Desencapsulamento
 ↓
Destino
```

> **VPN = túnel lógico protegido sobre uma rede não confiável.**

> **VPN não é sinônimo de anonimato.** Ela protege o tráfego entre determinados pontos e muda o caminho/tratamento da conexão, mas a privacidade final depende de toda a arquitetura e de quem controla os pontos envolvidos.
