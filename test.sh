sudo deluser test --remove-home

sudo adduser --disabled-password --gecos "" test
password=$(openssl passwd aaaa)
sudo usermod -p $password test
