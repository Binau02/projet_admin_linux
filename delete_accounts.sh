if [[ $1 -eq 0 ]]
then
	echo "No arguments supplied, please type ./account_creation_script.sh file.csv"
	exit
fi

sed '1,1d' $1 > temp.csv
tr A-Z a-z < temp.csv > temp2.csv
tr -d " " < temp2.csv > temp.csv

declare -a accounts=()

while IFS=";", read -r name surname mail password
do
	accounts+=("${name:0:1}$surname")
done < temp.csv

n=${#accounts[@]}

for i in ${!accounts[@]}
do
	let a=1
	for (( j=$(($i+1)); j<$n; j++ ))
	do
		if [[ ${accounts[$i]} == ${accounts[$j]} ]]
		then
			accounts[$j]=${accounts[$j]}"$a"
			a=$(($a+1))
		fi
	done
done

for i in ${!accounts[@]}
do
	sudo deluser ${accounts[$i]} --remove-home
done

echo "accounts deleted"

sudo crontab -r

echo "crontab removed"

sudo rm -rf /home/saves
sudo rm -rf /home/shared

echo "/home/saves and /home/shared deleted"