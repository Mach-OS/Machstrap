#!/bin/bash

install_base_packages() {
	cat ./packages/base.list | xargs sudo pacman -S -y

	echo "Are you using a laptop? (y/n)"
	read -r laptop

	if [[ "$laptop" == "y" ]]; then
		pacman -S tlp
		systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
	fi
}

install_processor_image() {
	echo "Do you have an AMD processor? (y/n)"
	read -r amd
	if [[ "$amd" == "y" ]]; then
		pacman -S amd-ucode
	fi

	echo "Do you have an Intel processor? (y/n)"
	read -r intel
	if [[ "$intel" == "y" ]]; then
		pacman -S intel-ucode
	fi
}

install_graphics_drivers() {
	echo "Do you have an nvidia card? (y/n)"
	read -r nvidia
	if [[ "$nvidia" == "y" ]]; then
		pacman -S nvidia nvidia-utils nvidia-settings
	fi

	echo "Do you have an amd card? (y/n)"
	read -r amd
	if [[ "$amd" == "y" ]]; then
		pacman -S xf86-video-amdgpu
	fi
}

create_user() {
	echo "Enter a value for the username: "
	read -r username

	useradd -m $username
	echo "Enter a value for the user password: "
	read -r password
	echo $username:$password | chpasswd

	echo "$username ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers.d/$username

	su - $username
}

install_aur_helper() {
	echo "Installing AUR helper paru..."
	git clone https://aur.archlinux.org/paru.git
	cd ./paru
	makepkg -si
	cd ..
	rm -rf ./paru
}

install_aur_packages() {
	echo "Installing AUR packages..."
	cat ./packages/aur.list | xargs paru -S -y
}

install_bluetooth_packages() {
	echo "Do you want to install bluetooth?"
	read -r bluetooth
	if [[ "$bluetooth" == "y" ]]; then
		cat ./packages/bluetooth.list | xargs sudo pacman -S -y
		systemctl enable bluetooth
	fi
}

enable_services() {
	echo "Do you want to enable ssh? (y/n)"
	read -r ssh
	if [[ "$ssh" == "y" ]]; then
		systemctl enable sshd
	fi

	systemctl enable NetworkManager
	systemctl enable cups
	systemctl enable avahi-daemon
	systemctl enable fstrim.timer
	systemctl enable firewalld
	systemctl enable acpid
}

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
