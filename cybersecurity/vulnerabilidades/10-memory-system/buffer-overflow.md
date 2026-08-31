# 💥 Buffer Overflow (Estouro de Buffer)

## 🧠 O que é Buffer Overflow?

**Buffer Overflow**, ou **estouro de buffer**, ocorre quando um programa tenta armazenar mais dados do que o espaço de memória reservado para determinada região.

Um **buffer** é uma área de memória utilizada temporariamente para armazenar dados.

Quando o programa não verifica corretamente o tamanho da entrada, dados adicionais podem ultrapassar os limites do buffer e sobrescrever regiões adjacentes da memória.

```text
Buffer reservado
┌────────────────────────┐
│ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │
└────────────────────────┘
              ▲
              │
          8 bytes

Entrada maior:
┌────────────────────────┐
│ A │ A │ A │ A │ A │ A │ A │ A │
└────────────────────────┘
┌─────── Dados extras ────┐
│ A │ A │ A │ A │ ...     │
└─────────────────────────┘
              │
              ▼
       Sobrescreve memória
```

Dependendo do programa e do contexto, isso pode causar:

- Crash da aplicação;
- Corrupção de memória;
- Alteração do fluxo de execução;
- Negação de serviço;
- Em determinadas condições, **execução arbitrária de código**.

---

# ⚙️ Por que acontece?

Linguagens como **C e C++** permitem manipulação direta de memória e não realizam automaticamente todas as verificações de limites.

Por isso, funções que não verificam adequadamente o tamanho da entrada podem introduzir vulnerabilidades.

Por exemplo:

```c
void askForUsername()
{
    char buffer[8];

    printf("Digite seu usuário:\n");
    scanf("%s", buffer);

    printf("Você digitou: %s\n", buffer);
}

int main()
{
    while(1)
        askForUsername();

    return 0;
}
```

O problema está principalmente aqui:

```c
scanf("%s", buffer);
```

O buffer possui espaço para apenas **8 bytes**, mas `%s` não impõe, nesse código, um limite compatível com o tamanho de `buffer`.

Uma entrada maior pode ultrapassar os limites da memória reservada.

---

# 🧪 Exemplo

Imagine:

```text
buffer[8]
```

E o usuário fornece:

```text
AAAAAAAAAAAA
```

São **12 caracteres**, enquanto o buffer possui espaço para 8.

Conceitualmente:

```text
Memória:

┌─────── buffer ────────┐
│ A A A A A A A A       │
└───────────────────────┘
                        │
                        ▼
                 dados extras
                 A A A A
```

Os bytes excedentes podem sobrescrever dados armazenados logo após o buffer.

---

# 🧠 O que pode existir depois do buffer?

Dependendo da arquitetura, compilador e contexto, outras informações podem estar próximas na memória, como:

```text
┌─────────────────────┐
│ Buffer              │
├─────────────────────┤
│ Outras variáveis    │
├─────────────────────┤
│ Metadados           │
├─────────────────────┤
│ Frame Pointer       │
├─────────────────────┤
│ Return Address      │
└─────────────────────┘
```

Em determinados cenários, sobrescrever informações relacionadas ao fluxo de execução pode permitir que um atacante altere o comportamento do programa.

---

# 💻 Buffer Overflow e Shellcode

Historicamente, uma técnica utilizada em determinadas explorações consistia em colocar instruções de máquina controladas pelo atacante na memória e manipular o fluxo de execução para chegar até elas.

Um conceito clássico é o **NOP sled**:

```text
┌─────────────────────────────────────┐
│ NOP │ NOP │ NOP │ NOP │ NOP │ ... │
└─────────────────────────────────────┘
                                  │
                                  ▼
                              Shellcode
```

`NOP` significa **No Operation**.

A ideia histórica era aumentar a margem de erro do endereço de execução: se o fluxo caísse em qualquer ponto da sequência de NOPs, ele avançaria até o código.

📌 Técnicas modernas de exploração são mais complexas e normalmente precisam lidar com mecanismos de proteção como **ASLR, DEP/NX e Stack Canaries**.

---

# 🛡️ Proteções modernas

Sistemas atuais possuem várias proteções contra exploração de corrupção de memória:

### Stack Canary

Um valor colocado próximo aos dados protegidos da stack.

```text
Buffer
  │
  ▼
Canary
  │
  ▼
Return Address
```

Se o buffer for sobrescrito e o canary for alterado, o programa pode detectar a corrupção antes de utilizar o endereço de retorno.

### ASLR

**Address Space Layout Randomization** altera a localização de regiões importantes da memória, dificultando a previsão de endereços.

### DEP / NX

Impede, quando suportado e configurado, que determinadas regiões de memória sejam executadas como código.

---

# 🧑‍💻 Linguagens de memória gerenciada

Linguagens como:

```text
Java
C#
Python
Ruby
JavaScript
```

possuem mecanismos que evitam muitos tipos tradicionais de buffer overflow em código normal.

Por exemplo, Java verifica os limites de um array:

```java
try {
    String[] array = {"a", "b", "c"};

    array[25] = "z";
}
catch (ArrayIndexOutOfBoundsException e) {
    e.printStackTrace();
}
```

Nesse caso, o acesso inválido gera uma exceção em vez de simplesmente escrever em uma região arbitrária da memória.

📌 Isso **não significa que aplicações nessas linguagens sejam imunes a corrupção de memória em qualquer circunstância**. Bibliotecas nativas, componentes escritos em C/C++, runtimes e dependências podem introduzir esse tipo de vulnerabilidade.

---

# 🌐 Buffer Overflow em aplicações Web

Embora a aplicação Web possa ser escrita em:

```text
Python
PHP
Java
Ruby
Node.js
```

ela pode depender de componentes escritos em linguagens de baixo nível:

```text
Aplicação Web
      │
      ▼
Runtime / Framework
      │
      ▼
Biblioteca nativa
      │
      ▼
C / C++
      │
      ▼
Sistema operacional
```

Por isso, vulnerabilidades de corrupção de memória podem afetar servidores Web, bibliotecas, runtimes e outros componentes da infraestrutura.

---

# 🔐 Como evitar

Em C/C++, é fundamental controlar os limites das operações de memória.

Por exemplo, evite:

```c
scanf("%s", buffer);
```

e utilize mecanismos que permitam limitar a quantidade de dados recebidos.

Também é importante:

- Validar o tamanho das entradas;
- Utilizar funções seguras de manipulação de memória;
- Ativar proteções do compilador;
- Utilizar ASLR e DEP/NX;
- Manter bibliotecas e runtimes atualizados;
- Realizar testes com sanitizers, como **AddressSanitizer (ASan)**;
- Preferir abstrações que controlem automaticamente os limites quando possível.

---

# 📚 Resumo

```text
Nome:       Buffer Overflow
Tipo:       Memory Corruption
Causa:      Escrita além dos limites do buffer
Comum em:   C, C++, Assembly
Impactos:   Crash, corrupção de memória, DoS e possível RCE
```

### 🎯 Cadeia simplificada

```text
Entrada controlada pelo usuário
            │
            ▼
     Buffer pequeno
            │
            ▼
   Falta de validação
            │
            ▼
      Buffer Overflow
            │
       ┌────┴────┐
       ▼         ▼
     Crash    Memória
              corrompida
                 │
                 ▼
          Possível alteração
          do fluxo de execução
```