echo -e "\033[33mWarning\033[0m : This action will replace the content of the folder \"a_sauver\". Are you sure you want to continue ? (Y/n)"

read -n 1 -r
echo  

if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! $REPLY == "" ]]
then
	echo "Please save the files that are already in the folder \"a_sauver\" before retrying this command."
	exit
fi

echo "Pulling the files..."

rm -rf /home/$(whoami)/a_sauver
mkdir /home/$(whoami)/a_sauver

scp -i .ssh/key asauni25@10.30.48.100:/home/saves/save_$(whoami).tgz /home/$(whoami)/a_sauver

tar -xvf /home/$(whoami)/a_sauver/save_$(whoami).tgz -C /home/$(whoami)/a_sauver/

rm a_sauver/save_$(whoami).tgz