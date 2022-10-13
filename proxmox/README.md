# Promox


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
