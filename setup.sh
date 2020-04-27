#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Update Kali and tweak Kali configuration
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Wait for other sudo apt updates to finish
# To prevent sudo apt from failing
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    tput rc
    echo -n "Waiting for other software managers to finish..."
    sleep 1s
done

# Configure sudo apt to be silent
export DEBIAN_FRONTEND=noninteractive

# Update the full system
sudo apt-get update
sudo apt-get -yq upgrade


# Configure Gnome
# Disable updates
gsettings set org.gnome.software download-updates false
# Disable automatic installation of security upgrades
sudo apt-get -yq purge unattended-upgrades
# Disable automatic timezone & date/time
gsettings set org.gnome.desktop.datetime automatic-timezone false
timedatectl set-ntp 0
# Disable lock screen
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Disable screensaver
dconf write /org/gnome/desktop/screensaver/lock-enabled false
# Configure Alt-Tab behavior
gnome-shell-extension-tool -e alternate-tab@gnome-shell-extensions.gcampax.github.com

# Dash-to-dock no autohide
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true



# crackmapexec
sudo apt-get -yq install crackmapexec


# wmic for Linux
sudo apt-get -yq install wmis


# VIM
# Manage runtime path: https://github.com/tpope/vim-pathogen/
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cat >~/.vimrc << EOL
execute pathogen#infect()
syntax on
filetype plugin indent on
EOL
# Syntax highlighting
# > PowerShell
mkdir -p ~/.vim/bundle
cd ~/.vim/bundle
git clone https://github.com/PProvost/vim-ps1

# Initialize Metasploit
sudo update-rc.d postgresql enable
sudo service postgresql start
sudo msfdb init
# sudo apt-get install metasploit-framework (msfupdate): has already been performed by sudo apt-get upgrade
sudo msfconsole -x "db_rebuild_cache; sleep 600; exit" &

#### Exploitation ####
mkdir ~/Tools
cd ~/Tools

#### Post-exploitation frameworks ####
# => PowerShell
mkdir ~/Tools/PowerShell && cd ~/Tools/PowerShell
# PowerSploit
git clone https://github.com/PowerShellMafia/PowerSploit
# Empire
export STAGING_KEY=RANDOM
git clone https://github.com/EmpireProject/Empire
cd ./Empire/setup/ && ./install.sh && cd ../..
# Nishang
git clone https://github.com/samratashok/nishang
# CimSweep
git clone https://github.com/PowerShellMafia/CimSweep
# PowerLurk
git clone https://github.com/Sw4mpf0x/PowerLurk
# PowerMemory
git clone https://github.com/giMini/PowerMemory
# PowerShell-Suite
git clone https://github.com/FuzzySecurity/PowerShell-Suite
# Autoruns
git clone https://github.com/p0w3rsh3ll/AutoRuns

# => CSharp
mkdir ~/Tools/CSharp && cd ~/Tools/CSharp
# NoPowerShell
curl -s https://api.github.com/repos/bitsadmin/nopowershell/releases/latest | grep browser_download_url | cut -d '"' -f 4 | wget -i -
unzip NoPowerShell_trunk.zip -d NoPowerShell
rm NoPowerShell_trunk.zip
# SharpUp - TODO: compile
git clone https://github.com/GhostPack/SharpUp
# SharpWeb
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.2/SharpWeb.exe -O SharpWeb46.exe
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.1/SharpWeb.exe -O SharpWeb45.exe
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.0/SharpWeb.exe -O SharpWeb20.exe
# WireTap - TODO: compile
git clone https://github.com/djhohnstein/WireTap
# SharpSploit - TODO: compile
git clone https://github.com/cobbr/SharpSploit

#### Other tools ####
cd ~/Tools
# ReVBShell
git clone https://github.com/bitsadmin/revbshell

# Dirsearch
git clone https://github.com/maurosoria/dirsearch

# Web shells and more
git clone https://github.com/fuzzdb-project/fuzzdb

# EmPyre
git clone https://github.com/adsudo aptivethreat/EmPyre
cd ./EmPyre/setup/ && ./install.sh && cd ../..

# Shellter binary obfuscator
wget https://www.shellterproject.com/Downloads/Shellter/Latest/shellter.zip
unzip shellter.zip
rm shellter.zip

# Windows Exploit Suggester
git clone https://github.com/GDSSecurity/Windows-Exploit-Suggester
pip install xlutils
cd Windows-Exploit-Suggester
python windows-exploit-suggester.py --update
cd ..

# Linux Exploit Suggester
git clone https://github.com/PenturaLabs/Linux_Exploit_Suggester

# unix-privesc-check
git clone https://github.com/pentestmonkey/unix-privesc-check

# PEASS - Privilege Escalation Awesome Scripts SUITE
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git

# Latest impacket tools
git clone https://github.com/CoreSecurity/impacket
cd /tmp
git clone https://github.com/CoreSecurity/impacket
cd impacket
sudo python setup.py install
cd ~

#### Miscellaneous ####
# Unpack rockyou wordlist
gzip -d /usr/share/wordlists/rockyou.txt.gz

# TODO: Add additional rules
#wget http://contest-2010.korelogic.com/rules.txt -O /usr/share/john/korelogic.conf

# TODO: Set rockyou as default password list for John
# In /etc/john/john.conf
# Default wordlist file name. Will fall back to standard wordlist if not
# defined.
#Wordlist = $JOHN/password.lst

# Python
pip install --upgrade pip
pip install pwntools
pip install beautifulsoup4

# Proper terminal experience
sudo apt-get -yq install terminator zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | grep -v "env zsh -l")"
# Enable infinite scrollback
mkdir ~/.config/terminator/
cat <<EOT > ~/.config/terminator/config
[profiles]
  [[default]]
    scrollback_infinite = True
EOT
# Disable update check
sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/g' ~/.zshrc
# powerlevel9k theme
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
sudo mv PowerlineSymbols.otf /usr/share/fonts/X11/misc
fc-cache -vf /usr/share/fonts/X11/misc
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
sed -i 's|ZSH_THEME=".*"|ZSH_THEME="norm"|g' ~/.zshrc

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
sed -i 's|^plugins=[(]\(\w*\)[)]|plugins=\(\1 zsh-autosuggestions\)|g' ~/.zshrc
# Ctrl + space for autocomplete
cat <<EOT >> ~/.zshrc
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
EOT

# Oracle JRE
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/sudo apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/sudo apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
sudo apt-get -yq install oracle-java8-installer

# VS Code
# TODO Find a way to install VS Code

# PEAS

# Cleanup sudo apt
sudo apt -yq autoremove

# Update locate db
updatedb

# Wait for msfconsole
echo "Waiting for msfconsole -> db_rebuild_cache to finish..."
wait

# Cleanup bash history
history -c

# Finished
echo "Done!"
