cd $HOME

if command -v apt &> /dev/null
then
    sudo apt update && sudo apt install git zsh stow curl keychain -y
fi

if command -v dnf &> /dev/null
then
    sudo dnf upgrade -y && sudo dnf install git zsh stow curl keychain -y
fi

if command -v pacman &> /dev/null
then
    sudo pacman -Syu --noconfirm git zsh stow curl keychain -y
fi

git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

cd dotfiles
stow zsh
