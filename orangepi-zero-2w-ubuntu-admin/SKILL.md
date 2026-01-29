---
name: orangepi-zero-2w-ubuntu-admin
description: This skill provides comprehensive administration, optimization, and troubleshooting workflows for Orange Pi Zero 2W running Ubuntu 24.04. Focuses on SD card longevity through write-reduction strategies, system performance optimization, thermal management, and common administrative tasks specific to ARM-based SBCs. Use when administering, optimizing, troubleshooting, or maintaining an Orange Pi Zero 2W system.
license: MIT
metadata:
  category: administration
  hardware: Orange Pi Zero 2W
  os: Ubuntu 24.04
  agent_environment: kilocode-cli
  mcp_servers:
    - context7
    - filesystem
    - searxng
    - sequentialthinking
---

# Orange Pi Zero 2W Ubuntu Administration Skill

This skill provides specialized knowledge for administering an Orange Pi Zero 2W single-board computer running Ubuntu 24.04 (Noble Numbat). The skill emphasizes SD card longevity, system optimization, and ARM SBC-specific best practices.

## Purpose

The Orange Pi Zero 2W is an ARM-based single-board computer with limited resources (4GB RAM, SD card storage). This skill provides:

1. **SD Card Protection**: Write-reduction strategies to extend the lifespan of the 32GB Lexar SD card
2. **System Optimization**: Memory management, swap configuration, and performance tuning for ARM architecture
3. **Thermal Management**: CPU frequency scaling and temperature monitoring for fanless operation
4. **Network Configuration**: Wi-Fi, Ethernet, and connectivity optimization for IoT applications
5. **Troubleshooting**: Common issues specific to Orange Pi Zero 2W and Allwinner H618 SoC
6. **Package Management**: Ubuntu-specific package handling with SD card wear considerations

## Hardware Context

- **Device**: Orange Pi Zero 2W
- **SoC**: Allwinner H618 (Quad-core Cortex-A53 @ 1.5GHz)
- **RAM**: 4GB LPDDR4
- **Storage**: 32GB Lexar SD card (limited write cycles)
- **Connectivity**: Dual-band Wi-Fi, Bluetooth 5.0, USB Type-C

**Reference**: Consult [`references/hardware_specs.md`](references/hardware_specs.md) for complete hardware specifications.

## MCP Server Integration

This skill leverages the following MCP servers available in kilocode-cli:

### filesystem
Use for reading system configuration files, logs, and monitoring disk usage patterns. Essential for:
- Checking `/etc/fstab` for mount optimizations
- Analyzing `/var/log` write patterns
- Reviewing systemd service configurations
- Monitoring SD card usage with `df -h` output

### searxng
Use to research:
- Latest Orange Pi Zero 2W firmware updates
- Community solutions for specific hardware issues
- Ubuntu 24.04 ARM-specific optimizations
- Package compatibility for ARM64 architecture

### context7
Use to retrieve up-to-date documentation for:
- Ubuntu 24.04 system administration
- ARM architecture optimization techniques
- Python/Node.js libraries used in automation scripts
- Systemd service configuration

### sequentialthinking
Use for complex troubleshooting workflows that require:
- Multi-step diagnostic procedures
- Root cause analysis of performance issues
- Planning system migrations or major configuration changes
- Analyzing trade-offs between different optimization strategies

## Core Workflows

### 1. Initial System Setup and Optimization

When setting up a new Orange Pi Zero 2W or optimizing an existing system:

1. **Assess Current State**: Use `filesystem` MCP to read `/etc/fstab`, systemd journal configuration, and current mount options
2. **Plan Optimization Strategy**: Review [`references/sd_card_optimization.md`](references/sd_card_optimization.md) for the complete write-reduction strategy
3. **Execute Setup Script**: Run [`scripts/setup_optimization.sh`](scripts/setup_optimization.sh) to apply:
   - Log2Ram installation and configuration
   - `noatime` mount optimizations
   - Zram compressed swap setup
   - Tmpfs for temporary files
   - Journald volatile storage configuration
4. **Verify Configuration**: Check that:
   - Log2Ram is active: `systemctl status log2ram`
   - Zram is configured: `zramctl`
   - Tmpfs mounts are active: `df -h | grep tmpfs`
   - `/etc/fstab` contains `noatime` for root partition
