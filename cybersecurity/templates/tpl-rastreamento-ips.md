# 🔎 Relatório de Inteligência de Ameaça - IP

## 📌 Informações Gerais

- **IP analisado**:
- **Data da análise**:
- **Analista**:
- **Contexto**: _(ex: tentativa de acesso, alerta IDS, log suspeito, etc.)_

---

## 📌 Origem da Análise

Descrever o evento que originou a investigação:

- Fonte do evento (log, firewall, SIEM, aplicação, etc.)
- Trecho do log (se aplicável)
- Ação observada (ex: acesso negado, tentativa de brute force, scan)

📎 **Evidência**:

```
[cole aqui o log]
```

🧠 **Hipótese inicial**:

- Reconnaissance
- Enumeração de serviços
- Atividade automatizada (bot/scanner)

---

## 🌍 Geolocalização

- **País**:
- **Região/Estado**:
- **Cidade**:
- **ISP (Provedor)**:
- **Tipo de rede**: _(Residencial, Datacenter, VPN, TOR)_
- **ASN**:
- **Latitude / Longitude**:

📎 Evidência:  
[IMAGEM]

---

## 🧠 Reputação do IP

### 🔍 VirusTotal

- **Detecções**:
- **Motores que marcaram**:

|Engine|Classificação|
|---|---|
|||

- **Classificação geral**: _(Malicious / Suspicious / Clean)_

📎 Evidência:  
[IMAGEM]

---

### 🚨 AbuseIPDB

- **Score de abuso**:
- **Total de reports**:
- **Último report**:
- **Tipos de abuso**:
    - DDoS
    - Port Scan
    - Brute Force
    - Outros

📎 Evidência:  
[IMAGEM]

---

### 🛡️ Talos Intelligence

- **Reputação**:
- **Categoria**:
- **Observações**:

📎 Evidência:  
[IMAGEM]

---

### 🤖 IPQualityScore

- **Fraud Score**:
- **Proxy/VPN**:
- **Bot activity**:

📎 Evidência:  
[IMAGEM]

---

## 🌐 Análise Técnica

### 🔎 Shodan

- **Portas abertas**:
- **Serviços detectados**:
- **Banners**:
- **Possíveis vulnerabilidades**:

📎 Evidência:  
[IMAGEM]

---

### 🔎 ASN / Infraestrutura

- **ASN**:
- **Organização**:
- **Upstreams**:
- **Tipo de uso**: _(Hosting, CDN, VPN, etc.)_
- **Países de operação**:

📎 Evidência:  
[IMAGENS]

---

## ⚠️ Indicadores de Comprometimento (IOCs)

- **IP**:
- **ASN**:
- **Domínio relacionado**:
- **Range de IP**:

---

## 📊 Avaliação Final

- **Nível de risco**: _(Baixo / Médio / Alto / Crítico)_
- **Motivo**:
    - Volume de reports
    - Detecção em múltiplas engines
    - Uso de VPN/Datacenter
    - Atividade automatizada

---

## 🛡️ Recomendações

- Bloquear IP no firewall
- Adicionar à blacklist
- Monitorar tentativas futuras
- Implementar rate limiting
- Revisar logs relacionados

---

## 🧩 Conclusão

Resumo técnico da análise:

O IP analisado apresenta **[grau de risco]**, com evidências de:

- Atividade maliciosa / suspeita 
- Uso de infraestrutura de anonimização (VPN/Datacenter)
- Correlação com múltiplas fontes de Threat Intelligence

A atividade observada indica possível:

- Reconnaissance
- Ataque automatizado
- Tentativa de exploração

➡️ **Recomendação final**: ação imediata / monitoramento contínuo