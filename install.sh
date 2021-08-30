cd $HOME

. /etc/os-release
OS=$NAME

case "$OS" in
Ubuntu) sudo apt update && sudo apt upgrade -y && sudo apt install zsh stow -y
        ;;
Debian) sudo apt update && sudo apt upgrade -y && sudo apt install zsh stow -y
;;
Fedora) sudo dnf upgrade -y && sudo dnf install zsh stow -y
        ;;
esac

git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

rm .zshrc

cd dotfiles
stow zsh