5. **Reboot and Monitor**: After reboot, monitor system for 24-48 hours to ensure stability

**Important Considerations**:
- Always back up `/etc/fstab` before modifications
- Log2Ram uses RAM, so ensure sufficient free memory (aim for 200MB+ free)
- Journald volatile storage means logs are lost on reboot (trade-off for SD card longevity)

### 2. SD Card Health Monitoring

To monitor and minimize SD card wear:

1. **Check Write Patterns**: Use `iotop` or `iostat` to identify processes writing frequently
   ```bash
   sudo iotop -o -b -n 3
   ```
2. **Monitor Smart Data** (if supported): Check SD card SMART attributes
   ```bash
   sudo smartctl -a /dev/mmcblk0
   ```
3. **Analyze Log2Ram Status**: Verify logs are staying in RAM
   ```bash
   df -h | grep log2ram
   systemctl status log2ram
   ```
4. **Identify Heavy Writers**: Look for services repeatedly writing to disk:
   ```bash
   sudo lsof | grep -E "\.log|\.journal" | awk '{print $1}' | sort | uniq -c | sort -nr
   ```
5. **Optimize Problem Services**: If a service writes excessively:
   - Consider disabling non-essential logging
   - Redirect logs to `/dev/null` for chatty services
   - Increase Log2Ram sync interval (if acceptable data loss on crash)

**Write Reduction Best Practices**:
- Avoid frequent `apt update` commands (weekly is sufficient)
- Disable unnecessary systemd timers: `systemctl list-timers`
- Use `tmpfs` for application cache directories when possible
- Consider `overlay` filesystem for read-mostly directories

### 3. Thermal Management and Performance Tuning

The Orange Pi Zero 2W operates fanless, requiring thermal management:

1. **Monitor Temperature**: Check current CPU temperature
   ```bash
   cat /sys/class/thermal/thermal_zone0/temp
   ```
   (Output is in millidegrees Celsius, divide by 1000)

2. **Check CPU Frequency**: Verify current CPU governor and frequency
   ```bash
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
   ```

3. **Adjust CPU Governor**: For different use cases:
   - **Performance**: Maximum frequency, higher heat/power
     ```bash
     echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
     ```
   - **Powersave**: Minimum frequency, cooler operation
     ```bash
     echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
     ```
   - **Ondemand**: Dynamic scaling (recommended for most uses)
     ```bash
     echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
     ```

4. **Limit Maximum Frequency**: If thermal throttling occurs (>70°C sustained):
   ```bash
   echo 1200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
   ```

5. **Add Heatsink**: For consistent heavy loads, physical cooling is recommended

**Temperature Guidelines**:
- **<60°C**: Normal operation
- **60-70°C**: Acceptable under load
- **70-85°C**: Thermal throttling may begin
- **>85°C**: Risk of instability, reduce load or add cooling

### 4. Network Configuration and Optimization

Wi-Fi and network setup for Orange Pi Zero 2W:

1. **Check Network Interfaces**: List available interfaces
   ```bash
   ip link show
   ```

2. **Configure Wi-Fi with Netplan**: Edit `/etc/netplan/*.yaml`
   ```yaml
   network:
     version: 2
     wifis:
       wlan0:
         dhcp4: yes
         access-points:
           "YOUR_SSID":
             password: "YOUR_PASSWORD"
   ```
   Apply with: `sudo netplan apply`

3. **Optimize Wi-Fi Power Management**: Disable power saving for stability
   ```bash
   sudo iw dev wlan0 set power_save off
   ```
   Make persistent in `/etc/network/if-up.d/wifi-power`

4. **Monitor Connection Quality**: Check signal strength and quality
   ```bash
   iwconfig wlan0
   ```

5. **Use Ethernet When Possible**: The expansion board provides Ethernet, which is:
   - More reliable than Wi-Fi
   - Lower latency
   - No power management issues

### 5. Package Management with SD Card Awareness

When installing or updating packages on Ubuntu:

1. **Before Large Updates**: Check available space
   ```bash
   df -h /
   ```
   Ensure at least 1GB free before major upgrades

