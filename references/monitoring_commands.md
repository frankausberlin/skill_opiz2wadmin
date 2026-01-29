# Orange Pi Zero 2W Monitoring Commands Reference

A comprehensive quick reference for monitoring system health, performance, and resource usage on Orange Pi Zero 2W.

## System Overview

### Quick Status Check
```bash
# One-line system overview
echo "Temp: $(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))°C | Load: $(uptime | awk -F'load average:' '{print $2}') | Mem: $(free -h | awk '/^Mem:/ {print $3 "/" $2}') | Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
```

### Detailed System Information
```bash
# Complete system info
neofetch  # Install: sudo apt install neofetch

# Or use screenfetch
screenfetch  # Install: sudo apt install screenfetch

# Hardware details
lshw -short

# CPU information
lscpu

# Memory information
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Cached|SwapTotal|SwapFree"
```

---

## CPU Monitoring

### Temperature
```bash
# Current temperature (millidegrees Celsius)
cat /sys/class/thermal/thermal_zone0/temp

# Temperature in Celsius
echo "$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))°C"

# Continuous temperature monitoring
watch -n 1 'echo "Temperature: $(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))°C"'

# Temperature with date/time logging
while true; do echo "$(date '+%Y-%m-%d %H:%M:%S') - Temp: $(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))°C"; sleep 5; done
```

### CPU Frequency
```bash
# Current CPU frequency (all cores)
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

# Human-readable frequency
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo "$(basename $cpu): $(($(cat $cpu/cpufreq/scaling_cur_freq)/1000)) MHz"
done

# Current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Available governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Frequency limits
echo "Min: $(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)/1000)) MHz"
echo "Max: $(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)/1000)) MHz"

# Continuous monitoring
watch -n 1 'paste <(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq) <(echo -e "cpu0\ncpu1\ncpu2\ncpu3") | awk "{print \$2\": \"\$1/1000\" MHz\"}"'
```

### CPU Usage
```bash
# Current load average
uptime

# Per-core usage (1 second sample)
mpstat 1 1  # Install: sudo apt install sysstat

# Top processes by CPU
ps aux --sort=-%cpu | head -10

# Real-time CPU monitoring
top  # Press '1' to show per-core usage

# Or use htop (better visualization)
htop  # Install: sudo apt install htop

# CPU usage over time (5 samples, 2 sec intervals)
sar 2 5  # Install: sudo apt install sysstat
```

---

## Memory Monitoring

### RAM Usage
```bash
# Simple overview
free -h

# Detailed breakdown
free -m
#          total        used        free      shared  buff/cache   available
# Mem:      3906         782        2456          45         667        2877
# Swap:        0           0           0

# Watch memory usage
watch -n 2 free -h

# Memory usage percentage
free | awk '/^Mem:/ {printf "%.2f%%\n", $3/$2 * 100}'

# Detailed memory info
cat /proc/meminfo

# Per-process memory usage
ps aux --sort=-%mem | head -10

# Top memory consumers
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10
```

### Swap Usage
```bash
# Swap summary
swapon --show

# Zram status (if using zram)
zramctl

# Detailed zram info
cat /proc/swaps

# Swap usage breakdown
cat /proc/meminfo | grep -i swap

# Check for swap thrashing (high si/so values bad)
vmstat 1 5
```

### Memory Pressure
```bash
# Check OOM (Out Of Memory) events
dmesg | grep -i "out of memory\|oom"

# Memory cgroup pressure (if using cgroups)
cat /sys/fs/cgroup/memory/memory.pressure_level
```

---

## Storage Monitoring

### Disk Usage
```bash
# Overview of all filesystems
df -h

# Specific partition
df -h /

# Inode usage
df -i

# Disk usage by directory (sorted)
sudo du -h / | sort -h | tail -20

# Disk usage of current directory
du -h --max-depth=1 | sort -h

# Find large files
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

### I/O Performance
```bash
# I/O statistics
iostat -x 2 5  # Install: sudo apt install sysstat

# Real-time I/O by process
sudo iotop  # Install: sudo apt install iotop
# Or:
sudo iotop -o  # Only show processes with I/O

# I/O wait percentage
iostat -x 1 5 | grep -A 1 "Device"
# %iowait > 10% indicates I/O bottleneck

# SD card read/write activity
cat /sys/block/mmcblk0/stat
# Columns: reads, reads_merged, sectors_read, time_reading, 
#          writes, writes_merged, sectors_written, time_writing, ...
```

### SD Card Health
```bash
# Basic SD card info
sudo fdisk -l /dev/mmcblk0

# Detailed card info
sudo mmc extcsd read /dev/mmcblk0  # Install: sudo apt install mmc-utils

# SMART data (if supported)
sudo smartctl -a /dev/mmcblk0  # Install: sudo apt install smartmontools

