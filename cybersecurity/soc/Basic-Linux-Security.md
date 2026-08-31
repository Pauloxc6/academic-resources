# 🛡️ Basic Linux Security - Playbook

**Tags:** #estudos #soc #linux #blueteam #hardening
**Data:** 2025-11-21

----

Aqui estão as melhores práticas divididas por camadas, com foco no que é relevante para um analista de segurança.

---

### 1. A "Porta de Entrada": Hardening do SSH

O SSH é o vetor de ataque mais comum. Se o SSH estiver exposto, ele _será_ atacado.

- **Desabilite o Login de Root:** Nunca permita login direto como root. Edite `/etc/ssh/sshd_config` e defina `PermitRootLogin no`.
    
- **Autenticação apenas por Chaves:** Senhas são fracas. Configure chaves SSH (públicas/privadas) e desabilite a autenticação por senha (`PasswordAuthentication no`).
    
- **Mude a Porta Padrão (Opcional mas útil):** Mudar da porta 22 para uma porta alta (ex: 2244) não é uma medida de segurança robusta (é segurança por obscuridade), mas reduz drasticamente o ruído de bots e scanners nos seus logs, facilitando a vida do analista.
    
- **Use Fail2Ban:** Ferramenta essencial que bane IPs (via firewall) que falham no login repetidamente.


---

### 2. Gestão de Identidade e Privilégios (IAM)

O princípio fundamental aqui é o **Privilégio Mínimo**.

- **Uso do Sudo:** Crie usuários comuns e adicione-os ao grupo `sudo` ou `wheel`. Cada comando administrativo deve ser rastreável a um usuário específico.
    
- **Bloqueie Usuários Inativos:** Contas antigas são backdoors esquecidos. Use `chage -l` para verificar a expiração de senhas e contas.
    
- **Separação de Funções:** Se o servidor roda um banco de dados, o serviço deve rodar com um usuário específico (ex: `postgres` ou `mysql`), nunca como root.

---

### 3. Defesa de Rede (Network Security)

Um servidor Linux deve ser uma fortaleza.

- **Firewall Host-based:** Sempre tenha um firewall ativo no servidor, independentemente do firewall da borda.
    
    - _Simples:_ `UFW` (Uncomplicated Firewall) para Ubuntu/Debian.
        
    - _Robusto:_ `firewalld` ou `iptables`/`nftables`.
        
    - **Regra de Ouro:** _Deny All Incoming_ (Negar tudo que entra) por padrão, e libere apenas o necessário (ex: portas 80/443 e sua porta SSH customizada).
        
- **[Desabilite IPv6](Desabilitar-o-Pv6.md) (se não usar):** Reduz a superfície de ataque.

---
### 4. Visibilidade e Logs (O Coração do SOC)

Para você, como futuro analista, esta é a parte mais crítica. Se não há log, o ataque não aconteceu (na sua visão).

- **Syslog/Rsyslog:** Garanta que os logs estão sendo gerados em `/var/log`.
    
    - `/var/log/auth.log` (ou `secure`): Tentativas de login (sucesso e falha).
        
    - `/var/log/syslog`: Mensagens gerais do sistema.
        
- **Auditd (Linux Audit Daemon):** Ferramenta poderosa para conformidade. Você pode configurar regras para auditar quem acessou um arquivo específico (ex: `/etc/passwd`) ou quem executou um comando específico.
    
- **Forwarding de Logs:** Em um ambiente real, logs locais podem ser apagados pelo atacante. Configure o `rsyslog` ou instale um agente (como o **Wazuh Agent** ou **Filebeat**) para enviar logs para um SIEM (Security Information and Event Management).

---
### 5. Proteção do Sistema de Arquivos

- **Particionamento Inteligente:** Separe diretórios críticos em partições diferentes. Isso impede que um ataque de DDoS encha o disco e trave o sistema, e permite flags de segurança.
    
- **Flags de Montagem:**
    
    - Monte `/tmp` e `/var/tmp` com a opção `noexec` (impede a execução de binários). Isso bloqueia muitos scripts de _malware_ que tentam rodar a partir de diretórios temporários.
        
- **FIM (File Integrity Monitoring):** Use ferramentas como **Tripwire**, **AIDE** ou o próprio **Wazuh**. Elas alertam se arquivos críticos do sistema foram alterados.

---
### 6. Mandatory Access Control (MAC)

Esta é a camada "Dificuldade Hard" que muitos administradores desligam, mas você deve manter.

- **SELinux (RHEL/CentOS/Fedora) ou AppArmor (Debian/Ubuntu):** Eles confinam programas a um conjunto limitado de recursos. Mesmo que um atacante explore uma vulnerabilidade no Apache, o SELinux pode impedir que o Apache acesse o arquivo `/etc/shadow` ou abra uma conexão reversa (shell reverso).