2. **Clean Package Cache Regularly**: Remove downloaded package files
   ```bash
   sudo apt clean
   sudo apt autoclean
   sudo apt autoremove
   ```

3. **Use Unattended Upgrades Carefully**: Auto-updates generate writes
   - Consider disabling: `sudo systemctl disable unattended-upgrades`
   - Or configure for less frequent updates: edit `/etc/apt/apt.conf.d/50unattended-upgrades`

4. **Prefer Minimal Installations**: Use `--no-install-recommends` flag
   ```bash
   sudo apt install --no-install-recommends <package>
   ```

5. **Batch Updates**: Instead of updating frequently, batch updates weekly
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

### 6. System Monitoring and Diagnostics

Essential monitoring commands for Orange Pi Zero 2W:

1. **System Overview**: Quick system status
   ```bash
   htop  # Interactive process viewer
   free -h  # Memory usage
   df -h  # Disk usage
   uptime  # Load average
   ```

2. **Memory Breakdown**: Understand memory allocation
   ```bash
   cat /proc/meminfo
   free -m  # Show RAM and swap in MB
   ```

3. **Zram Status**: Check compressed swap usage
   ```bash
   zramctl
   cat /proc/swaps
   ```

4. **Log2Ram Status**: Verify log storage location
   ```bash
   df -h | grep log2ram
   journalctl --disk-usage  # Journal size
   ```

5. **Storage I/O**: Monitor SD card read/write activity
   ```bash
   iostat -x 2 5  # 5 samples, 2 seconds apart
   ```

6. **Network Statistics**: Check network performance
   ```bash
   ifconfig  # Or: ip addr
   netstat -i  # Interface statistics
   ```

### 7. Backup and Recovery Strategies

Given SD card reliability concerns:

1. **Critical Configuration Backup**: Regularly backup key files
   ```bash
   sudo tar czf /tmp/system-backup-$(date +%F).tar.gz \
     /etc/fstab \
     /etc/systemd \
     /etc/netplan \
     /etc/apt/sources.list* \
     /home
   ```

2. **SD Card Image Backup**: Create full system image periodically
   - Shutdown the system
   - Remove SD card
   - Create image on another Linux machine:
     ```bash
     sudo dd if=/dev/sdX of=orangepi-backup.img bs=4M status=progress
     ```
   - Compress: `gzip orangepi-backup.img`

3. **Remote Backup**: Use `rsync` to backup to NAS or cloud
   ```bash
   rsync -avz --exclude='/proc/*' --exclude='/sys/*' \
     / user@backup-server:/backups/orangepi/
   ```

4. **Recovery Plan**:
   - Keep a spare SD card with working image
   - Document custom configurations
   - Store scripts in version control (git)

### 8. Troubleshooting Common Issues

#### Issue: System slow or unresponsive

**Diagnosis**:
1. Check memory usage: `free -h`
2. Check swap activity: `vmstat 1 5`
3. Check I/O wait: `iostat -x 2 3`
4. Check temperature: `cat /sys/class/thermal/thermal_zone0/temp`

**Solutions**:
- If memory is low (<200MB free): Reduce running services or add swap
- If I/O wait is high (>10%): Identify heavy writers with `iotop`
- If temperature >70°C: Reduce CPU frequency or add heatsink
- If swap thrashing: Increase zram size or reduce memory usage

#### Issue: Wi-Fi connection unstable

**Diagnosis**:
1. Check signal strength: `iwconfig wlan0`
2. Check for disconnections: `journalctl -u NetworkManager`
3. Check power management: `iw dev wlan0 get power_save`

**Solutions**:
- Disable Wi-Fi power saving (see Network Configuration workflow)
- Move device closer to router or reduce interference
- Try 2.4GHz instead of 5GHz (better range)
- Update firmware: `sudo apt install linux-firmware`

#### Issue: SD card corruption or filesystem errors

**Diagnosis**:
1. Check filesystem: `sudo fsck /dev/mmcblk0p1` (must be unmounted)
2. Check for dmesg errors: `dmesg | grep -i "mmc\|error"`
3. Check SMART data: `sudo smartctl -a /dev/mmcblk0`

