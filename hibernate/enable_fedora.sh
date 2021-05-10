#!/usr/bin/bash

sudo touch /var/swapfile
sudo chattr +C /var/swapfile
sudo fallocate --length "$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')" /var/swapfile
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
echo '/var/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo podman run --rm -it --privileged -v /var/swapfile:/var/swapfile -v /tmp:/tmp debian:stable sh -c '
  apt-get update &&
  apt-get install -qy gcc wget &&
  wget "https://raw.githubusercontent.com/osandov/osandov-linux/61679ecd914d653bab14d0e752595e86b9f50513/scripts/btrfs_map_physical.c" &&
  gcc -O2 -o btrfs_map_physical btrfs_map_physical.c &&
  ./btrfs_map_physical /var/swapfile | sed -n "2p" | awk "{print \$NF}" >/tmp/swap_physical_offset
  '
SWAP_PHYSICAL_OFFSET=$(cat /tmp/swap_physical_offset)
SWAP_OFFSET=$(echo "${SWAP_PHYSICAL_OFFSET} / $(getconf PAGESIZE)" | bc)

SWAP_UUID=$(findmnt -no UUID -T /var/swapfile)
RESUME_ARGS="resume=UUID=${SWAP_UUID} resume_offset=${SWAP_OFFSET}"
echo "${RESUME_ARGS}"

sudo grubby --update-kernel=ALL --args="${RESUME_ARGS}"

sudo mkdir -p /etc/systemd/system/systemd-logind.service.d/
cat <<-EOF | sudo tee /etc/systemd/system/systemd-logind.service.d/override.conf
[Service]
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
EOF
sudo mkdir -p /etc/systemd/system/systemd-hibernate.service.d/
cat <<-EOF | sudo tee /etc/systemd/system/systemd-hibernate.service.d/override.conf
[Service]
Environment=SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK=1
EOF

sudo echo "add_dracutmodules+=' resume '" >> /etc/dracut.conf.d/resume.conf
sudo dracut -f

echo "HandleLidSwitch=suspend-then-hibernate" | sudo tee -a /etc/systemd/logind.conf
echo "HibernateDelaySec=45min" | sudo tee -a /etc/systemd/sleep.conf
