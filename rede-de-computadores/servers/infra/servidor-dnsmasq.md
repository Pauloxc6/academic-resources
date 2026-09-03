# Servidor DNS com Dnsmasq

Este guia apresenta a instalação e configuração do **Dnsmasq** como servidor DNS local com cache, resolução de nomes personalizados e suporte opcional a DNSSEC.

---

# Topologia

```text
                   INTERNET
                       │
                  8.8.8.8
                       │
                +--------------+
                |   Dnsmasq    |
                | 192.168.10.2 |
                +------+-------+
                       │
      ┌────────────────┼────────────────┐
      │                │                │
 Cliente 1        Cliente 2        Cliente N
```

---

# 1. Desabilitando o systemd-resolved

Desabilite o serviço responsável pela resolução de nomes do systemd.

```bash
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

---

# 2. Removendo o Link Simbólico do resolv.conf

Verifique o arquivo atual:

```bash
ls -lh /etc/resolv.conf
```

Remova o link simbólico:

```bash
sudo unlink /etc/resolv.conf
```

---

# 3. Criando um Novo resolv.conf

Configure um servidor DNS temporário para acesso à Internet.

```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

---

# 4. Instalando o Dnsmasq

Atualize os repositórios:

```bash
sudo apt update
```

Instale o Dnsmasq:

```bash
sudo apt install dnsmasq -y
```

Verifique o serviço:

```bash
sudo systemctl status dnsmasq
```

---

# 5. Configurando o Dnsmasq

Edite o arquivo:

```text
/etc/dnsmasq.conf
```

```bash
sudo nano /etc/dnsmasq.conf
```

Exemplo de configuração:

```conf
port=53

domain-needed
bogus-priv
strict-order

expand-hosts

domain=example.com

listen-address=127.0.0.1
```

### Explicação

| Diretiva | Função |
|----------|--------|
| port | Porta utilizada pelo DNS |
| domain-needed | Ignora consultas sem domínio |
| bogus-priv | Bloqueia consultas reversas inválidas |
| strict-order | Consulta os servidores DNS na ordem definida |
| expand-hosts | Acrescenta automaticamente o domínio definido |
| domain | Domínio padrão |
| listen-address | Interface onde o serviço ficará escutando |

---

# 6. Ativando DNSSEC (Opcional)

Para ativar validação DNSSEC, edite:

```bash
sudo nano /etc/dnsmasq.conf
```

Descomente ou adicione:

```conf
dnssec
```

---

# 7. Reiniciando o Serviço

```bash
sudo systemctl restart dnsmasq
```

Verifique o status:

```bash
sudo systemctl status dnsmasq
```

---

# 8. Adicionando Registros Locais

Edite:

```text
/etc/hosts
```

```bash
sudo nano /etc/hosts
```

Adicione os registros desejados:

```text
10.1.3.4      server1.mypridomain.com
10.1.4.4      erp.mypridomain.com
192.168.10.2  checkout.mypridomain.com
192.168.4.3   hello.world
```

Reinicie novamente:

```bash
sudo systemctl restart dnsmasq
```

---

# 9. Configurando o Cliente DNS

Edite:

```text
/etc/resolv.conf
```

Configure:

```text
nameserver 127.0.0.1
nameserver 8.8.8.8
```

Assim o sistema consultará primeiro o Dnsmasq local.

---

# 10. Testando

Consultar um registro:

```bash
dig erp.mypridomain.com A
```

Resposta simplificada:

```bash
dig checkout.mypridomain.com A +noall +answer
```

Consultar outro registro:

```bash
dig server1.mypridomain.com
```

Utilizando o nslookup:

```bash
nslookup hello.world
```

---

# Comandos Úteis

Reiniciar:

```bash
sudo systemctl restart dnsmasq
```

Parar:

```bash
sudo systemctl stop dnsmasq
```

Iniciar:

```bash
sudo systemctl start dnsmasq
```

Status:

```bash
sudo systemctl status dnsmasq
```

Habilitar na inicialização:

```bash
sudo systemctl enable dnsmasq
```

Verificar logs:

```bash
sudo journalctl -u dnsmasq
```

Acompanhar logs em tempo real:

```bash
sudo journalctl -fu dnsmasq
```

---

# Estrutura dos Arquivos

```text
/etc/dnsmasq.conf
/etc/hosts
/etc/resolv.conf
```

---

# Observações

- O Dnsmasq funciona como servidor DNS, cache DNS e encaminhador (forwarder).
- Sempre utilize `127.0.0.1` como primeiro servidor DNS quando o Dnsmasq estiver instalado localmente.
- Os registros definidos em `/etc/hosts` têm prioridade sobre consultas externas.
- O recurso `dnssec` aumenta a segurança validando respostas DNS assinadas, porém pode aumentar ligeiramente o tempo das consultas.
- Caso o Dnsmasq utilize outra interface além do loopback (`127.0.0.1`), altere a diretiva `listen-address` para o endereço IP correspondente.