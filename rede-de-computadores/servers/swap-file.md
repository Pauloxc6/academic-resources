# Gerenciando um Arquivo de Swap no Linux

Este guia apresenta como criar, ativar, verificar e remover um **arquivo de Swap** em sistemas Linux.

O **Swap** é uma área de memória utilizada quando a memória RAM está próxima do limite de utilização. Embora seja mais lento que a RAM, ele ajuda a evitar falhas por falta de memória (*Out of Memory*).

---

# O que é Swap?

O Swap funciona como uma extensão da memória RAM.

```text
                +----------------+
                |      CPU       |
                +-------+--------+
                        │
                +-------▼--------+
                |      RAM       |
                +-------+--------+
                        │
          Memória cheia │
                        ▼
                +----------------+
                |      Swap      |
                |  /swapfile     |
                +----------------+
```

---

# Verificando a Memória Atual

Antes de criar o Swap, verifique a utilização da memória:

```bash
free -h
```

ou

```bash
swapon --show
```

---

# Criando um Arquivo Swap

## Método 1 - Utilizando `fallocate` (Recomendado)

Crie um arquivo de **2 GB**:

```bash
sudo fallocate -l 2G /swapfile
```

---

## Método 2 - Utilizando `dd`

Caso `fallocate` não esteja disponível ou o sistema de arquivos não o suporte:

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
```

> Para criar um Swap de outro tamanho, altere o valor de `count`.

---

# Ajustando as Permissões

Apenas o usuário **root** deve possuir acesso ao arquivo.

```bash
sudo chmod 600 /swapfile
```

Verifique:

```bash
ls -lh /swapfile
```

Resultado esperado:

```text
-rw------- 1 root root 2.0G ...
```

---

# Formatando o Arquivo

Inicialize o arquivo como área de Swap.

```bash
sudo mkswap /swapfile
```

Saída esperada:

```text
Setting up swapspace version 1
```

---

# Ativando o Swap

```bash
sudo swapon /swapfile
```

Verifique:

```bash
sudo swapon --show
```

Exemplo:

```text
NAME       TYPE  SIZE USED PRIO
/swapfile  file   2G   0B   -2
```

---

# Tornando Permanente

Edite:

```text
/etc/fstab
```

Adicione a seguinte linha:

```fstab
/swapfile none swap sw 0 0
```

Ou:

```fstab
/swapfile swap swap defaults 0 0
```

Teste:

```bash
sudo mount -a
```

---

# Verificando o Swap

Utilizando `swapon`:

```bash
sudo swapon --show
```

Exemplo:

```text
NAME       TYPE  SIZE USED PRIO
/swapfile  file   2G  500M   -2
```

---

Utilizando `free`:

```bash
free -h
```

Exemplo:

```text
               total   used   free  shared  buff/cache available
Mem:            8Gi    2Gi    3Gi    120Mi      3Gi        5Gi
Swap:           2Gi    0Mi    2Gi
```

---

# Ajustando a Swappiness

A **Swappiness** define o quanto o Linux utilizará o Swap.

Verificar o valor atual:

```bash
cat /proc/sys/vm/swappiness
```

Valores comuns:

| Valor | Descrição |
|--------|-----------|
| 10 | Utiliza pouco o Swap |
| 20 | Recomendado para desktops |
| 60 | Padrão da maioria das distribuições |
| 100 | Utiliza o Swap com maior frequência |

Alterar temporariamente:

```bash
sudo sysctl vm.swappiness=20
```

Alterar permanentemente:

Edite:

```text
/etc/sysctl.conf
```

Adicione:

```text
vm.swappiness=20
```

Aplicar:

```bash
sudo sysctl -p
```

---

# Removendo o Swap

## 1. Desativar

```bash
sudo swapoff -v /swapfile
```

---

## 2. Remover do fstab

Edite:

```text
/etc/fstab
```

Remova a linha:

```fstab
/swapfile swap swap defaults 0 0
```

ou

```fstab
/swapfile none swap sw 0 0
```

---

## 3. Excluir o Arquivo

```bash
sudo rm /swapfile
```

---

# Comandos Úteis

Verificar Swap:

```bash
swapon --show
```

Verificar memória:

```bash
free -h
```

Mostrar dispositivos Swap:

```bash
cat /proc/swaps
```

Ativar:

```bash
sudo swapon /swapfile
```

Desativar:

```bash
sudo swapoff /swapfile
```

---

# Arquivos Importantes

```text
/swapfile

/etc/fstab

/etc/sysctl.conf
```

---

# Observações

- O arquivo de Swap deve possuir permissões `600` para impedir acesso por outros usuários.
- Em sistemas modernos, o uso de um **arquivo de Swap** é geralmente mais flexível do que uma partição dedicada.
- O Swap não substitui memória RAM; ele apenas evita falhas por falta de memória, com desempenho significativamente inferior.
- Em sistemas com SSD, o uso de Swap é seguro, mas recomenda-se ajustar o parâmetro `vm.swappiness` conforme a carga de trabalho para reduzir gravações desnecessárias.
- Após alterar o arquivo `/etc/fstab`, utilize `mount -a` para verificar se a configuração está correta antes de reiniciar o sistema.