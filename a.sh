IP=$(cat /etc/IP)
echo "Port 53" >>/etc/ssh/sshd_config
service ssh restart
echo -ne "\033[1;32mUsername:\033[1;37m "
username=sucker
[[ -z $username ]] && {
	echo -e "\n${cor1}Empty or invalid username!${scor}\n"
	exit 1
}
[[ "$(grep -wc $username /etc/passwd)" != '0' ]] && {
	echo -e "\n${cor1}This user already exists. try another name!${scor}\n"
	exit 1
}
[[ ${username} != ?(+|-)+([a-zA-Z0-9]) ]] && {
	echo -e "\n${cor1}You entered an invalid username!${scor}"
	echo -e "${cor1}Do not use spaces, accents or special characters!${scor}\n"
	exit 1
}
sizemin=$(echo ${#username})
[[ $sizemin -lt 2 ]] && {
	echo -e "\n${cor1}You entered too short a username${scor}"
	echo -e "${cor1}use at least 4 characters!${scor}\n"
	exit 1
}
sizemax=$(echo ${#username})
[[ $sizemax -gt 10 ]] && {
	echo -e "\n${cor1}You entered a very large username"
	echo -e "${cor1}use a maximum of 10 characters!${scor}\n"
	exit 1
}
echo -ne "\033[1;32mPassword:\033[1;37m "
password=sucker
[[ -z $password ]] && {
	echo -e "\n${cor1}Empty or invalid password!${scor}\n"
	exit 1
}
sizepass=$(echo ${#password})
[[ $sizepass -lt 4 ]] && {
	echo -e "\n${cor1}Short password!, use at least 4 characters${scor}\n"
	exit 1
}
echo -ne "\033[1;32mdays to expire:\033[1;37m ";
dias=360
[[ -z $dias ]] && {
	echo -e "\n${cor1}number of days empty!${scor}\n"
	exit 1
}
[[ ${dias} != ?(+|-)+([0-9]) ]] && {
	echo -e "\n${cor1}You entered an invalid number of days!${scor}\n"
	exit 1
}
[[ $dias -lt 1 ]] && {
	echo -e "\n${cor1}The number must be greater than zero!${scor}\n"
	exit 1
}
echo -ne "\033[1;32mLimit of connections:\033[1;37m "
sshlimiter=900
[[ -z $sshlimiter ]] && {
	echo -e "\n${cor1}You left the connection limit empty!${scor}\n"
	exit 1
}
[[ ${sshlimiter} != ?(+|-)+([0-9]) ]] && {
	echo -e "\n${cor1}You entered an invalid number of connections!${scor}\n"
	exit 1
}
[[ $sshlimiter -lt 1 ]] && {
	echo -e "\n${cor1}Number of concurrent connections must be greater than zero!${scor}\n"
	exit 1
}
final=$(date "+%Y-%m-%d" -d "+$dias days")
gui=$(date "+%d/%m/%Y" -d "+$dias days")
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
useradd -e $final -M -s /bin/false -p $pass $username >/dev/null 2>&1 &
echo "$password" >/etc/VPSManager/senha/$username
echo "$username $sshlimiter" >>/root/usuarios.db
[[ -e /etc/openvpn/server.conf ]] && {
	echo -ne "\033[1;32mGenerate Ovpn File \033[1;31m? \033[1;33m[s/n]:\033[1;37m "; read resp
	[[ "$resp" = @(s|S) ]] && {
		rm $username.zip $username.ovpn >/dev/null 2>&1
		echo -ne "\033[1;32mGenerate With Username and Password \033[1;31m? \033[1;33m[s/n]:\033[1;37m "
		read respost
		echo -ne "\033[1;32mcurrent host\033[1;37m: \033[1;31m(\033[1;37m$Host\033[1;31m) \033[1;37m- \033[1;32mChange \033[1;31m? \033[1;33m[s/n]:\033[1;37m "; read oprc
		[[ "$oprc" = @(s|S) ]] && {
			fun_edithost
		} || {
			fun_geraovpn
		}
		gerarovpn() {
			[[ ! -e "/root/$username.zip" ]] && {
				zip /root/$username.zip /root/$username.ovpn
				sleep 1.5
			}
		}
		clear
    echo -e "\033[1;32m===================================="
    echo -e "\033[1;32m   🐉ㅤDRAGON VPS MANAGERㅤ🐉  " 
    echo -e "\033[1;32m===================================="
    echo ""
    echo -e "\033[1;31m◈─────⪧ IMPORTANT ⪦──────◈"
    echo ""
    echo -e "\033[1;32m◈⪧ 🚫ㅤNO SPAM"
    echo -e "\033[1;32m◈⪧ ⚠️ㅤNO DDOS"
    echo -e "\033[1;32m◈⪧ 🎭ㅤNO Hacking"
    echo -e "\033[1;32m◈⪧ ⛔️ㅤNO Carding"
    echo -e "\033[1;32m◈⪧ 🙅‍♂️ㅤNO Torrent"
    echo -e "\033[1;32m◈⪧ ❌ㅤNO MultiLogin"
    echo -e "\033[1;32m◈⪧ 🤷‍♂️ㅤNO Illegal Activities"
    echo ""
    echo -e "\033[1;37m◈─────⪧ SSH ACCOUNT ⪦─────◈"
    echo ""
    echo -e "\033[1;32m◈ Host / IP   :⪧  \033[1;31m$IP"
    echo -e "\033[1;32m◈ Username    :⪧  \033[1;31m$username"
    echo -e "\033[1;32m◈ Password    :⪧  \033[1;31m$password"
    echo -e "\033[1;32m◈ Login Limit :⪧  \033[1;31m$sshlimiter"
    echo -e "\033[1;32m◈ Expire Date :⪧  \033[1;31m$gui"
    echo ""
    echo -e "\033[1;37m◈──────⪧ PORTS ⪦ ───────◈"
    echo ""
    echo -e "\033[1;32m◈ SSH	   ⌁  22"
    echo -e "\033[1;32m◈ SSL	   ⌁  443"
    echo -e "\033[1;32m◈ Squid    ⌁  8080"
    echo -e "\033[1;32m◈ DropBear ⌁  80"
    echo -e "\033[1;32m◈ BadVPN   ⌁  7300"
    echo ""
    echo -e "\033[1;37m◈───⪧ONLINE USER COUNT⪦────◈ "
    echo ""
    echo -e "\033[1;32mhttp://$IP:8888/server/online"
    echo ""
    echo -e "\033[1;37m◈─────────────────────────────────◈"
    echo -e "\033[1;37m©️ 🐉  DRAGON VPS MANAGER SCRIPT  🐉"
    echo -e "\033[1;37m◈─────────────────────────────────◈"
