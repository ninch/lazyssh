#!/bin/bash
set -e

servers=( 01 02 nn ... )
prefix="stg-xxx"

do_ssh() {
	ssh -A ${userhost} "$@"
	echo -e
}

install_datadog() {
    cmd='DD_API_KEY=${DD_API_KEY} bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"'
    ssh -tt ${userhost} << EOF
sudo su;
${cmd}
exit
exit
EOF
}

upgrade_datadog() {
    cmd='DD_UPGRADE=true bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"'
    ssh -tt ${userhost} << EOF
sudo su;
${cmd}
exit
exit
EOF
}

header() {
	echo "#====={$@}=====#"
}

if [ ! -z $1 ]
then
	servers=( $1 )
fi
n=${#servers[@]}

for (( i=0;i<$n;i++ )); do
    echo -e
    userhost="${prefix}${servers[$i]}"
    echo "$(tput bold)$(tput setaf 2)Server: ${userhost}  @@ $(date -d "9 hours" +'%Y/%m/%d %H:%m:%S') @@ $(tput sgr 0)"

    header "Memory Usage"
    ssh -A ${userhost} 'free -m'
    #do_ssh df -h | grep -i "/data" | awk '{ print $5 " " $1  "\t<--\t" $6}'
    do_ssh du -h /data | sort -rh | sed -n '3,10p' || true

    # Upgrade datadog
    header "Upgrade Datadog Agent"
    upgrade_datadog

done
