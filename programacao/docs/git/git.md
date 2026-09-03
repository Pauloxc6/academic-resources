![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Versão](https://img.shields.io/badge/version-1.0-blue)

# 📖 Guia Git para desenvolvedores

É um sistema de controle de versões distribuído, usado principalmente no desenvolvimento de software, mas pode ser usado para registrar o histórico de edições de qualquer tipo de arquivo.

---

## 📋 Índice

1. [Introdução](#-introdução)
2. [Instalação e Configuração](#-instalação-e-configuração)
3. [Operações Básicas via CLI](#-operações-básicas-via-cli)
4. [Integração com bash](#-integração-com-bash)
5. [Exemplo Prático](#-exemplo-prático)
6. [Ferramentas Extras](#-ferramentas-extras)
7. [Referências](#-referências)

---

## 🚀 Introdução

- O que é **Git**?

  - Sistema de controle de versão distribuído.
  - Rastreia mudanças em arquivos ao longo do tempo.
  - Permite trabalho colaborativo.

- Git vs. GitHub/GitLab

  - Git: Ferramenta de versionamento local.
  - GitHub/GitLab: Plataformas que hospedam repositórios Git na nuvem.

---

## 🔧 Instalação e Configuração

**Linux**:

```bash
# Exemplo de instalação
sudo apt update && sudo apt install git
```

## Windows:

- Baixe em [git-scm.com](https://git-scm.com/downloads)
- Extraia e adicione ao **PATH**

## Verificação:

```bash
git --version
```

## Configuração

```bash
git config --global config.username "Username"   # Adiciona um Usuário
git config --global config.email "user@mail.com" # Adiciona um Email

git config --list                                # Mostra as config atuais
```

---

## 💻 Operações Básicas via CLI

### Comandos Básicos

```bash
git init                                # Inicia um repositório .git local
git status                              # Mostra os arquivos novos/modificados
git add README.md                       # Adiciona somente um arquivo a stage
git add .                               # Adiciona todos os arquivos a stage
git commit -m "Mensagem para o commit"  # Salva todas as alterações em um commit
```

### Clone de um repositório remoto

```bash
git clone https://github.com/Username/repo.git
```

### Vereficar o histórico de commits

```bash
git log             # Log completo de alteração
git log --oneline   # Log resumido das alterações
```

---

### Branchs

Criação e mudança entre branchs:

```bash
git branch                  # Lista todas branchs
git branch new-branch       # Cria uma nova branch
git checkout new-branch     # Muda para um branch
git checkout -b new-branch  # Cria e altera para branch criada
```

### Renomear branchs

```bash
git branch -m nome-antigo nome-novo       # Renomeia local
git push origin :nome-antigo nome-novo    # Atualiza no remoto
git push origin -u nome-novo              # Define upstream
```

### Deletar uma branch

```bash
git branch -d nome-da-branch             # Deleta local (se já mesclada)
git branch -D nome-da-branch             # Força exclusão (não mesclada)
git push origin --delete nome-da-branch  # Deleta no remoto
```

### Listar branchs

```bash
git branch -r              # Mostra branches remotas
git branch -a              # Mostra todas (locais + remotas)
```

### Mesclar branchs (Merge)

```bash
git checkout main           # Muda para branch principal
git merge nome-da-branch    # Mescla a branch nome-da-branch com a branch main
```

---

## Repositórios Remotos (Github/Gitlab)

### Conectando ao repositório remoto

```bash
git remote add origin https://github.com/username/repo.git
git remote -v
```

### Eviando Alterações

```bash
git push -u origin main # Primeiro push (Define o upstream)
git push                # Demais push
```

### Baixando Alterações

```bash
git pull origin main
```

---

## Trabalhando com Rebase (em vez de Merge)

### Rebase Básico

- Objetivo: Reaplicar commits de uma branch em outra, mantendo o histórico linear.

```bash
git checkout minha-branch
git rebase main            # Aplica seus commits em cima do main
```

### Rebase Interativo (Para Editar Commits)

```bash
git rebase -i HEAD~3       # Edita os últimos 3 commits
```

- Opções no rebase interativo:

  - **pick** → Mantém o commit.

  - **reword** → Altera a mensagem.

  - **edit** → Pausa para modificar o commit.

  - **squash** → Combina com o commit anterior.

  - **drop** → Remove o commit.

---

## Stash (Salvamento Temporário)

### Guardar Alterações Sem Commit

```bash
git stash                     # Salva as mudanças na "stash"
git stash push -m "mensagem"  # Stash com descrição
```

### Listar e Recuperar Stash

```bash
git stash list              # Mostra todas as stashes
git stash apply stash@{0}   # Aplica a stash mais recente
git stash pop               # Aplica e remove a última stash
```

### Limpar Stash

```bash
git stash drop stash@{0}    # Remove uma stash específica
git stash clear             # Limpa todas as stashes
```

---

## Revertendo Alterações

### Desfazer um Commit (Sem Apagar Histórico)

```bash
git revert HEAD             # Cria um novo commit desfazendo o último
git revert hash-do-commit   # Reverte um commit específico
```

### Reset (Cuidado! Altera Histórico)

```bash
git reset --soft HEAD~1     # Remove commit, mantém alterações no stage
git reset --mixed HEAD~1    # Remove commit e tira do stage (padrão)
git reset --hard HEAD~1     # Remove commit E descarta alterações (PERIGOSO)
```

### Recuperar Arquivos Deletados

```bash
git checkout HEAD -- arquivo-deletado.txt
```

---

## Tags (Versões)

### Criar e Listar Tags

```bash
git tag v1.0.0                          # Tag leve
git tag -a v1.0.0 -m "Release inicial"  # Tag anotada
git tag                                 # Lista todas as tags
```

### Enviar Tags para o Remoto

```bash
git push origin v1.0.0      # Envia uma tag
git push origin --tags      # Envia todas as tags
```

### Deletar Tags

```bash
git tag -d v1.0.0                # Deleta local
git push origin --delete v1.0.0  # Deleta no remoto
```

---

## Gitignore e Arquivos Rastreados

### Ignorar Arquivos (.gitignore)

- Crie um arquivo .gitignore e adicione padrões:

```
node_modules/
*.log
.env
```

### Remover Arquivos Já Rastreados

```bash
git rm --cached arquivo.txt   # Remove do Git, mas mantém no disco
```

---

## 📝 Integração com Bash

Script de inicialização de um projeto

```bash
root="$PWD/myapp"

if [[ ! -e "$root" ]]; then
    echo "[!] Error: repositório $root local não existe!"
    echo "[+] Criando repositório $root"
    mkdir -p "$root"
fi

echo "[+] Incializando o repositório $root"
cd "$root" || exit 1

# Criação básica
git init
git status

# Create README.md
if [[ ! -f "README.md" ]]; then
    echo "# Meu Projeto" > README.md
fi

# Adicionando os alterações a stage
git add .

# Commit inicail
git commit -m "Initial commit"

# Repositorio remoto
echo "[-] Repositório remoto:"
git remote -v
```

## 📊 Exemplo Prático

Desenvolvimento de uma Calculadora Simples

**Passo 1: Configuração Inicial**

```bash
# Criar diretório do projeto e inicializar Git
mkdir calculadora
cd calculadora
git init

# Configurar usuário
git config user.name "Seu Nome"
git config user.email "seu@email.com"
```

**Passo 2: Primeiro Commit (main)**

```bash
# Criar arquivo principal
echo "# Calculadora Simples" > README.md
echo "console.log('Bem-vindo à calculadora!');" > calculadora.js

# Primeiro commit
git add .
git commit -m "Initial commit: estrutura básica"
```

**Passo 3: Criar Branch para Nova Funcionalidade**

```bash
# Criar branch para feature de soma
git checkout -b feature/soma
```

**Passo 4: Desenvolver na Nova Branch**

```bash
# Adicionar funcionalidade de soma
cat << 'EOF' > calculadora.js
function somar(a, b) {
    return a + b;
}

console.log("Soma de 2 + 3:", somar(2, 3));
EOF

# Commitar na feature branch
git add calculadora.js
git commit -m "feat: adiciona função de soma"
```

**Passo 5: Simular Desenvolvimento Paralelo**

```bash
# Voltar para main e criar outra feature
git checkout main
git checkout -b feature/subtracao

# Desenvolver subtração
cat << 'EOF' > calculadora.js
function subtrair(a, b) {
    return a - b;
}

console.log("Subtração de 5 - 2:", subtrair(5, 2));
EOF

git add calculadora.js
git commit -m "feat: adiciona função de subtração"
```

**Passo 6: Merge das Features**

```bash

# Merge da feature de soma para main
git checkout main
git merge feature/soma

# Merge da feature de subtração (simulará conflito)
git merge feature/subtracao
```

**Passo 7: Resolver Conflito**

```bash
# Git mostrará conflito no arquivo calculadora.js
# Editar manualmente o arquivo para ficar assim:
cat << 'EOF' > calculadora.js
function somar(a, b) {
    return a + b;
}

function subtrair(a, b) {
    return a - b;
}

console.log("Soma de 2 + 3:", somar(2, 3));
console.log("Subtração de 5 - 2:", subtrair(5, 2));
EOF

# Resolver conflito
git add calculadora.js
git commit -m "fix: resolve conflito entre soma e subtração"
```

**Passo 8: Adicionar Remote e Push**

```bash
# Conectar ao repositório remoto (exemplo GitHub)
git remote add origin https://github.com/usuario/calculadora.git
git branch -M main
git push -u origin main

# Fazer push das branches de feature
git push origin feature/soma
git push origin feature/subtracao
```

**Passo 9: Tag de Versão**

```bash

# Criar tag para release
git tag -a v1.0.0 -m "Versão inicial com soma e subtração"
git push origin v1.0.0
```

**📊 Visualização do Histórico**

```bash

# Ver histórico gráfico
git log --oneline --graph --all

# Resultado esperado:
# *   a1b2c3d (HEAD -> main) fix: resolve conflito
# |\
# | * d4e5f6g (feature/subtracao) feat: adiciona subtração
# * | c7h8i9j (feature/soma) feat: adiciona soma
# |/
# * k0l1m2n Initial commit
```

**🛠 Comandos Úteis para Verificação**

```bash

# Ver status atual
git status

# Ver diferenças
git diff

# Ver branches
git branch -av

# Ver tags
git tag -n
```

**🎨 Exemplo de Arquivo Final**

**calculadora.js:**

```javascript
function somar(a, b) {
  return a + b;
}

function subtrair(a, b) {
  return a - b;
}

console.log("Soma de 2 + 3:", somar(2, 3));
console.log("Subtração de 5 - 2:", subtrair(5, 2));
```

## 🛠️ Ferramentas Extras

Gitkraken → www.gitkraken.com

Gitg → flathub.org/pt-BR/apps/org.gnome.gitg

QGit → sourceforge.net/projects/qgit

## 📚 Referências

- Documentação Oficial : [git-scm.com](https://git-scm.com/doc)

## 📜 Licença

[MIT License](../../../LICENSE) © 2025 Seu Nome
