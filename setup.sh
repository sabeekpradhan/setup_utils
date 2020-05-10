# Basic setup of vim, git, tmux, Python, Pip, and venv
sudo apt-get install vim git tmux python3 python3-pip python3-venv python-dev python3-dev

# Set up Vundle. Note: This assumes that you just installed vim 8.0+
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install Vundle packages
vim +PluginInstall +qall

# Install YouCompleteMe, via https://github.com/ycm-core/YouCompleteMe/wiki/Full-Installation-Guide
pip3 install --user setuptools
sudo apt-get install cmake
pushd ~
mkdir -p ycm_build
cd ycm_build
cmake -G "Unix Makefiles" . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
cmake --build . --target ycm_core
cd ~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/watchdog_deps/watchdog
rm -rf build/lib3
python3 setup.py build --build-base=build/3 --build-lib=build/lib3
popd

# Install gitpython and gitflow
pip3 install --user gitpython
# Wheel is required for termcolor, which is required for gitflow
pip3 install --user wheel
pip3 install --user termcolor
cp ./gitflow.py ~/.local/bin/gitflow

# Overwrite the vimrc, tmux config, and gitconfig.
cp ./vimrc ~/.vimrc
cp ./tmux.conf ~/.tmux.conf
cp ./tmux.reset.conf ~/.tmux.reset.conf
cp ./gitconfig ~/.gitconfig

# Put the local bin (including gitflow) in the path.
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc

# Add a couple convenience aliases to the bash_aliases file.
echo "alias ..='cd ..'" >> ~/.bash_aliases
echo "alias qgit=git" >> ~/.bash_aliases

# Source the bashrc
source ~/.bashrc
