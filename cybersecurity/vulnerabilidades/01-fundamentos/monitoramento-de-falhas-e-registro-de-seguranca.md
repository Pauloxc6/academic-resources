## 📊 Monitoramento de Falhas e Registros de Segurança (Security Logging and Monitoring Failures)

A falha de **Security Logging and Monitoring Failures** acontece quando uma aplicação ou infraestrutura **não registra, monitora ou alerta adequadamente sobre eventos de segurança importantes**.

👉 Em outras palavras: o sistema pode até ser atacado, mas **ninguém percebe o ataque ou não existem registros suficientes para investigar o que aconteceu**.

Essa categoria era anteriormente conhecida como **Insufficient Logging & Monitoring** e foi ampliada para abranger outros problemas relacionados à detecção e resposta a incidentes.

---

## ⚙️ Como acontece

Um sistema seguro precisa registrar e monitorar eventos importantes, como:

- tentativas de login
- falhas de autenticação
- alterações de senha
- alterações de privilégios
- ações administrativas
- acesso a informações sensíveis
- erros críticos
- atividades suspeitas

💥 O problema aparece quando:

- eventos importantes não são registrados
- os logs são incompletos
- os logs podem ser facilmente apagados
- não existem alertas
- ninguém monitora os eventos
- atividades suspeitas não são detectadas
- os registros não possuem informações suficientes

---

## 📌 Exemplos práticos

### 🔹 1. Tentativas de login não registradas

Um atacante tenta várias senhas:

```text
admin → senha1 ❌
admin → senha2 ❌
admin → senha3 ❌
admin → senha4 ❌
...
```

Mas o sistema não registra essas tentativas.

💥 A equipe de segurança não consegue identificar facilmente um possível **brute force**.

---

### 🔹 2. Acesso administrativo sem registro

Um usuário realiza uma alteração crítica:

```text
Usuário: admin
Ação: alterou permissões
Horário: ?
IP: ?
```

Se o sistema não registra essas informações:

💥 fica difícil descobrir **quem realizou a ação, quando ela ocorreu e de onde veio**.

---

### 🔹 3. Falta de alertas

Imagine que ocorra:

```text
100 falhas de login
        ↓
Sistema registra: NÃO
Alerta: NÃO
```

💥 O ataque pode continuar por muito tempo sem chamar atenção da equipe responsável.

---

### 🔹 4. Logs insuficientes para perícia

Depois de um incidente:

```text
Servidor comprometido
       ↓
Investigação
       ↓
Logs incompletos
```

A equipe descobre que houve uma invasão, mas não consegue determinar:

```text
Quem?
Quando?
De onde?
O que foi acessado?
O que foi alterado?
```

💥 Isso prejudica diretamente a **resposta a incidentes e a análise forense**.

---

## 🔎 Em pentest

Durante um pentest, é possível verificar se ações relevantes geram registros adequados.

Por exemplo:

```text
Tentativa de login
       ↓
Evento registrado?
       ↓
Alerta gerado?
       ↓
Equipe consegue identificar?
```

Também podem ser avaliados:

- logs de autenticação
- logs administrativos
- registros de erros
- alertas
- sistemas de monitoramento
- retenção dos logs
- integridade dos registros
- informações registradas

👉 O objetivo é avaliar se **um ataque poderia acontecer sem ser detectado ou investigado posteriormente**.

---

## 🚨 Impactos

A ausência de monitoramento adequado pode causar:

- ataques prolongados sem detecção
- dificuldade para identificar invasões
- atraso na resposta a incidentes
- perda de evidências
- dificuldade em análises forenses
- dificuldade para identificar ações maliciosas
- aumento dos danos causados por um ataque

📌 Um ataque detectado rapidamente pode ser contido. Um ataque que permanece invisível pode causar muito mais impacto.

---

## 🧠 Logging × Monitoring × Alerting

É importante diferenciar:

```text
Logging
↓
Registrar o que aconteceu

Monitoring
↓
Acompanhar e analisar os eventos

Alerting
↓
Avisar quando algo suspeito acontece
```

Exemplo:

```text
Login falhou
     ↓
[LOG] Evento registrado
     ↓
[MONITORAMENTO] Muitas falhas detectadas
     ↓
[ALERTA] Equipe de segurança notificada
```

👉 Os três mecanismos trabalham juntos.

---

## 🛡️ Como prevenir

- registrar eventos de segurança importantes
- centralizar logs
- monitorar eventos continuamente
- configurar alertas
- proteger os registros contra alterações
- definir políticas de retenção
- registrar informações suficientes para investigação
- sincronizar horários dos sistemas
- monitorar atividades administrativas
- testar periodicamente os mecanismos de detecção

📌 **Regra de ouro:**

👉 **Não basta impedir ataques; é preciso conseguir perceber quando eles acontecem e descobrir o que ocorreu.**