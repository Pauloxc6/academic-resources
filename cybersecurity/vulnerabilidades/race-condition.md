## 🧠 Race Condition (Condição de Corrida)

Uma **race condition** acontece quando dois ou mais processos/threads acessam e manipulam o mesmo recurso ao mesmo tempo, e o resultado final depende da ordem ou do tempo dessas execuções.

👉 Ou seja: o sistema “fica imprevisível” porque as operações acontecem fora de controle.

---

## ⚙️ Como acontece

Isso ocorre principalmente em sistemas concorrentes, como:

- programas com múltiplas threads
- servidores web com várias requisições simultâneas
- sistemas distribuídos

Quando não existe um controle adequado (sincronização), duas execuções podem:

- ler o mesmo valor ao mesmo tempo
- modificar esse valor simultaneamente
- sobrescrever dados importantes

---

## 📌 Exemplo simples

Imagine um saldo bancário de R$100:

1. Processo A lê o saldo (100)
2. Processo B lê o saldo (100)
3. Processo A saca 50 → salva 50
4. Processo B saca 50 → salva 50

❌ Resultado final: 50  
✔️ Resultado correto deveria ser: 0

👉 Isso aconteceu porque os dois processos usaram o mesmo valor inicial ao mesmo tempo.

---

## 🚨 Impactos

- dados inconsistentes
- falhas de lógica
- bugs difíceis de reproduzir
- vulnerabilidades de segurança (muito importante em pentest)

---

## 🔐 Race Condition em Segurança

Em segurança, pode ser explorada quando um atacante:

- envia várias requisições ao mesmo tempo 
- tenta burlar validações (ex: limite de saque, compra duplicada, bypass de autenticação)

📌 Exemplo:

- comprar um item uma vez, mas receber várias vezes
- usar saldo que já deveria ter sido gasto

---

## 🛡️ Como prevenir

- uso de **locks (travas)**
- **mutex / semáforos**
- controle de concorrência
- operações atômicas
- filas (queue) para organizar execuções