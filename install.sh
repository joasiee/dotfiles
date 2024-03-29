cd $HOME

if command -v apt &> /dev/null
then
    sudo apt update && sudo apt install git zsh stow curl python3-pip python3-venv -y
elif command -v dnf &> /dev/null
then
    sudo dnf upgrade -y && sudo dnf install git zsh stow curl python3-pip -y
elif command -v zypper &> /dev/null
then
    sudo zypper -n up && sudo zypper -n install git zsh stow curl python3-pip
elif command -v pacman &> /dev/null
then
    sudo pacman -Syu --noconfirm git zsh stow curl python-pip which -y
fi

git clone https://github.com/joasiee/dotfiles.git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

chsh -s $(which zsh)

python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install poetry
curl https://pyenv.run | bash

rm .zshrc
cd dotfiles
stow zsh

git config --global user.email "joasmulder@hotmail.com"
git config --global user.name "Joas Mulder"
