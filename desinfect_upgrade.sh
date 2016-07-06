#!/bin/bash
#@author Ewerton Oliveira
#@description Remove o virus e atualiza o firmware
FILE=/etc/persistent/mf.tar

# Check virus
if [ -e "$FILE" ] ; then
    #Acess folder
    cd /etc/persistent
    #Remove the virus
    echo -e "\e[33;m Removendo virus...\e[m"
    rm mf.tar
    rm -Rf .mf
    rm -Rf mcuser
    #rm rc.poststart
    # Preserve ISP custom scripts Colaboration PVi1 (Git user)
    sed -i '/mf\/mother/d' /etc/persistent/rc.poststart
    rm rc.prestart
    #Remove mcuser in passwd - by Alexandre
    echo -e "\e[33;m Removendo usuário do virus...\e[m"
    sed -ir '/mcad/ c ' /etc/inittab
    sed -ir '/mcuser/ c ' /etc/passwd
    sed -ir '/mother/ c ' /etc/passwd
    echo -e "\e[33;m Modificando dados da configuração...\e[m"
    #Change HTTP port for 8050 and SSH port 2250 | Need access http://IP:8050
    cat /tmp/system.cfg | grep -v http > /tmp/system2.cfg
    echo "httpd.https.status=disabled" >> /tmp/system2.cfg
    echo "httpd.port=8050" >> /tmp/system2.cfg
    echo "httpd.session.timeout=900" >> /tmp/system2.cfg
    echo "httpd.status=enabled" >> /tmp/system2.cfg
    echo "sshd.status=enabled" >> /tmp/system2.cfg
    echo "sshd.port=2250" >> /tmp/system2.cfg
    cat /tmp/system2.cfg | uniq > /tmp/system.cfg
    rm /tmp/system2.cfg
    echo -e "\e[33;m Aplicando configuração...\e[m"
    #Write new config
    cfgmtd -w -p /etc/
    cfgmtd -f /tmp/system.cfg -w
    #Kill process - by Alexandre
    echo -e "\e[33;m Encerrando processo em aberto pelo virus...\e[m"
    kill -HUP `/bin/pidof init`
    kill -9 `/bin/pidof mcad`
    kill -9 `/bin/pidof init`
    kill -9 `/bin/pidof search`
    kill -9 `/bin/pidof mother`
    kill -9 `/bin/pidof sleep`
    echo -e "\e[33;m Vacina aplicada!\e[m"
fi
