#!/bin/bash
########################################
# ///                                        \\\
#  		You can edit your configuration here
#
#
########################################
auquatoneThreads=5
subdomainThreads=10
dirsearchThreads=50
dirsearchWordlist=~/tools/dirsearch/db/dicc.txt
massdnsWordlist=~/tools/SecLists/Discovery/DNS/clean-jhaddix-dns.txt
chromiumPath=/snap/bin/chromium
########################################
# Happy Hunting
########################################

echo "hello"

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

SECONDS=0

domain=
subreport=
usage() { echo -e "Usage: ./lazyrecon.sh -d domain.com [-e] [excluded.domain.com,other.domain.com]\nOptions:\n  -e\t-\tspecify excluded subdomains\n " 1>&2; exit 1; }


while getopts ":d:e:r:" o; do
	case "${o}" in
		d)
			domain=${OPTARG}
			;;
		*) 
			usage
			;;
	esac
done
shift $((OPTIND - 1))

logo(){
	echo "

	▓█████ ▄▄▄        ██████▓██   ██▓ █     █░ ██▓ ███▄    █ 
	▓█   ▀▒████▄    ▒██    ▒ ▒██  ██▒▓█░ █ ░█░▓██▒ ██ ▀█   █ 
	▒███  ▒██  ▀█▄  ░ ▓██▄    ▒██ ██░▒█░ █ ░█ ▒██▒▓██  ▀█ ██▒
	▒▓█  ▄░██▄▄▄▄██   ▒   ██▒ ░ ▐██▓░░█░ █ ░█ ░██░▓██▒  ▐▌██▒
	░▒████▒▓█   ▓██▒▒██████▒▒ ░ ██▒▓░░░██▒██▓ ░██░▒██░   ▓██░
	░░ ▒░ ░▒▒   ▓▒█░▒ ▒▓▒ ▒ ░  ██▒▒▒ ░ ▓░▒ ▒  ░▓  ░ ▒░   ▒ ▒ 
	 ░ ░  ░ ▒   ▒▒ ░░ ░▒  ░ ░▓██ ░▒░   ▒ ░ ░   ▒ ░░ ░░   ░ ▒░
	    ░    ░   ▒   ░  ░  ░  ▒ ▒ ░░    ░   ░   ▒ ░   	                                ░ ░                             
	"

}

cleantemp(){
	rm ./$domain/$foldername/temp.txt
	rm ./$domain/$foldername/temp.txt
	rm ./$domain/$foldername/domaintemp.txt
	rm ./$domain/$foldername/cleantemp.txt
}

recon(){
	echo "${red}$domain 的信息收集已经开始${reset}"
	echo "${yellow}正在用assetfinder获取子域名${reset}"

	assetfinder $domain |  grep -v "@" | grep -v "*" | grep $domain | sort -u  > ./$domain/$foldername/$domain.txt
	
	discovery $domain
}


discovery(){
	hostalive $domain
}

hostalive(){ 
	echo "${red}测活子域名以及去除泛解析${reset}"
	echo "${yellow}小龙问路, 运行shuffledns${reset}"
	time shuffledns -d $domain -list ./$domain/$foldername/$domain.txt -r /root/db/resolvers.txt > ./$domain/$foldername/tokill.out	
	time cat ./$domain/$foldername/tokill.out | killwildcard > ./$domain/$foldername/$domain.txt
	echo "${yellow}大龙摆尾, 运行killwildcard ${reset}"
	
	echo "${red}测活子域名以及去除泛解析结束${reset}"

	echo "${red}总共找到 $(wc -l ./$domain/$foldername/$domain.txt | awk '{print $1}')个存活域名${reset}"

}



main(){

	if [ -z "${domain}" ] && [[ -z ${subreport[@]} ]]; then
		   usage; exit 1;
	fi
	logo
	if [ -d "./$domain" ]
	then
		echo "这个域名已经扫过了，奥利给"
	else
		mkdir ./$domain
	fi
	
	mkdir ./$domain/$foldername
	mkdir ./$domain/$foldername/assetfinder
	mkdir ./$domain/$foldername/reports/
	touch ./$domain/$foldername/temp.txt
	touch ./$domain/$foldername/tmp.txt
	touch ./$domain/$foldername/cleantemp.txt
	touch ./$domain/$foldername/domaintemp.txt
	touch ./$domain/$foldername/master_report.html

	cleantemp
	recon $domain

	echo $domain

}
todate=$(date +"%Y-%m-%d")
path=$(pwd)
foldername=recon-$todate
source ~/.bash_profile
main
