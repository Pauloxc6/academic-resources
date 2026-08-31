# 🌱 Spring4Shell — CVE-2022-22965

## 🧠 O que é Spring4Shell?

**Spring4Shell** é o nome dado à vulnerabilidade **CVE-2022-22965**, uma falha crítica de **execução remota de código (RCE)** relacionada ao **Spring Framework**.

Ela ficou conhecida como _Spring4Shell_ por causa da comparação com a **Log4Shell**, embora sejam vulnerabilidades diferentes e afetem componentes distintos.

O problema estava relacionado à forma como determinadas aplicações Spring realizavam **data binding** de parâmetros HTTP para objetos Java.

Em determinadas configurações, um atacante poderia manipular propriedades internas de objetos, incluindo propriedades relacionadas ao `class` e ao `ClassLoader`, criando condições para alteração de configuração e, em cenários específicos, execução de código.

---

## ⚙️ Como funciona

O fluxo simplificado é:

```text
Requisição HTTP
       │
       ▼
Parâmetros controlados pelo usuário
       │
       ▼
Spring Data Binding
       │
       ▼
Objeto Java
       │
       ▼
Propriedades internas
       │
       ▼
Configuração manipulada
       │
       ▼
RCE
```

A vulnerabilidade estava principalmente associada a determinadas combinações de:

- Spring Framework vulnerável;
- JDK 9 ou superior
- Aplicação utilizando determinadas formas de data binding;
- Aplicação empacotada como WAR;
- Servidor/ambiente compatível com o cenário de exploração.

📌 Portanto, **não significa que toda aplicação Spring estivesse automaticamente vulnerável**.

---

## 🔎 O problema com `class` e `ClassLoader`

O Spring possuía mecanismos destinados a impedir que propriedades internas fossem manipuladas diretamente por entrada externa.

O problema surgiu porque determinadas funcionalidades introduzidas no Java 9 permitiam que essa proteção fosse contornada em condições específicas.

O conceito pode ser representado assim:

```text
Entrada HTTP
     │
     ▼
Data Binding
     │
     ├── propriedade normal
     │
     └── propriedade interna
              │
              ▼
         ClassLoader
              │
              ▼
       Configuração alterada
```

Isso poderia permitir modificar propriedades que normalmente não deveriam estar sob controle do usuário.

---

# 🎯 Impacto

Em um cenário vulnerável, o impacto potencial poderia incluir:

- Execução remota de código;
- Comprometimento da aplicação;
- Leitura e alteração de arquivos;
- Roubo de informações;
- Comprometimento do servidor;
- Utilização do servidor como ponto de entrada para outros ataques.

A gravidade dependia da configuração específica da aplicação.

---

# 🌐 Exemplo de aplicação

Imagine uma aplicação Spring:

```text
http://example.com/helloworld/greeting
```

Ela recebe parâmetros HTTP e os utiliza para preencher objetos Java.

O problema ocorre quando parâmetros controlados pelo usuário conseguem atingir propriedades que deveriam estar protegidas.

---

# 🧪 Exploração

Diferentemente de vulnerabilidades simples de parâmetro, a exploração do Spring4Shell normalmente envolve uma **cadeia específica de manipulação de propriedades** para alterar a configuração da aplicação.

Em demonstrações históricas, o objetivo final poderia ser obter execução de comandos através de um JSP controlado pelo atacante.

Por exemplo, uma vez que uma webshell estivesse presente no laboratório:

```text
http://example.com/shell.jsp?cmd=id
```

O parâmetro:

```text
cmd=id
```

representaria o comando a ser executado pela shell.

⚠️ Esse exemplo pressupõe que uma etapa anterior da exploração já conseguiu criar a webshell; acessar simplesmente `/shell.jsp` não é, por si só, a exploração do Spring4Shell.

---

# 🔍 Detecção

Durante um pentest autorizado, uma abordagem inicial é identificar:

```text
Spring Framework
        │
        ├── versão
        ├── Java/JDK
        ├── tipo de empacotamento
        ├── servidor de aplicação
        └── utilização de data binding
```

Também existem ferramentas de **scanning** desenvolvidas para identificar possíveis instalações vulneráveis.

```text
spring4shell-scanner
```

📌 Um scanner deve ser tratado como **indicador**, e não como prova definitiva de exploração.

---

# 🛡️ Correção

A principal medida é:

```text
Atualizar o Spring Framework
        +
Atualizar dependências relacionadas
        +
Aplicar patches do fornecedor
```

Também é recomendado:

- Manter o JDK atualizado;
- Atualizar o servidor de aplicação;
- Não expor propriedades internas através de parâmetros;
- Aplicar validação adequada de entrada;
- Utilizar princípio do menor privilégio;
- Monitorar requisições suspeitas.

---

# 📚 Resumo

```text
Nome:        Spring4Shell
CVE:         CVE-2022-22965
Framework:   Spring Framework
Tipo:        Remote Code Execution (RCE)
Componente:  Data Binding
Condição:    Configuração específica
Impacto:     Possível execução arbitrária de código
```

### 🎯 Cadeia resumida

```text
Parâmetro HTTP
      │
      ▼
Spring Data Binding
      │
      ▼
Manipulação de propriedades
      │
      ▼
Class / ClassLoader
      │
      ▼
Alteração de configuração
      │
      ▼
Possível RCE
```