# Check for errors in dmesg
dmesg | grep -i "mmc\|error\|timeout"

# Partition info
lsblk
```

### Write Activity Monitoring
```bash
# Monitor writes in real-time
watch -n 5 'cat /sys/block/mmcblk0/stat | awk "{print \"Writes: \" \$5 \", Sectors written: \" \$7}"'

# Total data written since boot (in KB)
awk '{print $7 * 512 / 1024}' /sys/block/mmcblk0/stat

# Log write activity over time
while true; do
    echo "$(date +%H:%M:%S) $(awk '{print $7}' /sys/block/mmcblk0/stat)"
    sleep 60
done
```

---

## Network Monitoring

### Interface Status
```bash
# List all interfaces
ip link show

# Or:
ifconfig -a

# Interface details
ip addr show

# Specific interface
ip addr show wlan0
```

### Wi-Fi Information
```bash
# Current Wi-Fi status
iwconfig wlan0

# Connection details
iw dev wlan0 link

# Signal strength and quality
watch -n 1 'iwconfig wlan0 | grep -E "Quality|Signal"'

# Available networks
sudo iwlist wlan0 scan | grep -E "ESSID|Quality|Signal"

# Power management status
iw dev wlan0 get power_save
```

### Network Traffic
```bash
# Real-time bandwidth usage
sudo iftop  # Install: sudo apt install iftop

# Or use nload
nload  # Install: sudo apt install nload

# Or use speedometer
speedometer -r wlan0 -t wlan0  # Install: sudo apt install speedometer

# Interface statistics
netstat -i

# Connection statistics
netstat -s

# Active connections
netstat -tuln
```

### Network Performance
```bash
# Ping latency
ping -c 10 8.8.8.8

# Continuous ping with timestamp
ping 8.8.8.8 | while read line; do echo "$(date '+%H:%M:%S') $line"; done

# Download/upload speed test
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -

# Or install speedtest-cli
sudo apt install speedtest-cli
speedtest-cli
```

---

## Process Monitoring

### Process List
```bash
# All processes
ps aux

# Process tree
pstree

# Or:
ps auxf

# Specific user
ps aux | grep username

# By CPU usage
ps aux --sort=-%cpu | head -10

# By memory usage
ps aux --sort=-%mem | head -10

# By start time
ps aux --sort=start_time
```

### Real-Time Process Monitoring
```bash
# Interactive process viewer
top

# Better process viewer
htop

# Key htop commands:
# F2: Setup (customize display)
# F3: Search process
# F4: Filter by name
# F5: Tree view
# F6: Sort by column
# F9: Kill process
```

### Service Status
```bash
# List all services
systemctl list-units --type=service

# Running services only
systemctl list-units --type=service --state=running

# Failed services
systemctl --failed

# Specific service status
systemctl status <service-name>

# Service logs
journalctl -u <service-name>

# Follow service logs
journalctl -fu <service-name>
```

---

## Log Monitoring

### System Logs
```bash
# Recent system logs
journalctl -b  # Since last boot

# Follow logs in real-time
journalctl -f

# Logs from last boot
journalctl -b -1

# Logs with priority (error, warning, etc.)
journalctl -p err

# Logs for specific service
journalctl -u sshd

# Time range
journalctl --since "1 hour ago"
journalctl --since "2024-01-01" --until "2024-01-31"

# Disk usage by logs
journalctl --disk-usage
```

### Log2Ram Status
```bash
# Check if log2ram is running
systemctl status log2ram

# Ram disk usage
df -h | grep log2ram

# Check log2ram size
du -sh /var/log

# Last sync time
sudo journalctl -u log2ram | tail -20
```

### Traditional Logs
```bash
# System log
tail -f /var/log/syslog

# Authentication log
tail -f /var/log/auth.log

# Kernel messages
dmesg
dmesg | tail -50

# Follow kernel messages
dmesg -w

# Boot messages
dmesg | less
```

---

## System Resource Summary Scripts

### Create a monitoring dashboard
Save as `~/monitor.sh`:

```bash
#!/bin/bash

clear
echo "=== Orange Pi Zero 2W Monitoring Dashboard ==="
echo "$(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Temperature
TEMP=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))
echo "🌡️  Temperature: ${TEMP}°C"

# CPU
FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo "⚡ CPU: $((FREQ/1000))MHz ($GOV)"

# Load
LOAD=$(uptime | awk -F'load average:' '{print $2}')
echo "📊 Load:$LOAD"

