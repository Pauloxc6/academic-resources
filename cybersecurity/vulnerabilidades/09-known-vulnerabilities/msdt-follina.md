# 🪟 Follina — CVE-2022-30190

## 🧠 O que é a falha CVE-2022-30190?

A **CVE-2022-30190**, conhecida como **Follina**, é uma vulnerabilidade de **execução remota de código (RCE)** presente na **Microsoft Support Diagnostic Tool (MSDT)** do Windows.

O problema está relacionado à forma como o Windows processa determinadas referências ao protocolo `ms-msdt:`. Um documento malicioso do Microsoft Office podia induzir o sistema a chamar o MSDT e, em determinadas condições, permitir a execução de comandos com os privilégios do usuário que abriu o documento.

---

## ⚙️ Como funciona

O fluxo simplificado é:

```text
Documento malicioso
       │
       ▼
Microsoft Office
       │
       ▼
Conteúdo HTML / referência ms-msdt:
       │
       ▼
Microsoft Support Diagnostic Tool
       │
       ▼
Execução de código
       │
       ▼
Privilégios do usuário
```

A exploração ficou especialmente conhecida porque **podia ocorrer sem que macros do Office estivessem habilitadas**.

---

## 🎯 Vetor de ataque

Um cenário típico seria:

```text
Atacante
   │
   │ Documento malicioso
   ▼
Vítima
   │
   │ Abre o documento
   ▼
Microsoft Office
   │
   ▼
MSDT
   │
   ▼
Código arbitrário
```

O atacante poderia tentar distribuir o documento por:

- Phishing;
- E-mail;
- Engenharia social;
- Compartilhamento de arquivos;
- Outros meios de entrega de documentos.

---

## 💥 Impacto

Se explorada com sucesso, a vulnerabilidade poderia permitir ao atacante executar código com os **privilégios do usuário que abriu o documento**.

Dependendo desses privilégios, isso poderia permitir:

- Executar programas;
- Ler arquivos;
- Modificar ou excluir dados;
- Criar contas;
- Instalar software;
- Realizar outras ações permitidas pela conta comprometida.

📌 **Importante:** a vulnerabilidade não significa automaticamente que o atacante obtém privilégios de administrador. O nível de acesso depende das permissões do usuário comprometido.

---

## 🔎 Identificação

A vulnerabilidade está associada ao protocolo:

```text
ms-msdt:
```

Esse protocolo permite que outros aplicativos invoquem a **Microsoft Support Diagnostic Tool**.

O problema surgiu justamente da combinação entre o processamento desse protocolo, conteúdo HTML e determinadas funcionalidades do MSDT.

---

## 🧪 Exploit — laboratório

Uma ferramenta conhecida para demonstração da Follina é:

```text
msdt-follina
```

Repositório:

```text
https://github.com/JohnHammond/msdt-follina
```

Execução básica:

```bash
python3 follina.py
```

Exemplo de demonstração utilizando um comando simples:

```bash
python3 follina.py -c "notepad"
```

Execução utilizando uma porta especificada:

```bash
python3 follina.py -r 9001
```

⚠️ Esses exemplos devem ser utilizados somente em **laboratórios ou sistemas autorizados**, pois a vulnerabilidade permite execução de código no sistema da vítima.

---

## 🛡️ Mitigação

A Microsoft recomendou medidas como:

- Aplicar as atualizações de segurança correspondentes;
- Desabilitar o protocolo `ms-msdt:` quando apropriado;
- Manter Windows e Microsoft Office atualizados;
- Restringir a execução de documentos provenientes de fontes não confiáveis;
- Utilizar mecanismos de proteção contra phishing e arquivos maliciosos.

---

## 📌 Resumo

```text
CVE:       CVE-2022-30190
Nome:      Follina
Produto:   Microsoft Support Diagnostic Tool (MSDT)
Tipo:      Remote Code Execution (RCE)
Vetor:     Documento / conteúdo malicioso
Protocolo: ms-msdt:
Impacto:   Execução de código com os privilégios da vítima
```

### 🔗 Relação com outras vulnerabilidades

```text
Phishing / Engenharia Social
          │
          ▼
Documento malicioso
          │
          ▼
     CVE-2022-30190
          │
          ▼
         RCE
          │
          ▼
Execução com privilégios
     do usuário vítima
```