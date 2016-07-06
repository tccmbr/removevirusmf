#!/bin/bash

#@author Ewerton Oliveira
#@description Script para removeção do virus MF.tar e atualização do firmware v5.6.5 da Ubiquiti.

FILE=/etc/persistent/mf.tar
user=$1
pass=$2
network=$3
ip_start=$4
port=$5

if [ -z $1 ]; then
        user=mother     
fi
if [ -z $2 ]; then
        #usuário padrão
        pass=fucker
fi
if [ -z $3 ]; then
        #rede
        network="192.168.0"
fi
if [ -z $4 ]; then
        #IP Inicial
        ip_start=1
fi
if [ -z $5 ]; then
        #Porta padrão
        port=22
fi

total=0

for i in `seq $ip_start 255`
do
    	ip=$network.$i
    	echo -e "\e[33;1m Iniciando conexão em $ip...\e[m"
	versao=$(sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "cat /etc/version")
	if [ "$versao" != "" ] ; then
		tipo_versao=$(sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "mca-status  | grep firmware | cut -d, -f3 | cut -d= -f2 | cut -d. -f1")

		if [ "$tipo_versao" == "XM" -a "$versao" != "XM.v5.6.5" -o "$tipo_versao" == "XW" -a "$versao" != "XW.v5.6.5" ] ; then
			sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "ls $FILE && exit"
			if [ $? -eq 0 ]; then
		       		echo -e "\e[33;1m Virus encontrado, enviando vacina...! =(\e[m"
				echo "$(date +%d)/$(date +%m)/$(date +%Y) - $(date +%H):$(date +%M):$(date +%S) $ip" >> hosts_infectados.txt
				total=$(expr $total + 1)
				sshpass -p $pass scp -P $port -o ConnectTimeout=3 -o StrictHostKeyChecking=no desinfect_upgrade.sh $user@$ip:/tmp/

				if [ $? -eq 0 ] ; then
					sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "sh /tmp/desinfect_upgrade.sh"
					sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "rm /tmp/desinfect_upgrade.sh"
				else 
        		        	echo -e "\e[31;1m Não foi possível enviar a vacina.\e[m"
	        		fi
			else
				echo -e "\e[32;1m Não infectado =) \e[m"
			fi
		
			echo -e "\e[33;m Versão atual do firmware:\e[m $versao"
	        	if [ "$tipo_versao" == "XM" ]; then
			        firmware="XM.v5.6.5.29033.160515.2119.bin"
		        fi
			if [ "$tipo_versao" == "XW" ]; then
	                	firmware="XW.v5.6.5.29033.160515.2108.bin"
	       		fi
	
			echo -e "\e[33;m Enviando firmware \e[33;1m $firmware\e[m \e[m"
			sshpass -p $pass scp -P $port -o ConnectTimeout=3 -o StrictHostKeyChecking=no firmware/$firmware $user@$ip:/tmp/fwupdate.bin
			if [ $? -eq 0 ] ; then
				echo -e "\e[33;m Atualizando firmware...\e[m"
				sshpass -p $pass ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $user@$ip -p $port "/sbin/fwupdate -m"
			else
				echo -e "\e[31;1m Não foi possível enviar o firmware.\e[m"
			fi
		fi
	fi
done
if [ $total -gt 0 ] ; then echo "$total equipamentos infectados! =´(" ; else echo "Nenhum cliente infectado =)" ; fi