# Memory
MEM=$(free -h | awk 'NR==2{print $3 "/" $2 " (" $3/$2*100 "%)"}'echo "🧠 Memory: $MEM"

# Swap/Zram
if [ -f /proc/swaps ]; then
    SWAP=$(free -h | awk 'NR==3{print $3}')
    echo "💾 Swap: $SWAP"
fi

# Disk
DISK=$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')
echo "💿 Disk: $DISK"

# Network (if wlan0 exists)
if [ -d /sys/class/net/wlan0 ]; then
    SIGNAL=$(iwconfig wlan0 2>/dev/null | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2)
    echo "📶 Wi-Fi Signal: $SIGNAL"
fi

# Uptime
echo "⏱️  Uptime: $(uptime -p)"

echo ""
echo "Press Ctrl+C to exit"
```

Make executable and run:
```bash
chmod +x ~/monitor.sh
watch -n 2 ~/monitor.sh
```

### SD Card Write Monitor
Save as `~/sd-writes.sh`:

```bash
#!/bin/bash

INTERVAL=10

echo "Monitoring SD card writes (Ctrl+C to stop)..."
echo "Time       | Writes  | MB Written"
echo "-----------|---------|------------"

LAST_WRITES=$(awk '{print $5}' /sys/block/mmcblk0/stat)
LAST_SECTORS=$(awk '{print $7}' /sys/block/mmcblk0/stat)

while true; do
    sleep $INTERVAL
    
    WRITES=$(awk '{print $5}' /sys/block/mmcblk0/stat)
    SECTORS=$(awk '{print $7}' /sys/block/mmcblk0/stat)
    
    WRITES_DIFF=$((WRITES - LAST_WRITES))
    SECTORS_DIFF=$((SECTORS - LAST_SECTORS))
    MB_DIFF=$(echo "scale=2; $SECTORS_DIFF * 512 / 1024 / 1024" | bc)
    
    echo "$(date +%H:%M:%S) | $WRITES_DIFF | $MB_DIFF MB"
    
    LAST_WRITES=$WRITES
    LAST_SECTORS=$SECTORS
done
```

Make executable and run:
```bash
chmod +x ~/sd-writes.sh
./sd-writes.sh
```

---

## Automated Monitoring

### Create systemd service for monitoring

**Email alerts on high temperature** (requires mail setup):

Save as `/etc/systemd/system/temp-monitor.service`:
```ini
[Unit]
Description=Temperature Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/temp-monitor.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Save as `/usr/local/bin/temp-monitor.sh`:
```bash
#!/bin/bash

THRESHOLD=75000  # 75°C in millidegrees

while true; do
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    
    if [ $TEMP -gt $THRESHOLD ]; then
        echo "High temperature: $((TEMP/1000))°C detected!" | \
            mail -s "Orange Pi High Temperature Alert" user@example.com
        
        # Reduce CPU frequency
        echo 1200000 > /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    fi
    
    sleep 60
done
```

Enable:
```bash
sudo chmod +x /usr/local/bin/temp-monitor.sh
sudo systemctl enable temp-monitor
sudo systemctl start temp-monitor
```

---

## Monitoring Tools Comparison

| Tool | Purpose | Installation | Resource Usage |
|------|---------|--------------|----------------|
| `top` | Process monitoring | Pre-installed | Low |
| `htop` | Enhanced process monitoring | `apt install htop` | Low |
| `iotop` | I/O monitoring | `apt install iotop` | Low |
| `iftop` | Network bandwidth | `apt install iftop` | Low |
| `sysstat` (iostat, sar, mpstat) | System statistics | `apt install sysstat` | Low |
| `nethogs` | Per-process network | `apt install nethogs` | Low |
| `glances` | All-in-one monitoring | `apt install glances` | Medium |
| `netdata` | Web-based monitoring | Complex setup | High |
| `prometheus + grafana` | Advanced metrics | Complex setup | High |

For Orange Pi Zero 2W, stick to lightweight tools (top, htop, iostat) to avoid consuming resources.

---

## Remote Monitoring

### SSH for remote access
```bash
# Enable SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Monitor via SSH
ssh user@orangepi-ip "htop"

# Run monitoring script remotely
ssh user@orangepi-ip "~/monitor.sh"
```

### Web-based monitoring with Glances
```bash
# Install glances
sudo apt install glances

# Run in web server mode
glances -w

# Access at: http://orangepi-ip:61208
```

---

## Best Practices

1. **Regular Monitoring**: Check system health daily
2. **Baseline Metrics**: Know your system's normal behavior
3. **Automated Alerts**: Set up notifications for critical thresholds
4. **Log Rotation**: Ensure logs don't fill up disk (use log2ram)
5. **Lightweight Tools**: Avoid resource-heavy monitoring on constrained devices
6. **Remote Monitoring**: Use SSH rather than running heavy GUIs locally

---

## Quick Reference Card

```
Temperature:    cat /sys/class/thermal/thermal_zone0/temp
CPU Frequency:  cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
Memory:         free -h
Disk:           df -h
I/O:            iostat -x 2 3
Processes:      htop
Network:        iwconfig wlan0
Logs:           journalctl -f
Services:       systemctl --failed
```

Keep this reference handy for quick system checks!
