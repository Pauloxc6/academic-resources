# 🖼️ Esteganografia + Geração de Imagens (CLI Linux)

## 📌 Conceito

**Esteganografia** = esconder um arquivo dentro de outro (ex: imagem)  
**Criptografia** = proteger o conteúdo

👉 O ideal é usar os dois juntos

---

# 🖼️ Gerando imagens via CLI

## 🔧 Usando ImageMagick

### Criar imagem preta

```bash
convert -size 800x600 xc:black imagem.png
```

### Criar imagem branca

```bash
convert -size 800x600 xc:white imagem.png
```

### Gerar gradiente

```bash
convert -size 800x600 gradient: imagem.png
```

### Gerar imagem com ruído (ótimo para esteganografia)

```bash
convert -size 1024x1024 plasma:fractal imagem.jpg
```

---

## 🎨 Adicionar texto na imagem

```bash
convert -size 800x600 xc:black \
-fill white -gravity center -pointsize 40 \
-annotate 0 "SEGREDO" imagem.png
```

---

## 📦 Gerar imagem a partir de dados aleatórios

```bash
head -c 100000 /dev/urandom > random.bin
convert -size 256x256 -depth 8 gray:random.bin imagem.png
```

---

# 🔐 Esteganografia

## 🧰 Ferramentas

- steghide → esconder arquivos com senha
- outguess → alternativa compatível com JPEG
- binwalk → análise/extrair dados ocultos
- stegseek → faz o crack de senhas

---

## 📥 Método simples (concatenação)

```bash
cat imagem.jpg segredo.txt > imagem_fake.jpg
```

### Extrair

```bash
binwalk imagem_fake.jpg
```

---

# 🔐 Steghide (recomendado)

### Esconder arquivo

```bash
steghide embed -cf imagem.jpg -ef segredo.txt
```

### Esconder arquivo com saída personalizada

```bash
steghide embed -cf imagem.jpg -ef segredo.txt -sf imagem_final.jpg
```

### Extrair arquivo

```bash
steghide extract -sf imagem.jpg
```

---

# 🔐 Outguess

### Esconder arquivo

```bash
outguess -k senha -d segredo.txt imagem.jpg imagem_saida.jpg
```

### Extrair arquivo

```bash
outguess -k senha -r imagem_saida.jpg arquivo_extraido.txt
```

---
# 🔐 Stegseek

## Crack

```bash
stegseek --crack -sf imagem_saida.jpg -wl /opt/rockyou.txt -xf output
```


---

# 🔒 Método recomendado (camada dupla)

### 1. Criptografar arquivo

```bash
gpg -c segredo.txt
```

### 2. Esconder arquivo criptografado

```bash
steghide embed -cf imagem.jpg -ef segredo.txt.gpg
```

---

# 🔍 Análise e detecção

## Ver conteúdo oculto

```bash
binwalk imagem.jpg
```

## Extrair automaticamente

```bash
binwalk -e imagem.jpg
```

---

# ⚠️ Boas práticas

- Use imagens grandes e com ruído (menos suspeito)
- Evite imagens muito simples (preta/branca)
- Sempre criptografe antes de esconder
- Teste com ferramentas de análise

---

# 🚨 Limitações

- Pode ser detectado por análise forense
- Arquivos grandes podem distorcer a imagem
- JPEG funciona melhor na maioria dos casos

---

# 🧠 Workflow recomendado

1. Gerar imagem com ruído
2. Criptografar arquivo
3. Esconder na imagem
4. Testar com binwalk

---

# 🚀 Exemplo completo

```bash
# gerar imagem
convert -size 1024x1024 plasma:fractal base.jpg

# criptografar
gpg -c segredo.txt

# esconder com steghide
steghide embed -cf base.jpg -ef segredo.txt.gpg -sf final.jpg

# verificar
binwalk final.jpg
```

---