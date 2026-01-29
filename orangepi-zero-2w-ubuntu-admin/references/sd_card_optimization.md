# SD Card Optimization for Longevity

## Strategy Overview
SD cards have a limited number of write cycles. To extend the life of the 32GB Lexar SD card on the Orange Pi Zero 2W, we implement a "write-reduction" strategy by moving frequently written data to RAM and optimizing mount options.

## Core Components

### 1. Log2Ram
Moves `/var/log` to a RAM disk. Logs are periodically synced to the SD card (e.g., daily or on shutdown) to prevent excessive wear from constant log updates.
- **Installation**: Requires adding the Azlux repository and keyring.
  ```bash
  echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ stable main" | sudo tee /etc/apt/sources.list.d/azlux.list
  sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
  sudo apt update && sudo apt install log2ram
  ```
- **Benefit**: Drastically reduces writes from system services and kernel logging.

### 2. Mount Options: `noatime`
By default, Linux updates the "last access time" (`atime`) every time a file is read.
- **Optimization**: Use the `noatime` flag in `/etc/fstab` for the root partition.
- **Benefit**: Eliminates a write operation for every read operation.

### 3. Zram
Creates a compressed swap device in RAM.
- **Benefit**: Provides virtual memory without hitting the SD card's swap partition (if any), and is much faster than disk-based swap.

### 4. Tmpfs
Mounts temporary directories like `/tmp` and `/var/tmp` in RAM.
- **Benefit**: Ensures temporary files created by applications never touch the SD card.

## Implementation Checklist
- [ ] Install and configure `log2ram`.
- [ ] Update `/etc/fstab` to include `noatime` for the root filesystem.
- [ ] Configure `zram-tools` or `zram-config`.
- [ ] Add `tmpfs` entries to `/etc/fstab` for `/tmp` and `/var/tmp`.
- [ ] Disable or minimize systemd journal persistence if necessary.
