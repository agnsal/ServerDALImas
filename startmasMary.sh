#exec 1>/dev/null # @echo off
clear # cls
#title "MAS"
sicstus_home=/usr/local
main_home=../..
dali_home=../src
conf_dir=conf
prolog="$sicstus_home/bin/sicstus"
WAIT="ping -c 4 127.0.0.1" 
instances_home=mas/instances
types_home=mas/types
build_home=build

rm -rf tmp/*
rm -rf build/*
rm -f work/*.txt # remove everything if you want to clear agent history
rm -rf conf/mas/*

# Build agents by creating a file with the instance name containing the type content for each instance.
for instance_filename in $instances_home/*.txt
do	
	type=$(<$instance_filename) # agent type name is the content of the instance file
	type_filename="$types_home/$type.txt"
	instance_base="${instance_filename##*/}" # e.g. 'mas/instances/agent1.txt' -> 'agent1.txt'
	echo $type_filename	
	cat $type_filename >> "$build_home/$instance_base"
done

cp $build_home/*.txt work

echo 'avvio' & $prolog -l $dali_home/active_server_wi.pl --goal "go(3010,'server.txt')." > /dev/null & 
echo Server ready. Starting the MAS.... &
$WAIT > /dev/null # %WAIT% >nul &

# $prolog -l $dali_home/active_user_wi.pl --goal "utente." & 

echo Launching agents instances... &
$WAIT > /dev/null # %WAIT% > nul &

# Launch agents
for agent_filename in $build_home/*
do
    sleep 5 &&
    agent_base="${agent_filename##*/}"
    echo "Agente: $agent_base"
    ./conf/makeconf.sh $agent_base $dali_home
    ./conf/startagent.sh $agent_base $prolog $dali_home > /dev/null &
    $WAIT > /dev/null # %WAIT% >nul &
done

sleep 5

echo MAS started.
echo Press a key to shutdown the MAS
read -p "$*"
echo Halting the MAS...
killall sicstus
