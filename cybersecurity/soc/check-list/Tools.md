# Check List Tools

**TAGS:** #blueteam #estudos #linux #soc #tools
**Data:** 2025-11-21

---

## 🛡️Ferramentas Básicas para todos os servidores

1. [ ] | UFW - Firewall
2. [ ] | Fail2ban - Bloqueia ataques de brute force
3. [ ] |  Lnav - Visualizador de logs

## 🛡️ Para Segurança e Hardening (Melhoria da Defesa)

1. [ ] | Lynis - Auditoria de segurança e _hardening_ do sistema (excelente para verificar a configuração).
2. [ ] | ClamAv - Scanner de código aberto para detecção de malware (bom para varreduras ocasionais ou agendadas).
3. [ ] | chkrootkit / Rootkit Hunter (rkhunter) - Scanners de rootkits, backdoors e explorações locais.
4. [ ] | SELinux / AppArmor - Módulos de Segurança de Acesso Obrigatório (_Mandatory Access Control_ - MAC) para limitar o que processos podem fazer.

## 🔍 Para Monitoramento e Detecção (Visibilidade e SOC)

1. [ ] | Netstat / SS - Visualização de conexões de rede ativas e portas abertas (essencial para verificar quem está se comunicando).
2. [ ] | Auditd (Linux Audit System) - Captura e registra eventos de segurança detalhados do kernel (fundamental para análise forense e trilhas de auditoria).
3. [ ] | **Wazuh / OSSEC** - Sistema de Detecção de Intrusão Baseado em Host (**HIDS**) e Gerenciamento de Integridade de Arquivos (**FIM**).
4. [ ] | Prometheus + Grafana - Combinação poderosa para coleta de métricas e visualização de monitoramento (CPU, memória, tráfego, etc.).

## 💾 Gerenciamento e Análise de Logs (Log Management)

1. [ ] | **rsyslog / syslog-ng**Soluções robustas de envio e coleta de logs centralizados (o primeiro passo para um SOC).
2. [ ] | **Elastic Stack (ELK/ECL)** - Ferramenta de Logs, Métricas e Segurança (incluindo Kibana para visualização), muito comum em arquiteturas SOC.
3. [ ] | **Vector / Filebeat** - Agentes leves para enviar logs de forma eficiente para uma solução centralizada (rsyslog, Elastic, etc.).

## 🌐 Ferramentas de Rede e Análise de Tráfego

1. [ ] | **tcpdump / Wireshark** - Ferramentas essenciais para capturar e analisar o tráfego de rede (necessário para investigação profunda). 
2. [ ] | **Nmap** - Utilitário para exploração de rede e auditoria de segurança, para mapear portas e serviços.
3. [ ] | **Suricata / Snort** - Sistemas de Detecção de Intrusão Baseados em Rede (**NIDS**) para monitorar o tráfego em tempo real em busca de ameaças.