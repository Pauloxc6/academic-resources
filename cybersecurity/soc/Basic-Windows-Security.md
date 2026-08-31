# 🪟 Basic Windows Security - Playbook

**Tags:** #estudos #soc #windows #blueteam #eventlogs
**Data:** 2025-11-21

---

O Windows é o alvo número 1 em ambientes corporativos, principalmente porque é onde os usuários finais estão (Endpoints) e onde a identidade é gerenciada (Active Directory).

Para um analista de SOC, monitorar Windows é um jogo diferente do Linux. Aqui, não olhamos tanto para arquivos de texto (`/var/log`), mas sim para **Event Logs** estruturados e para o **Registro (Registry)**.

Aqui estão as melhores práticas e pontos de monitoramento para Windows.

---

### 1. Hardening e Redução da Superfície de Ataque

Assim como no Linux fechamos o SSH, no Windows o foco são os protocolos administrativos e de compartilhamento.

- **RDP (Remote Desktop - Porta 3389):** É o vetor de ataque mais comum para Ransomware.
    
    - Nunca exponha o RDP diretamente para a internet. Use VPN.
        
    - Se precisar expor internamente, restrinja quais IPs podem conectar.
        
- **SMB (Server Message Block - Porta 445):**
    
    - Famoso pelo ataque _WannaCry_ (EternalBlue).
        
    - Desabilite o **SMBv1** imediatamente.
        
- **LAPS (Local Administrator Password Solution):**
    
    - Em uma rede corporativa, se todos os computadores tiverem a mesma senha de Admin Local, o atacante invade um e domina todos (Movimentação Lateral). O LAPS garante que cada PC tenha uma senha de admin diferente e rotativa.
        
- **PowerShell Execution Policy:**
    
    - Configure para `RemoteSigned` ou `Restricted` para evitar execução acidental de scripts, mas saiba que atacantes conseguem burlar isso fácil (`-ExecutionPolicy Bypass`). A defesa real é o monitoramento (veremos abaixo).

---
### 2. O "Syslog" do Windows: Windows Event Logs

O Windows gera milhões de eventos. O segredo do SOC é saber **qual ID filtrar**.

Os logs ficam no **Visualizador de Eventos (Event Viewer)** (`eventvwr.msc`). Existem três canais principais:

1. **Security:** Logins, uso de privilégios (O mais importante).
    
2. **System:** Serviços parando, erros de driver, reboots.
    
3. **Application:** Erros de softwares (SQL Server, IIS, etc.).
    

#### 🚨 A "Cola" dos Event IDs (Decore estes números)

Como analista, você vai criar alertas no SIEM para estes códigos:

| ID       | Descrição       | Contexto de Ataque                                |
| :------- | :-------------- | :------------------------------------------------ |
| **4624** | Logon Sucesso   | Tipo 3 (Rede) ou 10 (RDP) suspeitos.              |
| **4625** | Logon Falha     | Brute-force ou Password Spraying.                 |
| **4720** | Usuário Criado  | Persistência (Backdoor account).                  |
| **4728** | Add em Grupo    | Add em "Domain Admins" ou "Enterprise Admins".    |
| **4688** | Processo Criado | Execução de malware (Verificar linha de comando). |
| **1102** | Log Limpo       | **CRÍTICO:** Tentativa de esconder rastros.       |

---
### 3. Turbinando os Logs: Sysmon (System Monitor)

O log padrão do Windows é "bom", mas o **Sysmon** (ferramenta da Microsoft Sysinternals) é "excelente".

Muitos SOCs obrigam a instalação do Sysmon em todos os servidores. Ele detalha coisas que o Windows nativo ignora, como:

- **Event ID 1:** Criação de Processo (com o hash do arquivo e a linha de comando completa).
    
- **Event ID 3:** Conexão de Rede (qual processo iniciou a conexão).
    
- **Event ID 11:** Criação de Arquivo (útil para ver se um malware foi baixado).
    

_Dica de estudo:_ Se você vir "Sysmon" na descrição da vaga, estude o básico dele. É um diferencial enorme.

---
### 4. Persistência no Windows (Onde o Malware dorme)

Diferente do Linux (Cron), o Windows tem dezenas de lugares para esconder inicialização automática.

1. **Registro (Registry):** O local favorito.
    
    - Caminho: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
        
    - Caminho: `HKLM\Software\Microsoft\Windows\CurrentVersion\Run`
        
    - Qualquer coisa listada aqui roda quando o PC liga.
        
2. **Agendador de Tarefas (Task Scheduler):**
    
    - Atacantes criam tarefas com nomes falsos (ex: "WindowsUpdateCheck") que rodam um script malicioso a cada hora.
        
3. **Serviços:**
    
    - Malwares sofisticados se instalam como serviços do Windows para rodar com privilégio `SYSTEM` (acima do Admin).
        
4. **Pasta Startup:**
    
    - `shell:startup` (método simples, mas ainda usado).

---
### 5. PowerShell: A Espada de Dois Gumes

O PowerShell é a ferramenta mais poderosa para administrar Windows, e a favorita dos atacantes para ataques "Fileless" (sem arquivo no disco, roda só na memória RAM).

**O que monitorar:**

- Comandos codificados em Base64 (ex: `powershell -e aBg3...`). É uma técnica para esconder o código real.
    
- Downloads via linha de comando: `Invoke-WebRequest` ou `IEX (New-Object Net.WebClient).DownloadString`.
    

**Defesa:** Ativar o **Script Block Logging (Event ID 4104)**. Isso grava no log todo o código que o script PowerShell tentou rodar, mesmo que esteja ofuscado.

---
### 6. Ferramentas de Live Forensics (Sysinternals)

Se você estiver em um servidor Windows suspeito, esqueça o "Gerenciador de Tarefas" (Task Manager). Ele mente ou esconde detalhes.

Use a suíte **Sysinternals** (gratuita da Microsoft):

1. **Process Explorer:** Um Gerenciador de Tarefas anabolizado. Mostra quem é o "pai" de cada processo, quais DLLs estão carregadas e verifica assinaturas digitais (se o processo da Microsoft é legítimo ou falso).
    
2. **TCPView:** O `netstat` com interface gráfica. Mostra conexões em tempo real e processos associados.
    
3. **Autoruns:** A ferramenta definitiva para achar persistência. Ele varre o Registro, Tarefas Agendadas e Pastas de Inicialização e marca em rosa o que não tem assinatura digital verificada.