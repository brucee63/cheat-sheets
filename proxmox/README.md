# Promox

## installing proxmox with display driver issues
[link](https://subscription.packtpub.com/book/big-data-and-business-intelligence/9781788397605/1/ch01lvl1sec12/debugging-the-proxmox-installation) <br />
when booting to installer splash screen, press E 
then edit the loader info, add `nomodeset` to the following -

```sh
linux/boot/linux26 ro ramdisk_size=16777216 rw quiet nomodeset
```

Then press f10 to continue <br />
[link](https://www.rpiathome.com/2020/10/21/proxmox-6-2-1-installation-fails-after-dhcp-lease-obtained/#comments)

```sh
chmod 1777 /tmp   
#apt update
#apt upgrade
Xorg -configure   
mv /xorg.conf.new /etc/X11/xorg.conf
vim /etc/X11/xorg.conf # update Driver "intel"-> "fbdev" 
startx
```

Now you can restart and connect to the webui, use ssh to connect otherwise.

## qemu guest agent
Install the guest agent on the vm
```sh
sudo apt install qemu-guest-agent
sudo systemctl enable qemu-guest-agent
```

In proxmox, under the VM Options, enable Qemu Guest Agent
Shutdown the VM
Start the VM

The following service should show `active (running)` now -
```sh
sudo systemctl status qemu-guest-agent
```

## enable dark theme
[github](https://github.com/Weilbyte/PVEDiscordDark)
```sh
wget https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh
bash PVEDiscordDark.sh install
```

## two node cluster, no quorum
In the case you want to have one proxmox server up without the other, update the `/etc/pve/corosync.conf` file, add the following to the quorum config section
```js
quorum {
  provider: corosync_votequorum
  two_node: 1
  wait_for_all: 0
}
```