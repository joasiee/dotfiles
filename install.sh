cd $HOME

. /etc/os-release
OS=$ID

case "$OS" in
ubuntu) sudo apt update && sudo apt upgrade -y && sudo apt install git zsh stow curl -y
        ;;
debian) sudo apt update && sudo apt upgrade -y && sudo apt install git zsh stow curl -y
        ;;
fedora) sudo dnf upgrade -y && sudo dnf install git zsh stow curl -y
        ;;
esac

git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

rm .zshrc

cd dotfiles
stow zsh
