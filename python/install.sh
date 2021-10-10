VERSION="3.9.7"

sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev -y
wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
tar -xf Python-$VERSION.tgz
cd Python-$VERSION
./configure --enable-optimizations
make -j 4
sudo make altinstall
cd ..
sudo rm --dir -f -R Python-$VERSION
sudo rm Python-$VERSION.tgz

echo "alias python=python${VERSION[0,3]}" >> ~/.zshenv
echo "alias python3=python${VERSION[0,3]}" >> ~/.zshenv
echo "alias pdmi = eval "$(pdm --pep582)"" >> ~/.zshenv
echo "python${VERSION[0,3]}" >> ~/.zshenv

/usr/local/bin/python3.9 -m pip install --user pipx
/usr/local/bin/python3.9 -m pipx ensurepath

pipx install pdm
