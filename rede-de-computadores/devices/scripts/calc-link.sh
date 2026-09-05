#!/usr/bin/env bash

echo -e "\e[37;1m"

echo "calc-links"

echo "By: @Pauloxc6"
echo ""

read -p "Quantos Links [2-10] :  " links_cont

if [[ $links_cont -ge 2 && $links_cont -le 10 ]]; then
    soma=0
    menor=1000000

    # Entrada
    for ((i = 1; i <= $links_cont; i++)); do
        read -p "Link$i (Ex: 10): " link
        soma=$((soma + link))
        if [[ $link -lt $menor ]]; then
            menor=$link
        fi
    done

    # Calculos filas e mbps
    filas=$((soma / $menor))
    mbps=$((soma / filas))

    # Print
    echo -e "\e[37;1mA soma dos links é: \e[32;1m$soma Mbps\n\e[37;1mO menor link é: \e[32;1m$menor Mbps\n\e[37;1mQuantos Mbps em cada fila: \e[32;1m$mbps Mbps\e[0m"
else
    echo -e "\e[31;1mDeve ser inserido valores entre 2 e 10!\e[0m"
fi