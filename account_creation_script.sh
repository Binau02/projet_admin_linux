if [[ $1 -eq 0 ]]
then
	echo "No arguments supplied, please type ./account_creation_script.sh file.csv"
	exit
fi

sed '1,1d' $1 > temp.csv
tr A-Z a-z < temp.csv > temp2.csv
tr -d " " < temp2.csv > temp.csv

#cat temp.csv

declare -a accounts=()
declare -a passwords=()

while IFS=";", read -r name surname mail password
do
	#echo $name
	#echo $surname
	#echo $mail
	#echo "b"
	#echo "${name:0:1}$surname"
	accounts+=("${name:0:1}$surname")
	passwords+=($password)
done < temp.csv

n=${#accounts[@]}

for i in ${!accounts[@]}
do
	let a=1
	for (( j=$(($i+1)); j<$n; j++ ))
	do
		if [[ ${accounts[$i]} == ${accounts[$j]} ]]
		then
			#echo ${accounts[$j]}"$a"
			accounts[$j]=${accounts[$j]}"$a"
			a=$(($a+1))
		fi
	done
done

sudo mkdir /home/shared

for i in ${!accounts[@]}
do
	echo ${passwords[$i]}
	sudo adduser --disabled-password --gecos "" ${accounts[$i]}
	sudo usermod -p $(openssl passwd -1 ${passwords[$i]}) ${accounts[$i]}
	sudo passwd -e ${accounts[$i]}
	sudo mkdir /home/${accounts[$i]}/a_sauver
	sudo chown ${accounts[$i]}:${accounts[$i]} /home/${accounts[$i]}/a_sauver
	sudo mkdir /home/shared/${accounts[$i]}
	sudo chown ${accounts[$i]}:${accounts[$i]} /home/shared/${accounts[$i]}
done

echo "end"