**Solutions**:
- If corruption detected: Boot from USB, run `fsck -y /dev/mmcblk0p1`
- If repeated corruption: Replace SD card (likely failing)
- Ensure write optimizations are active (Log2Ram, noatime, etc.)
- Consider using overlay filesystem for rootfs (advanced)

#### Issue: Services failing after reboot

**Diagnosis**:
1. Check failed services: `systemctl --failed`
2. Review logs: `journalctl -xeu <service-name>`
3. Check dependencies: `systemctl list-dependencies <service-name>`

**Solutions**:
- If Log2Ram related: Increase Log2Ram size in `/etc/log2ram.conf`
- If tmpfs related: Increase tmpfs size in `/etc/fstab`
- If timing related: Add `After=` directive to service unit file

### 9. Leveraging Searxng for Research

When encountering unfamiliar issues or needing current information:

1. **Use searxng MCP** to research:
   - "Orange Pi Zero 2W [specific issue]"
   - "Allwinner H618 [configuration need]"
   - "Ubuntu 24.04 ARM [package/optimization]"

2. **Check Official Resources**:
   - Orange Pi Wiki: http://www.orangepi.org/orangepiwiki/
   - Ubuntu ARM documentation
   - Armbian forums (similar hardware, applicable solutions)

3. **Community Solutions**: Many Orange Pi issues have been solved by the community
   - Search for error messages verbatim
   - Look for solutions in GitHub issues
   - Check Reddit r/OrangePI and r/SelfHosted

### 10. Using Context7 for Documentation

When implementing solutions requiring external libraries or tools:

1. **Retrieve Current Documentation**: Use context7 MCP to get up-to-date docs for:
   - Python libraries used in automation scripts
   - Systemd service configuration (systemd documentation)
   - Network configuration tools (netplan, NetworkManager)
   - Monitoring tools (prometheus, grafana for advanced setups)

2. **Version-Specific Information**: Ensure documentation matches Ubuntu 24.04 versions
   - Ubuntu 24.04 ships with systemd 255, Python 3.12, etc.
   - Use context7 to get version-appropriate syntax and options

## Best Practices Summary

1. **Always prioritize SD card longevity**: Every optimization should consider write impact
2. **Monitor before optimizing**: Establish baseline metrics before changes
3. **Test incrementally**: Apply one optimization at a time, verify stability
4. **Document changes**: Keep notes on modifications for troubleshooting
5. **Plan for failure**: SD cards will eventually fail, have backup and recovery strategy
6. **Balance performance vs. longevity**: Don't over-optimize at the cost of usability
7. **Use appropriate tools**: Leverage MCP servers for research and documentation
8. **Stay updated**: Check for kernel and firmware updates periodically (monthly)

## When to Use This Skill

Invoke this skill when the task involves:
- Administering or configuring Orange Pi Zero 2W hardware
- Optimizing Ubuntu 24.04 for ARM architecture or SD card storage
- Troubleshooting performance, thermal, or stability issues on SBCs
- Setting up services or applications on resource-constrained devices
- Planning system modifications that impact SD card writes
- Diagnosing hardware-specific issues with Allwinner H618 SoC
- Implementing IoT or embedded Linux best practices

## Related Skills and Considerations

**Not covered by this skill**:
- Application-specific configurations (use appropriate app-specific skills)
- Advanced networking (VPNs, firewalls, routing) - use networking skills
- Docker/container optimization - use container-specific skills
- Web server optimization - use web server skills

**Complementary skills**:
- Use filesystem MCP extensively for reading configurations
- Use searxng MCP for researching hardware-specific issues
- Use context7 MCP for up-to-date software documentation
- Use sequentialthinking MCP for complex troubleshooting

## References

- [`references/hardware_specs.md`](references/hardware_specs.md): Complete hardware specifications
- [`references/sd_card_optimization.md`](references/sd_card_optimization.md): Detailed write-reduction strategies
- [`references/troubleshooting_guide.md`](references/troubleshooting_guide.md): Comprehensive troubleshooting procedures for common issues
- [`references/monitoring_commands.md`](references/monitoring_commands.md): Quick reference for system monitoring commands
- [`scripts/setup_optimization.sh`](scripts/setup_optimization.sh): Automated setup script for initial optimization
