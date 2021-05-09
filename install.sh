sudo apt update && sudo apt upgrade -y && sudo apt install zsh stow curl

git config --global user.email "joasmulder@hotmail.com"
git config --global user.name "Joas Mulder"
git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd dotfiles
stow zsh