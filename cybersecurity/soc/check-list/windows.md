# 🪟 Windows Security & SOC - Playbook

**Tags:** #estudos #soc #windows #blueteam #eventlogs
**Data:** 2025-11-21

---

## 1. Hardening Básico
- [ ] **RDP (3389):** Nunca exposto direto p/ internet. Restringir IPs.
- [ ] **SMB (445):** Desabilitar SMBv1 (Prevenção WannaCry).
- [ ] **LAPS:** Implementar para rotacionar senhas de Admin Local.
- [ ] **UAC:** Manter no nível máximo.

---

## 2. Event Logs (O que monitorar)
*Ferramenta: Event Viewer (`eventvwr.msc`)*

| ID       | Descrição       | Contexto de Ataque                                |
| :------- | :-------------- | :------------------------------------------------ |
| **4624** | Logon Sucesso   | Tipo 3 (Rede) ou 10 (RDP) suspeitos.              |
| **4625** | Logon Falha     | Brute-force ou Password Spraying.                 |
| **4720** | Usuário Criado  | Persistência (Backdoor account).                  |
| **4728** | Add em Grupo    | Add em "Domain Admins" ou "Enterprise Admins".    |
| **4688** | Processo Criado | Execução de malware (Verificar linha de comando). |
| **1102** | Log Limpo       | **CRÍTICO:** Tentativa de esconder rastros.       |

*Recomendação:* Instalar **Sysmon** para logs avançados (Event ID 1 - Process Creation com Hash).

---

## 3. Persistência (Caça a Malware)
*Onde o malware se esconde para iniciar com o Windows?*

1.  **Registry Run Keys:**
    - `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
    - `HKLM\Software\Microsoft\Windows\CurrentVersion\Run`
2.  **Task Scheduler:** Tarefas agendadas maliciosas.
3.  **Services:** Serviços falsos rodando como SYSTEM.
4.  **Startup Folder:** `shell:startup`.

**Ferramenta de Caça:** `Autoruns.exe` (Sysinternals).

---

## 4. PowerShell Security
*Identificando ataques Fileless.*

- **Sinais de Perigo:**
    - Comandos com `-EncodedCommand` ou `-e` (Base64).
    - Uso de `IEX` (Invoke-Expression) para rodar scripts da web.
    - Comandos de download: `Invoke-WebRequest`, `Net.WebClient`.
- **Defesa:** Ativar GPO de "Script Block Logging" (Event ID 4104).

---

## 5. Live Forensics (Comandos Rápidos)
*PowerShell para Triage rápida.*

```powershell
# Conexões de Rede (Equivalente ao netstat)
Get-NetTCPConnection | Where-Object State -eq 'Established' | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime

# Processos Suspeitos (Top consumo ou sem descrição)
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 Name, Id, Path

# Tarefas Agendadas
Get-ScheduledTask | Get-ScheduledTaskInfo | Select-Object TaskName, LastRunTime, TaskPath

# Usuários Locais
Get-LocalUser