VERSION="3.9.7"

sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev -y
wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
tar -xf Python-$VERSION.tgz
cd Python-$VERSION
./configure --enable-optimizations
make -j 2
sudo make altinstall
cd ..
rm --dir -f -R Python-$VERSION
