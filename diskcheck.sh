#/bin/bash
echo "***************************************"
echo "*****Warning: This with reboot the system. Ctrl+C now to stop or wait to continue"
echo "********************************************"
sleep 5
#First we get root
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
#Then we check some stuff
lsblk -tfp
read -p "Which device would you like to check? /dev/" var
e4defrag /dev/$var
fsck /dev/$var
reboot now
