# Orange Pi Zero 2W Troubleshooting Guide

This guide provides detailed diagnostic procedures and solutions for common issues encountered with the Orange Pi Zero 2W running Ubuntu 24.04.

## Table of Contents

1. [System Performance Issues](#system-performance-issues)
2. [Boot and Startup Problems](#boot-and-startup-problems)
3. [Network Connectivity Issues](#network-connectivity-issues)
4. [Storage and SD Card Problems](#storage-and-sd-card-problems)
5. [Thermal and Power Issues](#thermal-and-power-issues)
6. [Service and Application Failures](#service-and-application-failures)
7. [Hardware-Specific Issues](#hardware-specific-issues)

---

## System Performance Issues

### Symptom: System is slow or unresponsive

**Diagnostic Steps**:

1. **Check Memory Usage**:
   ```bash
   free -h
   ```
   - If "available" memory < 200MB: Memory pressure
   - If swap is heavily used: Possible swap thrashing

2. **Check CPU Load**:
   ```bash
   uptime
   ```
   - Load average > 4.0 (number of CPU cores) indicates high load
   
3. **Check I/O Wait**:
   ```bash
   iostat -x 2 3
   ```
   - `%iowait` > 10%: Disk I/O bottleneck
   
4. **Identify Resource Hogs**:
   ```bash
   htop
   # Press F6 to sort, select PERCENT_CPU or PERCENT_MEM
   ```

**Common Causes & Solutions**:

| Cause | Symptoms | Solution |
|-------|----------|----------|
| Memory leak | Free memory decreasing over time | Identify and restart leaky service |
| Swap thrashing | Constant disk activity, high iowait | Increase zram size or reduce services |
| Runaway process | Single process using 100% CPU | Kill process: `kill -9 <PID>` |
| SD card slowdown | High iowait, slow file operations | Check card health, may need replacement |
| Thermal throttling | CPU frequency drops, temperature >70°C | Reduce max frequency or add heatsink |

**Example: Fixing Memory Pressure**:
```bash
# Identify memory-hungry processes
ps aux --sort=-%mem | head -10

# Stop non-essential services
sudo systemctl stop <service-name>

# Clear page cache (safe, data not lost)
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

# Increase zram size (edit /etc/default/zramswap if using zram-config)
sudo nano /etc/default/zramswap
# Change PERCENT=50 to PERCENT=100
sudo systemctl restart zramswap
```

---

### Symptom: Lag or stuttering during use

**Diagnostic Steps**:

1. **Check Temperature**:
   ```bash
   while true; do cat /sys/class/thermal/thermal_zone0/temp; sleep 1; done
   ```
   Press Ctrl+C to stop. Temperatures in millidegrees Celsius (divide by 1000).

2. **Check CPU Frequency Scaling**:
   ```bash
   watch -n 1 'cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq'
   ```
   If frequency keeps dropping below 1GHz: Likely thermal throttling

3. **Check for Background Updates**:
   ```bash
   ps aux | grep -E "apt|dpkg|unattended"
   ```

**Solutions**:

- **If thermal throttling**: Add heatsink, improve ventilation, or reduce max CPU frequency
  ```bash
  # Limit to 1.2GHz
  echo 1200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
  ```

- **If background updates**: Wait for completion or disable unattended-upgrades
  ```bash
  sudo systemctl disable unattended-upgrades
  ```

---

## Boot and Startup Problems

### Symptom: System fails to boot or boots to emergency mode

**Diagnostic Steps**:

1. **Check boot messages via serial console** (requires USB-to-TTL adapter):
   - Connect to GPIO pins (see hardware_specs.md)
   - Baud rate: 115200, 8N1
   
2. **Boot from recovery** (if available):
   - Hold a specific key during power-on (hardware-dependent)
   
3. **Common causes**:
   - Corrupted `/etc/fstab`
   - Failed filesystem check
   - Partition table corruption
   - Boot partition full

**Solution for corrupted fstab**:

```bash
# Boot from another SD card or USB with Linux
# Mount the problematic root partition
sudo mkdir /mnt/orangepi
sudo mount /dev/mmcblk0p1 /mnt/orangepi  # Adjust partition number

# Check current fstab
cat /mnt/orangepi/etc/fstab

# Restore from backup or fix manually
sudo nano /mnt/orangepi/etc/fstab

# Unmount and reboot
sudo umount /mnt/orangepi
sudo reboot
```

**Solution for full boot partition**:

```bash
# Mount boot partition
sudo mount /dev/mmcblk0p1 /boot  # If separate boot partition

# Check usage
df -h /boot

# Remove old kernels (keep latest and one previous)
sudo apt autoremove --purge

# Or manually remove old kernel images
ls -lh /boot
sudo rm /boot/vmlinuz-<old-version>
sudo rm /boot/initrd.img-<old-version>
```

---

### Symptom: Services fail to start after reboot

**Diagnostic Steps**:

1. **List failed services**:
   ```bash
   systemctl --failed
   ```

2. **Check specific service status**:
   ```bash
   systemctl status <service-name>
   journalctl -xeu <service-name>
   ```

3. **Common causes**:
   - Dependency on tmpfs/log2ram not ready
   - Wrong file permissions after tmpfs mount
   - Service timeout too short

**Solutions**:

**For log2ram timing issues**:
```bash
# Edit service to start after log2ram
sudo systemctl edit <service-name>

# Add these lines:
[Unit]
After=log2ram.service
Requires=log2ram.service

# Save and restart
sudo systemctl daemon-reload
sudo systemctl restart <service-name>
```

**For permission issues on tmpfs**:
```bash
# Check permissions
ls -la /tmp /var/tmp

# Fix if needed (in systemd service or tmpfs mount options)
# Edit /etc/fstab:
tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,mode=1777 0 0
```

---

## Network Connectivity Issues

### Symptom: Wi-Fi disconnects frequently

**Diagnostic Steps**:

1. **Check signal quality**:
   ```bash
   iwconfig wlan0
   ```
   - Link Quality < 40/70: Weak signal
   - Signal level < -70 dBm: Very weak

2. **Check for disconnections in logs**:
   ```bash
   journalctl -u NetworkManager | grep -i "disconnected\|deauth\|reason"
   ```

3. **Check power management**:
   ```bash
   iw dev wlan0 get power_save
   ```
   - If "on": Power saving may cause disconnections

4. **Check for interference**:
   ```bash
   sudo iwlist wlan0 scan | grep -E "ESSID|Frequency|Signal"
   ```

**Solutions**:

**Disable Wi-Fi power saving**:
```bash
# Temporary
sudo iw dev wlan0 set power_save off

# Permanent: Create script
sudo nano /etc/network/if-up.d/wifi-power
```

Add:
```bash
#!/bin/sh
/sbin/iw dev wlan0 set power_save off
```

Make executable:
```bash
sudo chmod +x /etc/network/if-up.d/wifi-power
```

**Switch to 2.4GHz if using 5GHz**:
- 2.4GHz has better range and obstacle penetration
- Edit netplan configuration to prefer 2.4GHz band

**Use Ethernet if available**:
- Ethernet via expansion board is more stable for stationary deployments

---

### Symptom: Cannot connect to Wi-Fi network

**Diagnostic Steps**:

1. **Check if wlan0 exists**:
   ```bash
   ip link show wlan0
   ```
   
2. **Check if driver is loaded**:
   ```bash
   lsmod | grep -i wifi
   dmesg | grep -i wifi
   ```

3. **Scan for networks**:
   ```bash
   sudo iwlist wlan0 scan | grep ESSID
   ```

4. **Check netplan configuration**:
   ```bash
   cat /etc/netplan/*.yaml
   ```

**Solutions**:

**For driver issues**:
```bash
# Update firmware
sudo apt update
sudo apt install linux-firmware

# Reload module
sudo modprobe -r <wifi-module-name>
sudo modprobe <wifi-module-name>
```

**For configuration issues**:
```bash
# Edit netplan
sudo nano /etc/netplan/01-netcfg.yaml
```

Example configuration:
```yaml
network:
  version: 2
  renderer: networkd
  wifis:
    wlan0:
      dhcp4: yes
      dhcp6: no
      access-points:
        "YourSSID":
          password: "YourPassword"
```

Apply:
```bash
sudo netplan apply
```

---

## Storage and SD Card Problems

### Symptom: SD card read-only or filesystem corruption

**Diagnostic Steps**:

1. **Check mount status**:
   ```bash
   mount | grep mmcblk0
   ```
   - If "ro" appears: Mounted read-only

2. **Check dmesg for errors**:
   ```bash
   dmesg | grep -i "mmc\|error\|readonly"
   ```

3. **Check filesystem status**:
   ```bash
   sudo tune2fs -l /dev/mmcblk0p1 | grep -E "Filesystem state|Mount count"
   ```

**Solutions**:

**For readonly mount**:
```bash
# Remount as read-write (temporary)
sudo mount -o remount,rw /

# If it fails, filesystem is likely corrupted
```

**For filesystem corruption**:
```bash
# IMPORTANT: Unmount first or boot from another system
# If root partition, boot from USB or another SD card

# Run filesystem check
sudo fsck -y /dev/mmcblk0p1

# If many errors, backup data and reformat
```

**For dying SD card**:
- Symptoms: Frequent corruption, read errors, slow performance
- Solution: Replace SD card
- Prevention: Use quality cards (SanDisk, Samsung, Lexar), implement write-reduction

---

### Symptom: No space left on device

**Diagnostic Steps**:

1. **Check disk usage**:
   ```bash
   df -h
   ```

2. **Find large files/directories**:
   ```bash
   sudo du -h / | sort -h | tail -20
   ```

3. **Check for deleted but open files** (still consuming space):
   ```bash
   sudo lsof | grep deleted
   ```

4. **Check inode usage**:
   ```bash
   df -i
   ```

**Solutions**:

**Clean package cache**:
```bash
sudo apt clean
sudo apt autoclean
sudo apt autoremove
```

**Remove old logs**:
```bash
# If not using log2ram
sudo journalctl --vacuum-time=7d
sudo rm -rf /var/log/*.gz
sudo rm -rf /var/log/*.old
```

**Remove deleted but open files**:
```bash
# Identify process holding file
sudo lsof | grep deleted

# Restart service or kill process
sudo systemctl restart <service>
```

**Expand partition** (if SD card larger than current partition):
```bash
# Use parted or gparted to resize partition
sudo parted /dev/mmcblk0
# (use resize command)
```

---

## Thermal and Power Issues

### Symptom: System randomly reboots or freezes

**Diagnostic Steps**:

1. **Check power supply**:
   - Use 5V/3A adapter (5V/2A may be insufficient under load)
   - Check cable quality (poor cables cause voltage drops)

2. **Check last reboot reason**:
   ```bash
   last reboot
   journalctl -b -1  # Logs from previous boot
   ```

3. **Monitor voltage**:
   - Voltage drop during load indicates power issue

**Solutions**:

**For power issues**:
- Upgrade to 5V/3A power supply
- Use shorter, thicker USB cable
- Avoid connecting high-power USB devices without powered hub

**For thermal issues**:
```bash
# Reduce CPU frequency permanently
sudo nano /etc/rc.local
```

Add:
```bash
echo 1200000 > /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

Or add heatsink to SoC.

---

### Symptom: High temperature (>75°C)

**Diagnostic Steps**:

1. **Monitor temperature under different loads**:
   ```bash
   # Idle temperature
   cat /sys/class/thermal/thermal_zone0/temp
   
   # Under load (run stress test)
   sudo apt install stress
   stress --cpu 4 --timeout 60s &
   watch -n 1 'cat /sys/class/thermal/thermal_zone0/temp'
   ```

2. **Check current CPU governor**:
   ```bash
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

**Solutions**:

**Reduce maximum CPU frequency**:
```bash
# Limit to 1.2GHz (balance of performance and temperature)
echo 1200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

**Change CPU governor**:
```bash
# Powersave mode
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Add heatsink**:
- Self-adhesive aluminum heatsink for Allwinner H618
- Size: 20x20mm or larger recommended

---

## Service and Application Failures

### Symptom: Docker containers won't start

**Diagnostic Steps**:

1. **Check Docker status**:
   ```bash
   sudo systemctl status docker
   ```

2. **Check logs**:
   ```bash
   sudo journalctl -u docker
   ```

3. **Check storage driver**:
   ```bash
   docker info | grep -i "storage driver"
   ```

**Common Issues**:

- **Overlay2 storage driver**: May have issues on some SD cards
  - Solution: Switch to vfs or devicemapper (slower but more compatible)

- **Out of disk space**: Docker images consume significant space
  - Solution: Clean unused images: `docker system prune -a`

- **Incompatible architecture**: Some images are x86-only
  - Solution: Use ARM64/aarch64 images explicitly

---

### Symptom: Python/Node.js applications crashing

**Check for ARM compatibility**:
- Not all Python/Node.js packages have ARM builds
- Check error logs for "unsupported architecture" or "illegal instruction"

**Solutions**:
- Use virtual environments: `python3 -m venv venv`
- Install ARM-compatible packages: Check pip/npm for aarch64 wheels
- Compile from source if necessary

---

## Hardware-Specific Issues

### Symptom: GPIO pins not working

**Diagnostic Steps**:

1. **Check if GPIO is accessible**:
   ```bash
   ls -l /dev/gpiochip*
   ```

2. **Install GPIO tools**:
   ```bash
   sudo apt install python3-lgpio gpiod
   ```

3. **Test GPIO**:
   ```bash
   gpioinfo
   ```

**Common Issues**:
- Pins may be used by other functions (UART, SPI, I2C)
- Device tree overlay may need configuration

---

### Symptom: HDMI output not working

**Diagnostic Steps**:

1. **Check if HDMI device is detected**:
   ```bash
   dmesg | grep -i hdmi
   ```

2. **List available display modes**:
   ```bash
   xrandr  # If X11 is running
   ```

**Solutions**:
- Edit `/boot/armbianEnv.txt` or equivalent to set HDMI resolution
- Ensure HDMI cable is connected before boot
- Try different HDMI cable or display

---

## General Troubleshooting Workflow

For any undiagnosed issue, follow this systematic approach:

1. **Gather Information**:
   ```bash
   # System info
   uname -a
   cat /etc/os-release
   
   # Hardware info
   lshw -short
   
   # Recent logs
   journalctl -b --no-pager | tail -100
   
   # Resource usage
   top -bn1 | head -20
   ```

2. **Search for Error Messages**:
   - Use `searxng` MCP to search for specific error messages
   - Check Orange Pi forums and Armbian forums
   
3. **Isolate the Problem**:
   - Disable non-essential services one by one
   - Boot in single-user mode if needed
   
4. **Test Hypotheses**:
   - Make one change at a time
   - Use `sequentialthinking` MCP for complex diagnostic workflows
   
5. **Document Solution**:
   - Keep notes on what worked
   - Share solutions with community

---

## Emergency Recovery

If system is completely unresponsive or won't boot:

1. **Remove SD card**
2. **Insert into another Linux system**
3. **Mount and backup critical data**:
   ```bash
   sudo mount /dev/sdX1 /mnt
   tar czf backup-$(date +%F).tar.gz /mnt/home /mnt/etc
   ```
4. **Check filesystem**:
   ```bash
   sudo fsck -y /dev/sdX1
   ```
5. **Fix issues** (fstab, services, etc.)
6. **If unfixable**: Restore from backup image

**Prevention**:
- Keep weekly SD card image backups
- Use version control for custom scripts
- Document all system modifications

---

## Additional Resources

- Official Orange Pi Wiki: http://www.orangepi.org/orangepiwiki/
- Ubuntu ARM Documentation: https://wiki.ubuntu.com/ARM
- Armbian Forums: https://forum.armbian.com/
- Stack Exchange: https://unix.stackexchange.com/

For issues not covered here, use `searxng` MCP to research or consult the community.
