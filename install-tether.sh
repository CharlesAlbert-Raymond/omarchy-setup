#!/bin/sh
# Tether bridges an iPhone to the desktop (clipboard, files, messages,
# notifications). tether-bin is the upstream release tarball; tether-git
# builds from source and pulls in a full toolchain for no gain.
#
# Omarchy's ufw denies incoming by default, which blocks the iPhone from
# connecting back to tetherd on 5134/tcp (mDNS discovery still works, so the
# phone sees the box but pairing never completes). The package ships a ufw app
# profile covering 5134/tcp and 5353/udp; allow it, as Omarchy does for
# LocalSend.
#
# Messages, contacts and notification mirroring ride Bluetooth (MAP/PBAP/ANCS)
# and need two system changes the package deliberately leaves to the user;
# these are the exact commands `tether --bt-setup` prints:
#   1. bluetoothd with --experimental, for the LE bearer API notification
#      mirroring needs. Must be in place BEFORE pairing the iPhone over
#      Bluetooth: a bond made without it has no LE half.
#   2. Class of Device A/V Hands-Free (4/8), or iOS never offers the "Show
#      Message Notifications" / "Sync Contacts" toggles. bluetoothd resets the
#      class on every start, so the packaged tether-btclass@ unit re-applies it
#      (PartOf=bluetooth.service).
# Side effect: this box looks like a hands-free headset to every Bluetooth
# device, not just the iPhone.

yay -S --noconfirm --needed tether-bin

if sudo ufw status | grep -q '^Tether '; then
  echo "tether: firewall rule already present"
else
  sudo ufw allow Tether
fi

dropin=/etc/systemd/system/bluetooth.service.d/experimental.conf
if [ -f "$dropin" ]; then
  echo "tether: bluetoothd --experimental already configured"
else
  sudo mkdir -p /etc/systemd/system/bluetooth.service.d
  printf '[Service]\nExecStart=\nExecStart=%s --experimental\n' \
    /usr/lib/bluetooth/bluetoothd | sudo tee "$dropin" >/dev/null
  sudo systemctl daemon-reload && sudo systemctl restart bluetooth
fi

if systemctl is-enabled --quiet tether-btclass@hci0; then
  echo "tether: bluetooth class unit already enabled"
else
  sudo systemctl enable --now tether-btclass@hci0
fi
