#!/usr/bin//env bash

#=======================================
# Banner
#=======================================

cat <<EOF
  ____       _                           
 / ___| __ _| |_ _____      ____ _ _   _ 
| |  _ / _' | __/ _ \ \ /\ / / _' | | | |
| |_| | (_| | ||  __/\ V  V / (_| | |_| |
 \____|\__,_|\__\___| \_/\_/ \__,_|\__, |
                                   |___/ 
By: @Pauloxc6
EOF


#=======================================
# Vars
#=======================================

# ! Protreção de código
set -euo pipefail

# * Otimização
export LANG=C
export LC_ALL

# Arrays com ferramentas necessarias
tools=(
    net-tools
    iptables
    netfilter-persistent
)

# Check os
os=$(lsb_release -a | grep "Distributor ID:" | cut -d ":" -f2 | tr -d '\t')  # Sistemas baseados em GNU/Linux
#os_bsd=$(cat /etc/os-release | cut -d "=" -f2 | tr '\n' ' '| cut -d " " -f1) # Sistemas baseados em BSD

# Básico
debug=0
interfaces_config="/etc/network/interfaces" 

# Cores
export RESET=$'\e[0m'
export RED=$'\e[31;1m'
export GREEN=$'\e[32;1m'
export YELLOW=$'\e[33;1m'
export BLUE=$'\e[34;1m'
export PURPLE=$'\e[35;1m'
export CYAN=$'\e[36;1m'
export WHITE=$'\e[37;1m'

#=======================================
# Checagem Root
#=======================================

[[ ! "$UID" -eq 0 ]] && {
    echo -e "${RED}[*] O programa ./$0 deve ser executado como root!${RESET}"
    exit 1
}

#=======================================
# Funções
#=======================================

function barra_carregamento() {
    local progresso=0
    local largura=50  # Largura da barra de progresso

    echo -ne "${GREEN}[+] Analizando ...${RESET}\n"

    while [[ $progresso -le 100 ]]; do
        # Calcula o número de caracteres preenchidos
        local preenchido=$((progresso * largura / 100))
        local vazio=$((largura - preenchido))

        # Cria a barra
        local barra=$(printf "%0.s#" $(seq 1 $preenchido))
        local espacos=$(printf "%0.s-" $(seq 1 $vazio))

        # Exibe a barra na mesma linha
        printf "\r${BLUE}[%s%s] %3d%%${RESET}" "$barra" "$espacos" "$progresso"

        # Incrementa o progresso
        progresso=$((progresso + 1))
        sleep 0.05  # Pausa para simular o carregamento
    done

    # Move para a próxima linha após o carregamento
    echo -e "\n${GREEN}[+] Concluído!${RESET}"
}

function debug(){

	function cleanup() {

		echo -w "${WHITE}[+] Fim da depuração!${RESET}"
		set +x

	}

	echo -e "${WHITE}[+] Início da depuração!${RESET}"
	set -x

	trap cleanup EXIT
}

#=======================================
# Parser
#=======================================

while [ $# -gt 0 ]; do
	case "$1" in
		-d) debug ; debug=1 ;;
        -h|--help) echo -e "Ajuda: $0 -h\n\t-d, --debug | Ativa o modo de depuração" ; exit 0 ;;
        * ) echo "${RED}[!] O comando $1 não exite!${RESET}" ; exit 1
	esac
    shift
done

#=======================================
# Main
#=======================================

# Remoção da barra de carregamento do debug
if [[ "${debug}" == 0 ]]; then
	barra_carregamento
fi

# Atualização de pacotes
echo -e "${BLUE}[+]${WHITE}Atualizando todos os pacotes!${RESET}"

# Para adicionar um novo padrão de utilização utilize o seguinte termo:
# "debian"|"ubuntu") apt update && apt upgrade -y ;;
case "${os,,}" in
    "debian"|"ubuntu") apt update && apt upgrade -y ;;
    *) echo -e "${RED}[!] Não foi possivel determinar o sistema operacional!${RESET}"; exit 1
esac

#=======================================
# Instação das ferramentas
#=======================================

