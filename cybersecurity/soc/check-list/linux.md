# 🛡️ Check List - Playbook

**Tags:** #estudos #soc #linux #blueteam #hardening
**Data:** 2025-11-21
## 1. Hardening (Endurecimento)
*O foco é reduzir a superfície de ataque.*

- [ ] **SSH Config** (`/etc/ssh/sshd_config`)
    - `PermitRootLogin no`
    - `PasswordAuthentication no` (Usar chaves SSH)
    - (Opcional) Mudar porta padrão.
- [ ] **Usuários**
    - Princípio do Privilégio Mínimo.
    - Bloquear inativos: `chage -l usuario`
- [ ] **Firewall**
    - `ufw enable` ou `firewalld`.
    - Regra: *Deny All Incoming* (Exceto SSH/Serviços necessários).

---

## 2. Log Analysis (Detecção)
*Se não está no log, não aconteceu.*

| Log File | O que procurar? |
| :--- | :--- |
| `/var/log/auth.log` | Logins (Sucesso/Falha), `sudo`, Criação de users. |
| `/var/log/syslog` | Erros gerais, serviços parando. |
| `/var/log/cron` | Tarefas agendadas (Muitas vezes usado para persistência). |

**Comando de Caça (Brute-Force):**
```bash
# Quem mais errou senha?
root@srv-0001-prod:~\# grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
```

---
## 3. Threat Hunting & Persistência

_Como o atacante se mantém no sistema?_

### 🕵️ Onde olhar:

1. [ ] **Cron Jobs (Agendador):**
    
    - `crontab -u root -l`
    - `cat /etc/crontab`
    - _Sinal de Alerta:_ Downloads com `curl`/`wget` ou conexões `/dev/tcp`.
        
2. [ ] **Chaves SSH:**
    
    - `cat ~/.ssh/authorized_keys` (Verificar chaves desconhecidas).
    
3. [ ] **Binários Alterados (Rootkits):**
    
    - `stat /bin/ls` (Data de modificação recente?).
    - `rpm -V coreutils` ou `dpkg --verify coreutils` (Verificar Hash/Integridade).

---

## 4. Network Analysis (Rede)

_O malware precisa "falar" com o dono._

- [ ] **Conexões Ativas:** `netstat -antp` ou `ss -antp`
    
    - _Sinal de Alerta:_ Conexão ESTABLISHED para IPs desconhecidos em portas altas.
        
- [ ] **Portas Ouvindo:** `ss -tulpn`
    
- [ ] **Sniffing:** `ip link` (Procurar por `PROMISC`).

---

## 5. 🚑 Incident Response (Primeiros 15 min)

**REGRA DE OURO:** NÃO REINICIE O SERVIDOR! (Perde a evidência da RAM).

1. [ ] **Isolar:** Bloquear IP no Firewall / Security Group da Cloud.
    
2. [ ] **Coleta Volátil (Salvar em `/dev/shm` ou Pendrive):**

  ```bash
	date > /dev/shm/case01.txt
	netstat -antp >> /dev/shm/case01.txt  # Pegar conexões antes que caiam
	ps aux >> /dev/shm/case01.txt         # Processos rodando
	lsof -n >> /dev/shm/case01.txt        # Arquivos abertos
	w >> /dev/shm/case01.txt              # Quem está logado
	```

