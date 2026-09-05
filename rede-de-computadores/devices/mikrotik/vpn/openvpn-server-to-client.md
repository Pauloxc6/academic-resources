### Certificado CA

```
certificate add name=CA-tpl common-name="CA" key-size=4096 days-valid=3650 key-usage=crl-sign,key-cert-sign
certificate sign CA-tpl ca-crl-host=127.0.0.1 name="CA"
```

### Certificado Server

```
certificate add name=Server-tpl common-name="172.16.0.2" key-size=4096 days-valid=1095 key-usage=digital-signature,key-encipherment,tls-server
certificate sign Server-tpl ca="CA" name="Server"
```

### Cliente

```
certificate add name=Cliente-tpl common-name="Cliente" key-size=4096 days-valid=3650 key-usage=tls-client
certificate add name=Cliente1 copy-from=Cliente-tpl common-name="Cliente1"
certificate sign Cliente1 ca="CA" name="Cliente1"
```

### Export

```
certificate export-certificate CA export-passphrase=""
certificate export-certificate Cliente1 export-passphrase=12345678
```