# Para adicionar um novo padrão de utilização utilize o seguinte termo:
# "debian"|"ubuntu") for tool in "${tools[@]}";do apt install "${tool}" -y; done    ;;

echo -e "${BLUE}[+]${WHITE}instalando todos os pacotes!${RESET}"
case "${os,,}" in
    "debian"|"ubuntu") for tool in "${tools[@]}";do apt install "${tool}" -y; done ;;
esac

#=======================================
# Configurações
#=======================================

# Configuração dos ips
# Altere conforme for necessário
echo -e "${BLUE}[+]${WHITE}Iniciando as configurações de rede!${RESET}"
if [[ "${os,,}" == "debian" || "${os,,}" == "debian" ]]; then
    if [ -e "${interfaces_config}" ]; then
        cat <<CONFIG > "${interfaces_config}"
    # Loopback
    auto lo
    iface lo inet loopback

    # Board
    allow-hotplug enp3s0
    iface enp3s0 inet dhcp

    # DMZ
    auto enp8s0
    iface enp8s0 inet static
        address 10.1.1.1/24

    # MZ
    auto enp9s0
    iface enp9s0 inet static
        address 10.2.2.1/24
CONFIG
    fi

    # Ativando as configurações
    echo -e "${BLUE}[+]${WHITE}Ativando as configurações!${RESET}"
    ifdown enp3s0
    ifdown enp8s0
    ifdown enp9s0

    ifup enp3s0
    ifup enp8s0
    ifup enp9s0
fi

# Configuração das regras de firewall
# Altere conforme for necessário

echo -e "${BLUE}[+]${WHITE}Configurando as regras de firwall!${RESET}"
if [[ "${os,,}" == "debian" || "${os,,}" == "debian" ]]; then

    iptables -t nat -A POSTROUTING -o enp3s0 -j MASQUERADE

    iptables -A FORWARD -i enp8s0 -o enp3s0 -j ACCEPT
    iptables -A FORWARD -i enp9s0 -o enp3s0 -j ACCEPT

    iptables -A FORWARD -i enp3s0 -o enp8s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i enp3s0 -o enp9s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.1.1.4:80
    iptables -A FORWARD -p tcp -d 10.1.1.4 --dport 80 -j ACCEPT

    echo -e "${BLUE}[+]${WHITE}Salvando as regras de firewall!${RESET}"
    netfilter-persistent save

fi

#=======================================
# Dump final
#=======================================

echo
echo -e "${YELLOW}[+]${WHITE} Configurações de IP!${RESET}"
echo

ip -c addr show

echo
echo -e "${YELLOW}[+]${WHITE} Tabela de rotas!${RESET}"
echo

ip -c route

echo
echo -e "${YELLOW}[+]${WHITE} Configurações das interfaces!${RESET}"
echo

ip -c link show

echo
echo -e "${YELLOW}[+]${WHITE} Regras do Firewall!${RESET}"
echo

iptables -L -n -v

echo
echo -e "${YELLOW}[+]${WHITE} Regras NAT!${RESET}"
echo

iptables -t nat -L -n -v

echo
echo -e "${GREEN}[+] Dump finalizado!${RESET}"

#=======================================
# Mini Dump do Sistema
#=======================================

echo
echo -e "${YELLOW}[+]${WHITE} Informações do sistema!${RESET}"
echo

echo -e "${CYAN}Sistema Operacional:${RESET} ${os}"
echo -e "${CYAN}Hostname:${RESET} $(hostname)"
echo -e "${CYAN}Kernel:${RESET} $(uname -r)"
echo -e "${CYAN}Arquitetura:${RESET} $(uname -m)"
echo -e "${CYAN}Uptime:${RESET} $(uptime -p)"
echo -e "${CYAN}CPU:${RESET} $(nproc) núcleos"

echo -e "${CYAN}Memória:${RESET}"
free -h | awk '
NR==1 {printf "  %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4}
NR==2 {printf "  %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4}
'

echo

#=======================================
# Sair
#=======================================
echo -e "${BLUE}[+]${WHITE}Saindo do programa ... !${RESET}"
exit 0