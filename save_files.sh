if [[ $1 -eq 0 ]]
then
	echo "No arguments supplied, please type ./account_creation_script.sh file.csv"
	exit
fi

sed '1,1d' $1 > temp.csv
tr A-Z a-z < temp.csv > temp2.csv
tr -d " " < temp2.csv > temp.csv

# declare -a accounts=()

while IFS=";", read -r name surname mail password
do
	account=("${name:0:1}$surname")
	tar zcvf save_$account.tgz --directory=/home/$account/a_sauver .
	scp save_$account.tgz asauni25@10.30.48.100:/home/saves/
	rm save_$account.tgz
done < temp.csv

rm temp.csv
rm temp2.csv

echo "Saved succesfull"
