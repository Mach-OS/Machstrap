#!/bin/bash

welcome() {
  echo "Welcome, to Machstrap, this script will bootstrap Arch linux with programs and development tools to increase your productivity."
  echo "For this installer to work you will need to have an active internet connection and allow this program to run as root."

  pacman --noconfirm --needed -Sy archlinux-keyring > /dev/null 2>&1 || echo "MUST RUN AS ROOT USER"
}

add_user() {
  echo "Enter new username: "
  read username
  if id -u $username >/dev/null 2>$1; then
    echo "User already exists!"

  else
    echo -n "Enter password for new user: "
    read -s password
    useradd -m -g wheel "$username"
    echo "$password" | passwd "$username" --stdin
  fi
}

choose_user() {
  echo "Enter existing username: "
  read username
}

add_or_choose_user() {
  while true; do
    echo "Do you need to create a user?"
    echo "(y) create a user"
    echo "(n) choose an existing user"
    echo "(c) cancel"
    read -p "> " ync
      case $ync in
          [Yy]* ) add_user; break;;
          [Nn]* ) choose_user; break;;
          [Cc]* ) exit;;
          * ) echo " ";;
      esac
  done
}


install_basics() {
  pacman --noconfirm --needed -Sy $(< ./packages/base.list)
}

install_aur_helper() {
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si
  cd ..
  rm -rf yay-bin
}

install_fonts() {
  # do you want all the nerdfonts? This is about 2GB of data
  yay --noconfirm --needed -Sy nerd-fonts-jetbrains-mono
}

start_network_service() {
  systemctl start NetworkManager
  systemctl enable NetworkManager
}

start_display_manager_service() {
  systemctl enable lightdm
}


install_extras() {
  while true; do
    echo "Do you want to install extras?"
    cat ./packages/extra.list
    echo "(y) install extras"
    echo "(n) don't install extras"
    read -p "> " ync
      case $ync in
          [Yy]* ) yay --noconfirm --needed -Sy $(< ./packages/extra.list); break;;
          [Nn]* ) echo "Not installing extras"; break;;
          * ) echo " ";;
      esac
  done
}

# install_data_science_package() {
#   # ask first
#   sudo pacman -S $(< ./packages/data_science.list)
# }

# install_web_dev_package() {
#   # ask first
#   sudo pacman -S $(< ./packages/web_dev.list)
# }

# install_normie_package() {
#   # ask first
#   sudo pacman -S $(< ./packages/normie.list)
# }

# install_nvcode() {

# }



# welcome
welcome
