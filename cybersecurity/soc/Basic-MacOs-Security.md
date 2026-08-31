# 🛡️ Basic MacOs Security - Playbook

**Tags:** #estudos #soc #linux #blueteam #hardening
**Data:** 2025-11-21

---

O macOS é uma plataforma única. Embora seja baseado em **UNIX** (semelhante ao Linux), ele tem camadas de segurança próprias que mudam a forma como um analista de SOC o investiga.

---
## 1. Hardening e Prevenção (Prevention) 🍎

O macOS tem recursos de segurança robustos integrados, mas que precisam ser configurados corretamente.

- **Gatekeeper e Notarização:**
    
    - Garanta que a política de segurança permite apenas aplicações baixadas da **App Store** ou de **Desenvolvedores Identificados**.
    - Um IoC (Indicador de Compromisso) comum é o atacante tentar remover a _quarentena_ de um executável via terminal (`xattr -d com.apple.quarantine`).
        
- **FileVault:**
    
    - Habilite a **criptografia de disco** nativa (**FileVault**). Isso impede que um atacante obtenha dados do disco rígido se o computador for fisicamente roubado.
        
- **TCC (Transparency, Consent, and Control):**
    
    - Este sistema de segurança controla as permissões de privacidade (acesso à webcam, microfone, gravação de ecrã). Ataques _targeted_ frequentemente tentam **contornar o TCC** para espionagem ou roubo de dados.
        
- **Remoção de Serviços:**
    
    - Desative o **SSH** e o **Remote Login** se não forem usados. O SSH no macOS é chamado de _Remote Login_ e é controlado em **Partilha de Ficheiros > Serviços Remotos**.

---

## 2. Logging e Visibilidade (Identification) 🔭

A principal diferença do macOS para Linux/Windows é o seu sistema de logs.

### 1. Unified Logging System (ULS)

O macOS não usa ficheiros de texto simples (`/var/log/messages`) como o Linux. Em vez disso, ele usa um sistema de log unificado (Unified Logging System) estruturado e otimizado para performance.

- **Como Aceder:** Você não usa mais `tail -f`. Você usa o comando `log show`.

```bash
log show --predicate 'process == "Finder"' --last 1h
```

- _(Mostra apenas logs do processo "Finder" na última hora.)_
- **Caça de Malware:** Malware que tenta desabilitar o Gatekeeper ou o TCC é registado no ULS.

---
## 3. Persistência (Persistence) 👻

No macOS, o equivalente a um **Cron Job** (Linux) ou um **Serviço** (Windows) é um **Launch Agent** ou **Launch Daemon**. Eles são definidos por ficheiros `.plist` (Property List).

- **Launch Daemons:** Rodam como `root` e iniciam no arranque do sistema, mesmo que ninguém faça login.
    
    - **Caminho:** `/Library/LaunchDaemons/`
        
- **Launch Agents:** Rodam quando um utilizador específico faz login (são a forma mais comum de malware persistir).
    
    - **Caminho:** `~/Library/LaunchAgents/` (dentro da pasta de cada utilizador)
        
    - **Caminho:** `/Library/LaunchAgents/` (para todos os utilizadores)
        

### 🚨 Comando Essencial para Caça à Persistência:

Use o comando `ls -la` para verificar quem adicionou o ficheiro recentemente:
```bash
ls -la /Library/LaunchDaemons/
```

Procure ficheiros `.plist` com nomes suspeitos (ex: `com.apple.update.service.plist`) ou ficheiros que foram **modificados recentemente** (data de modificação coincide com o tempo do ataque).


---
## 4. Forense e Ferramentas (Triage) 🛠️

Por ser baseado em UNIX, o macOS responde aos comandos Linux que você já aprendeu.
