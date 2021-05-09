cd $HOME

. /etc/os-release
OS=$NAME

case "$OS" in
Ubuntu) sudo apt update && sudo apt upgrade -y && sudo apt install zsh stow curl
        ;;
Fedora) sudo dnf upgrade -y && sudo dnf install zsh stow curl -y
        ;;
esac

git config --global user.email "joasmulder@hotmail.com"
git config --global user.name "Joas Mulder"
git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

rm .zshrc
rm .p10k.zsh

cd dotfiles
stow zsh
