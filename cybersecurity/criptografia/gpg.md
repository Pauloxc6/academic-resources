# 🔐 Guia rápido de GPG (GnuPG)

## 📌 O que é

O GPG (GNU Privacy Guard) é uma ferramenta de criptografia que usa chaves públicas e privadas para:

- Proteger arquivos
- Garantir autenticidade (assinatura)
- Manter confidencialidade

---

# 🔑 Gerar chaves

## Criar nova chave

```bash
gpg --full-generate-key
```

### Opções recomendadas:

- Tipo: RSA and RSA
- Tamanho: 4096 bits
- Expiração: 1 ano (ou conforme necessidade)
- Nome/Email: pode usar real ou pseudônimo
- Senha: use uma senha forte

---

## Ver chaves criadas

```bash
gpg --list-keys
```

```bash
gpg --list-secret-keys
```

---

## Ver fingerprint (IMPORTANTE)

```bash
gpg --fingerprint "Nome ou Email"
```

---
## Salvar o Revoke

```shell
gpg --output revocation.crt --gen-revoke -r "Nome"
gpg --output revocation.crt --gen-revoke id-key
```

---

## 📤 Exportar chave pública

```bash
gpg --export -a "Seu Nome" > chave-publica.asc
```

## 📤 Exportar chave privada

```shell
gpg -r "Nome" --export-secret-keys > chave-privada.asc
```

## 📥 Importar chave

```bash
gpg --import chave.asc
```

## 📥 Editar chave

```shell
gpg --edit-key -r "Nome"
```

---

# 🔐 Criptografia

## Criptografar para alguém

```bash
gpg -e -r "email@exemplo.com" arquivo.txt
```

## Criptografar para múltiplos destinatários

```bash
gpg -e -r "Pessoa1" -r "Pessoa2" arquivo.txt
```

## Criptografar para você mesmo

```bash
gpg -e -r "Seu Nome" arquivo.txt
```

## Criptografia simétrica (senha)

```bash
gpg -c arquivo.txt
```

---

# 🔓 Descriptografia

```bash
gpg -d arquivo.txt.gpg > arquivo.txt
```

ou

```bash
gpg arquivo.txt.gpg
```

---

# ✍️ Assinaturas

## Assinar arquivo

```bash
gpg --sign arquivo.txt
```

## Assinatura separada

```bash
gpg --detach-sign arquivo.txt
```

---

# ✅ Verificação

## Verificar assinatura separada

```bash
gpg --verify arquivo.txt.sig
```

## Verificar arquivo assinado

```bash
gpg --verify arquivo.txt.gpg
```

---

# ⚠️ Importante

## Diferença crítica

- `.gpg` pode ser:
    - arquivo criptografado
    - arquivo assinado
- `--verify` só funciona com assinatura

---

# 🔍 Identificar tipo do arquivo

```bash
gpg --list-packets arquivo.gpg
```

- `encrypted data` → criptografado
- `signature packet` → assinado

---

# 🧠 Boas práticas (OPSEC)

- Sempre verificar fingerprint antes de confiar em uma chave
- Preferir usar Key ID ao invés de nome
- Fazer backup da chave privada:

```bash
gpg --export-secret-keys -a "Seu Nome" > privada.asc
```

- Nunca compartilhar sua chave privada

---

# 🚨 Erros comuns

## no valid recipients

Você esqueceu o `-r`

## decryption failed: No secret key

Você não possui a chave privada correta

## verify signatures failed

Você tentou verificar um arquivo criptografado

---

# 🚀 Extra

## Criptografar + assinar

```bash
gpg -e -s -r "Destino" arquivo.txt
```

---