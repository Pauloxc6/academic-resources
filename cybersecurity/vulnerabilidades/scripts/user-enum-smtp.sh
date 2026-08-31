#!/usr/bin/env bash
#======================================================
# BANNER
#======================================================

figlet "SMTP User Enum"
echo "By: @Pauloxc6"

# Proteção para o código em caso de error
set -euo pipefail

#======================================================
# CONFIGURAÇÕES E VARIÁVEIS GLOBAIS
#======================================================

verbose=0
ssl_enable="false"
ip="127.0.0.1"
port="25"
wordlist=""
mode_attack="VRFY"

#======================================================
# MÓDULO DE RECONHECIMENTO (FINGERPRINTING)
#======================================================

function teste_mode(){
    # Array indexado simples
    local modes=("VRFY" "EXPN")

    for mode in "${modes[@]}"; do
        [[ "$verbose" -eq 1 ]] && echo "Testando o modo: $mode"

        # Captura a resposta, remove o banner 220 e pega o código de status (primeiros 3 dígitos)
        # 250/252 geralmente indicam sucesso no VRFY/EXPN
        response=$(nc "$ip" "$port" <<< "$mode root" | grep -v "^220" | head -n 1 | cut -c 1-3)

        if [[ "$response" =~ ^(250|252) ]]; then
             echo "[+] O servidor tem o modo $mode HABILITADO (Resposta: $response)"
        else
             echo "[-] O servidor tem o modo $mode DESABILITADO ou bloqueado"
        fi
    done
}

#======================================================
# MOTOR DE EXPLOIT (ENUMERAÇÃO)
#======================================================

function exploit() {

    echo "[+] Iniciando o exploit"
    sleep 1s

    if [[ -z "$ip" || -z "$wordlist" ]]; then
        echo "[!] IP ou wordlist não fornecidos!"
        exit 1
    fi

    echo "[+] Carregando a wordlist"
    sleep 1s

    if [[ ! -f "$wordlist" ]]; then
        echo "[!] Wordlist não encontrada: $wordlist"
        exit 1
    fi

    echo "[+] Validando os dados"
    sleep 1s

    if ! nc "$ip" "$port" <<<"QUIT" >/dev/null 2>&1;then
	   echo "[!] Porta $port desabilitada para o host [$ip]"
	   exit 1
    fi

    teste_mode

    echo 

    if [[ "$ssl_enable" == "true" ]] ;then
        if [[ "$port" -eq 465 ]];then
            CMD_PREFIX="nc --ssl -q 1 $ip $port"
        elif [[ "$port" -eq 587 ]];then
            CMD_PREFIX="openssl -starttls smtp -quiet -connect $ip:$port"
        fi
    else
        CMD_PREFIX="nc -q 1 -q 1 $ip $port"
    fi

    while IFS= read -r payload; do
        [[ "$verbose" -eq 1 ]] && echo "[*] Testando: $payload@$ip:$port"

        response=$($CMD_PREFIX <<< "$mode_attack $payload" 2>/dev/null | grep -v "^220" | head -n 1 | cut -d " " -f 1)

        if [[ "$response" == "252" || "$response" == "250" ]]; then
            echo "[+] Usuário encontrado: $payload@$ip:$port"
        fi
    done < "$wordlist"

    echo
}

#======================================================
# INTERFACE DE AJUDA (HELP MENU)
#======================================================

function help() {
    echo "Modo de uso:"
    echo "bash $0 -e -ip <ip> -w <wordlist> [-v,-d]"
    echo
    echo "Menu"
    cat <<EOF
    Básico

    -h, --help	Menu de ajuda
    --version	Mostra a versão

    Debug
    -d	Ativa o modo depuração
    -v	Ativa o modo verboso

    Modulos
    enum | Módulo de enumeração de usários
        -ip,--ip	    Seleciona o ip
        -p,--port       Seleciona a porta
        -w,--wordlist   Seleciona a wordlist

	connect_test | Módulo de test de conexão ao host
        -ip,--ip        Seleciona o ip
        -p,--port       Seleciona a porta

	connect_shell | Módulo de criação de um shell interativo com host
        -ip,--ip        Seleciona o ip
        -p,--port       Seleciona a porta

    Outros
        --ssl           Ativa o modo de conexão SSL
        -m, --mode      Seleciona o tipo do modo (VRFY ou EXPN)
EOF
    exit 0
}


#======================================================
# MÓDULOS AUXILIARES E CONECTIVIDADE
#======================================================

function debug(){

   function cleanup(){
       set +x
       echo "[+] Finalizando o debug [+]"
   }

   echo "[+] Inciando o debug [+]"
   set -x

   trap cleanup EXIT

}

function connect_test() {
    if ! nc "$ip" "$port" <<<"QUIT" >/dev/null 2>&1;then
        echo "[!] Porta $port desabilitada para o host [$ip]"
        exit 1
    else
	   echo "[!] Porta $port habilitada para o host [$ip]"
    fi
}

function connect_shell(){
    echo "[+] Iniciando shell interativo"
    sleep 2s

    echo "[+] Testando conexão com host"
    connect_test

    # teste
    nc "$ip" "$port"
}

#======================================================
# PARSER DE ARGUMENTOS (CLI)
#======================================================

if [[ $# -eq 0 ]]; then
    help
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--enum|enum)   run_exploit=1       ;;
        -c|connect_test)  run_connect_test=2  ;;
        -s|connect_shell) run_connect_shell=3 ;;
        -ip|--ip)  shift; ip="$1"             ;;
	    -p|--port) shift; port="$1"           ;;
        -w|--wordlist) shift; wordlist="$1"   ;;
        -v|--verbose) verbose=1               ;;
        --help|-h)    help                    ;;
	    --version) echo "[-] Version 3.0"     ;;
        -d) debug                             ;;
        --ssl) ssl_enable="true"              ;;
        -m|--mode) shift; mode_attack="$1"    ;;
        *) echo "[!] Opção desconhecida: $1"; help ;;
    esac
    shift
done

#======================================================
# EXECUÇÃO DO FLUXO PRINCIPAL
#======================================================

echo
[[ "${run_exploit:-0}" -eq 1 ]] && exploit
[[ "${run_connect_test:-0}" -eq 2 ]] && connect_test
[[ "${run_connect_shell:-0}" -eq 3 ]] && connect_shell

# Sai do programa
exit 0