# $1 = accounts.csv file
# $2 = smtp server
# $3 = mail
# $4 = password

if [[ $1 -eq 0 ]] 2> /dev/null
then
	echo -e "\033[31mArgument error :\033[0m"
	echo ""
	echo "Syntax :"
	echo "account_creation_script.sh file.csv smtp-mail-server login.mail@domain.name mail-password"
	echo -e "                           \033[31m↑\033[0m"
	exit
fi

if [[ $2 -eq 0 ]] 2> /dev/null
then
	echo -e "\033[31mArgument error :\033[0m"
	echo ""
	echo "Syntax :"
	echo "account_creation_script.sh file.csv smtp-mail-server login.mail@domain.name mail-password"
	echo -e "                                    \033[31m↑\033[0m"
	exit
fi

if [[ $3 -eq 0 ]] 2> /dev/null
then
	echo -e "\033[31mArgument error :\033[0m"
	echo ""
	echo "Syntax :"
	echo "account_creation_script.sh file.csv smtp-mail-server login.mail@domain.name mail-password"
	echo -e "                                                     \033[31m↑\033[0m"
	exit
fi

if [[ $4 -eq 0 ]] 2> /dev/null
then
	echo -e "\033[31mArgument error :\033[0m"
	echo ""
	echo "Syntax :"
	echo "account_creation_script.sh file.csv smtp-mail-server login.mail@domain.name mail-password"
	echo -e "                                                                            \033[31m↑\033[0m"
	exit
fi

# rewrite the csv file to have good usernames
sed '1,1d' $1 > temp.csv
tr A-Z a-z < temp.csv > temp2.csv
tr -d " " < temp2.csv > temp.csv

# fitting user data for the mail
smtp_server=$2
mail_address=$3
mail_fit=$(echo $3 | sed 's/@/%40/g')
password_fit=$(echo $4 | sed 's/\\/\\\\/g')
password_fit=$(echo $password_fit | sed 's/\ /\\\ /g')
password_fit=$(echo $password_fit | sed 's/\$/\\\$/g')
password_fit=$(echo $password_fit | sed 's/\~/\\\~/g')
password_fit=$(echo $password_fit | sed 's/\&/\\\&/g')
password_fit=$(echo $password_fit | sed 's/\@/\\\@/g')
password_fit=$(echo $password_fit | sed 's/\!/\\\!/g')


declare -a accounts=()
declare -a passwords=()
declare -a mails=()

# Creating the key
ssh-keygen -N '' -f ./key
scp key.pub asauni25@10.30.48.100:.ssh
ssh asauni25@10.30.48.100 "cat .ssh/key.pub >> .ssh/authorized_keys"

# reading through the csv file
while IFS=";", read -r name surname mail password
do
	accounts+=("${name:0:1}$surname")
	passwords+=($password)
	mails+=($mail)
done < temp.csv

# n the nimber of users
n=${#accounts[@]}

# adding numbers after the username if similar usernames
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

sudo mkdir /home/shared

# creating the users with passwords
for i in ${!accounts[@]}
do
	sudo adduser --disabled-password --gecos "" ${accounts[$i]}
	sudo usermod -p $(openssl passwd -1 ${passwords[$i]}) ${accounts[$i]}
	sudo passwd -e ${accounts[$i]}
	sudo mkdir /home/${accounts[$i]}/a_sauver
	sudo chown ${accounts[$i]}:${accounts[$i]} /home/${accounts[$i]}/a_sauver
	sudo mkdir /home/shared/${accounts[$i]}
	sudo chown ${accounts[$i]}:${accounts[$i]} /home/shared/${accounts[$i]}
	sudo mkdir /home/${accounts[$i]}/.ssh
	sudo cp key /home/${accounts[$i]}/.ssh/
	sudo chmod 005 /home/${accounts[$i]}/.ssh/key
	
	sudo cp retablir_sauvegarde.sh /home/${accounts[$i]}/
	sudo chown ${accounts[$i]} /home/${accounts[$i]}/retablir_sauvegarde.sh
	sudo chmod 500 /home/${accounts[$i]}/retablir_sauvegarde.sh
	
	ssh asauni25@10.30.48.100 "mail --subject \"[Confidentiel] Mot de passe nouveau compte entreprise\" --exec \"set sendmail=smtp://$mail_fit:$password_fit;@$smtp_server\" --append \"From:$mail_address\" ${mails[$i]} <<< \"Bonjour,

Voici votre nom d'utilisateur : ${accounts[$i]}

Voici votre mot de passe : ${passwords[$i]}

Lors de votre première connexion, il vous sera demmandé ce mot de passe, et il vous sera ensuite demander de le changer pour un mot de passe personnel. Veillez à ne jamais communiquer ce mot de passe, ainsi que celui que vous allez créer, à quiconque. Veilez à choisir un mot de passe fort (Plus de 8 caractères, dont : majuscules, minuscules, chiffres, caractères spéciaux).

Ce mail a été générer automatiquement, ne pas y répondre.\""
done

# add the line below to create the /home/saves on the distant machine (asauni25 doesn't have the rights to do so)
# sudo ssh asauni25@10.30.48.100 "mkdir /home/saves"
sudo mkdir /home/saves

$(sudo crontab -l) > cron_temp
echo "0 23 * * 1-5 .$(pwd)/save_files.sh $(pwd)/accounts.csv" >> cron_temp
sudo crontab cron_temp
rm cron_temp

rm temp.csv
rm temp2.csv
rm key
rm key.pub

echo "Accounts succesfully created"