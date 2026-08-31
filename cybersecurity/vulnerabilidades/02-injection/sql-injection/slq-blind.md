## 🕶️ Boolean-Based Blind SQL Injection

A **Boolean-Based Blind SQL Injection** é uma técnica de **SQL Injection** em que o atacante não recebe diretamente os dados do banco de dados na resposta.

Em vez disso, ele envia uma condição **verdadeira ou falsa** e observa como a aplicação se comporta.

👉 O atacante transforma a aplicação em uma espécie de **"sim ou não"** para descobrir informações sobre o banco.

---

## ⚙️ Como acontece

Imagine uma aplicação que recebe:

```text
?id=10
```

O backend pode executar algo como:

```sql
SELECT * FROM users WHERE id = '10';
```

O atacante adiciona uma condição:

```sql
' AND 1=1 #
```

A consulta resultante pode ser interpretada como:

```sql
SELECT * FROM users
WHERE id = '10' AND 1=1;
```

Como:

```text
1 = 1 → VERDADEIRO
```

a aplicação pode apresentar o comportamento normal.

Agora:

```sql
' AND 1=0 #
```

Temos:

```text
1 = 0 → FALSO
```

💥 Se a resposta da aplicação mudar, o atacante consegue distinguir **verdadeiro de falso**.

---

## 🧠 A lógica booleana

A técnica utiliza valores que podem representar:

```text
VERDADEIRO → 1
FALSO      → 0
```

Operador **AND**:

```text
Verdadeiro AND Verdadeiro = Verdadeiro

Verdadeiro AND Falso = Falso

Falso AND Verdadeiro = Falso

Falso AND Falso = Falso
```

Simplificando:

```text
1 AND 1 = 1

1 AND 0 = 0
```

👉 Essa lógica permite fazer perguntas ao banco de dados.

---

## 📌 Exemplos práticos

### 🔹 1. Condição verdadeira

Em um ambiente de laboratório:

```sql
1' AND 1=1 #
```

A condição:

```text
1=1
```

é verdadeira.

Se a aplicação responder normalmente:

```text
Página normal
```

temos uma indicação de comportamento **TRUE**.

---

### 🔹 2. Condição falsa

Agora:

```sql
1' AND 1=0 #
```

A condição:

```text
1=0
```

é falsa.

Se a resposta mudar:

```text
Página diferente
```

podemos identificar o comportamento **FALSE**.

---

### 🔹 3. Fazendo perguntas ao banco

A ideia pode ser generalizada:

```sql
' AND <condição> #
```

Por exemplo, em um laboratório, uma condição poderia perguntar:

```text
"O primeiro caractere de determinado valor é 'a'?"
```

Se a aplicação responder como TRUE:

```text
SIM
```

Caso contrário:

```text
NÃO
```

💥 Repetindo esse processo, é possível reconstruir informações **caractere por caractere**.

---

## 🤖 Exploração automatizada

O processo manual seria:

```text
Pergunta
   ↓
TRUE ou FALSE?
   ↓
Anota resultado
   ↓
Próxima pergunta
```

Um script pode automatizar:

```text
Banco de dados
      ↓
Pergunta 1 → TRUE
Pergunta 2 → FALSE
Pergunta 3 → TRUE
Pergunta 4 → TRUE
      ↓
Reconstrução da informação
```

👉 É por isso que uma vulnerabilidade aparentemente simples pode permitir a extração de uma grande quantidade de informações.

---

## 🔎 Em pentest

O primeiro objetivo é identificar uma **diferença observável** entre uma condição verdadeira e uma falsa.

Por exemplo:

```text
Teste TRUE
   ↓
Resposta A

Teste FALSE
   ↓
Resposta B
```

As diferenças podem estar em:

- conteúdo da página
- tamanho da resposta
- código HTTP
- número de resultados
- redirecionamento
- mensagens exibidas
- tempo de resposta

📌 Se existe uma diferença consistente, ela pode funcionar como um **canal booleano**.

---

## ⚠️ Sobre UNION-Based SQLi

Os payloads que você colocou como:

```sql
UNION SELECT 1,2
```

```sql
UNION SELECT version(), database()
```

```sql
UNION SELECT ...
```

são mais característicos de **UNION-Based SQL Injection**, e não de **Boolean-Based Blind SQLi**.

Na Boolean-Based Blind SQLi, normalmente o atacante **não precisa que os dados apareçam diretamente na página**.

A ideia principal é:

```text
Condição verdadeira
      ↓
Resposta A

Condição falsa
      ↓
Resposta B
```

Já na UNION-Based:

```text
Consulta original
       +
UNION SELECT
       ↓
Dados aparecem na resposta
```

👉 São técnicas diferentes, embora ambas sejam formas de SQL Injection.

---

## 🚨 Impactos

Dependendo dos privilégios da aplicação no banco, uma SQL Injection pode permitir:

- leitura de dados
- descoberta da estrutura do banco
- acesso a informações de usuários
- exposição de credenciais armazenadas
- alteração de dados
- exclusão de dados
- comprometimento de outros recursos

📌 O impacto depende principalmente das **permissões do usuário utilizado pela aplicação no banco de dados**.

---

## 🛡️ Como prevenir

A principal defesa é utilizar **consultas parametrizadas (Prepared Statements)**.

Em vez de concatenar:

```python
query = "SELECT * FROM users WHERE id = '" + id + "'"
```

utilize parâmetros:

```python
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (id,))
```

Também é importante:

- utilizar Prepared Statements
- evitar concatenação de SQL com entrada do usuário
- validar entradas quando apropriado
- utilizar ORM corretamente
- aplicar o princípio do menor privilégio no banco
- evitar mensagens de erro detalhadas
- realizar testes de segurança

📌 **Regra de ouro:**

👉 **Nunca construa consultas SQL concatenando diretamente dados fornecidos pelo usuário.**