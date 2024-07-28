#!/bin/bash

# transform files into iso, because proxmox only accept iso and no floppy A:\

echo "[+] Build iso windows server 2022 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./assets/iso/autounattend-win22.iso assets/answer_file
# sha_winserv2022=$(sha256sum ./assets/iso/autounattend-win22.iso | cut -d ' ' -f1)
# echo "[+] update windows_server2022_proxmox_cloudinit.pkvars.hcl"
# sed -i "s/\"sha256:.*\"/\"sha256:$sha_winserv2022\"/g" windows_server2022_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso for scripts"
mkisofs -J -l -R -V "scripts CD" -iso-level 4 -o ./assets/iso/scripts_win22.iso scripts
# echo "scripts_win22.iso"
# sha256sum ./iso/scripts_win22.iso
