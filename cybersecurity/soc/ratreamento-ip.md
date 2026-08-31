# 🔎 Rastreamento de IP (OSINT & Recon)

> [!info]
> Rastrear um IP **não identifica diretamente uma pessoa**, mas permite coletar:
> - Provedor / ASN  
> - Localização aproximada  
> - Serviços expostos  
> - Reputação (malicioso ou não)

> [!warning]
> Você **não consegue diretamente**:
> - Nome da pessoa  
> - Endereço exato  
> - Identidade real (sem vazamento ou ordem judicial)

---

# 🧠 Conceitos Básicos

## 🌐 Tipos de IP

- **Residencial** → ISP (Vivo, Claro, etc)
- **Datacenter/VPS** → AWS, Azure, DigitalOcean
- **Corporativo** → empresas

## 🔁 Reverse DNS (PTR)

- Nem todo IP possui PTR
- Muito comum em servidores (menos em IP residencial)

---

# 🖥️ Ferramentas CLI

## 🔹 Host

```bash
host <ip>
host -t ptr <ip>
```

>[!tip]
> Simples e rápido para resolução básica

## 🔹 Dig (mais poderoso)

```bash
dig -x <ip> +short        # Reverse DNS (PTR)  
dig <dominio> ANY         # Info geral (limitado hoje)  
dig NS <dominio>          # Name Servers  
dig MX <dominio>          # Servidores de e-mail
```

### 🔥 Zone Transfer (AXFR)

```bash
dig AXFR @ns1.dominio.com dominio.com
```

> [!danger]  
> Só funciona se o servidor DNS estiver mal configurado (raro)

## 🔹 Nslookup

```bash
nslookup <ip>  
nslookup -debug <ip>
```
---

## 🔹 Whois

```
whois <ip>
```

> Retorna:
> 
> - ASN
> - Organização
> - Range de IP

---

# 🌐 Enumeração DNS

## 🔥 dnsrecon

```bash
dnsrecon -d dominio.com -t std  
dnsrecon -d dominio.com -t brt
```

---

## 🔥 fierce

```bash
fierce --domain dominio.com
```

---

## 🚀 Alternativas modernas

- amass
- subfinder

---
## 🌍 Tools Web

### 🔍 Reputação de IP

- https://www.virustotal.com/gui/home/upload
- https://www.abuseipdb.com/
- https://talosintelligence.com/

### 🌎 Geolocalização

- https://www.ipqualityscore.com/
- https://ipin.io/en/iplocation.html
- https://www.maxmind.com/en/geoip-demo

### 🧠 OSINT Avançado

- https://www.shodan.io/
- https://bgp.tools/
- https://leakix.net/graph
- https://dehashed.com/
- https://intelx.io/
- https://hostingchecker.com/

### 🌐 Infraestrutura DNS

- https://viewdns.info/
- https://urlscan.io/
- https://dnsdumpster.com/
- https://www.iana.org/whois
- https://search.dnslytics.com/
- https://centralops.net/co/
