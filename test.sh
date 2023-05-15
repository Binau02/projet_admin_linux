echo "-> Partie 1 :\n\n"

# remove things to create all
echo "-> On enlève les users, groups et files créés pour éxécuter l'exercice"
sudo deluser sramkin1 --remove-home
sudo delgroup sramkin1
sudo delgroup unseen_university
sudo delgroup inadvisably_applied_magic

sudo rm /tmp/in_octavo

sudo deluser test3 --remove-home
sudo delgroup test3

echo ""