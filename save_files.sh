# verifying parameters
if [[ $1 -eq 0 ]] 2> /dev/null
then
	echo -e "\033[31mArgument error :\033[0m"
	echo ""
	echo "Syntax :"
	echo "save_files.sh file.csv"
	echo -e "              \033[31m↑\033[0m"
	exit
fi

# rewrite the csv file to have good usernames
sed '1,1d' $1 > temp.csv
tr A-Z a-z < temp.csv > temp2.csv
tr -d " " < temp2.csv > temp.csv

# reading through the csv file and save
while IFS=";", read -r name surname mail password
do
	account=("${name:0:1}$surname")
	tar zcvf save_$account.tgz --directory=/home/$account/a_sauver .
	scp save_$account.tgz asauni25@10.30.48.100:/home/saves/
	rm save_$account.tgz
done < temp.csv

# removing temp files
rm temp.csv
rm temp2.csv

echo "Saved succesfull"
