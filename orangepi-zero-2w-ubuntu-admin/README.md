# 🍊 Orange Pi Zero 2W Ubuntu Administration & Optimization Skill

A comprehensive skill for [kilocode-cli](https://github.com/kilocode/kilocode-cli) that provides specialized administration, optimization, and troubleshooting capabilities for **Orange Pi Zero 2W** running **Ubuntu 24.04**.

## 🎯 What This Skill Does

This skill transforms your kilocode-cli agent into an **Orange Pi Zero 2W expert** with deep knowledge of:

- 💾 **SD Card Longevity**: Write-reduction strategies to extend the lifespan of your SD card
- ⚡ **Performance Optimization**: Memory management, swap configuration, and ARM-specific tuning
- 🌡️ **Thermal Management**: CPU frequency scaling and temperature monitoring for fanless operation
- 🌐 **Network Configuration**: Wi-Fi, Ethernet, and connectivity optimization
- 🔧 **System Troubleshooting**: Hardware-specific diagnostics and solutions
- 📦 **Package Management**: SD card-aware Ubuntu package handling

### Why You Need This Skill

The Orange Pi Zero 2W is a powerful yet resource-constrained ARM single-board computer. Unlike traditional servers, it requires special care:

- **Limited Storage**: SD cards have finite write cycles and can fail prematurely
- **ARM Architecture**: Different optimization strategies than x86/x64 systems
- **Fanless Design**: Requires thermal awareness and CPU frequency management
- **IoT Use Cases**: Often deployed in remote or embedded scenarios where reliability is critical

This skill provides the **accumulated knowledge and best practices** to keep your Orange Pi Zero 2W running reliably for years.

## 📋 Prerequisites

Before installing this skill, ensure you have the following:

### 1. 🖥️ Orange Pi Zero 2W Hardware

- Orange Pi Zero 2W with 4GB RAM
- 32GB+ SD card (Lexar recommended, but any quality Class 10 or UHS-1 works)
- Ubuntu 24.04 LTS installed ([Download from Orange Pi](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-Zero-2W.html))
- Power supply (5V/2A minimum, 5V/3A recommended)
- Network connectivity (Wi-Fi or Ethernet via expansion board)

### 2. 🤖 kilocode-cli Installation

kilocode-cli is an AI-powered command-line agent that uses Claude with MCP support.

**Install kilocode-cli:**

```bash
# Install via npm (requires Node.js 18+)
npm install -g @kilocode/cli

# Or install via pip (requires Python 3.8+)
pip install kilocode-cli

# Verify installation
kilocode --version
```

For detailed installation instructions, see the [kilocode-cli documentation](https://github.com/kilocode/kilocode-cli).

### 3. 🔌 MCP Servers Installation

This skill leverages four MCP (Model Context Protocol) servers to extend the agent's capabilities. Configure them in your kilocode-cli MCP settings.

#### MCP Configuration File

Create or edit `~/.kilocode/mcp_settings.json`:

```json
{
    "mcpServers": {
        "searxng": {
            "command": "uvx",
            "args": ["mcp-searxng"],
            "env": {"SEARXNG_URL": "http://localhost:8088"}
        },
        "context7": {
            "command": "npx",
            "args": ["-y", "@upstash/context7-mcp"],
            "env": {"DEFAULT_MINIMUM_TOKENS": ""}
        },
        "sequentialthinking": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
        },
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"]
        }
    }
}
```

#### 🔍 searxng - Privacy-Respecting Web Search

**What it does**: Provides web search capabilities to research Orange Pi issues, find documentation, and discover community solutions.

**Why you need it**: Orange Pi Zero 2W has hardware-specific quirks that require researching wiki pages, forums, and GitHub issues.

**Installation**:
```bash
# Install uvx (Python package runner)
pip install uvx

# searxng MCP will auto-install when first used by kilocode-cli
# Optional: Run local SearXNG instance for better privacy
docker run -d -p 8088:8080 searxng/searxng
```

**Use cases**:
- Finding solutions to hardware-specific errors
- Researching Ubuntu 24.04 ARM package compatibility
- Discovering community optimizations and tweaks

---

#### 📚 context7 - Up-to-Date Documentation

**What it does**: Retrieves current, version-specific documentation and code examples for libraries and frameworks.

**Why you need it**: Ensures you get Ubuntu 24.04-compatible configuration syntax and recent API changes.

**Installation**:
```bash
# Requires Node.js 18+ (npx comes with Node.js)
# context7 MCP will auto-install when first used by kilocode-cli
```

**Use cases**:
- Getting systemd 255 configuration examples (Ubuntu 24.04 version)
- Python 3.12 library documentation
- Current netplan syntax and options
- Up-to-date kernel module parameters

---

#### 🧠 sequentialthinking - Complex Problem Solving

**What it does**: Enables step-by-step reasoning for complex troubleshooting and multi-step procedures.

**Why you need it**: Diagnosing system issues requires methodical analysis, hypothesis testing, and iterative refinement.

**Installation**:
```bash
# Requires Node.js 18+ (npx comes with Node.js)
# sequentialthinking MCP will auto-install when first used by kilocode-cli
```

**Use cases**:
- Root cause analysis of performance degradation
- Planning system migrations or major configuration changes
- Analyzing trade-offs between optimization strategies
- Multi-step diagnostic procedures

---

#### 📁 filesystem - File System Access

**What it does**: Allows the agent to read, write, and navigate the file system.

**Why you need it**: Essential for reading configuration files, analyzing logs, and implementing system changes.

**Installation**:
```bash
# Requires Node.js 18+ (npx comes with Node.js)
# filesystem MCP will auto-install when first used by kilocode-cli
```

**Security Note**: The configuration above grants access to `/` (root). Restrict to specific directories if needed:
```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/etc", "/var/log", "/home"]
```

**Use cases**:
- Reading `/etc/fstab` for mount optimization
- Analyzing `/var/log` for errors
- Modifying systemd service files
- Checking disk usage patterns

---

## 🚀 Installation

### Step 1: Download the Skill

```bash
# Clone or download this repository
git clone https://github.com/yourusername/orangepi-zero-2w-ubuntu-admin.git
cd orangepi-zero-2w-ubuntu-admin
```

Or download and extract the ZIP file.

### Step 2: Install the Skill

Copy the skill to your kilocode-cli skills directory:

```bash
# Create skills directory if it doesn't exist
mkdir -p ~/.kilocode/skills

# Copy the skill (ensure you're in the skill directory)
cp -r orangepi-zero-2w-ubuntu-admin ~/.kilocode/skills/

# Verify installation
ls ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin
```

You should see:
```
SKILL.md  README.md  references/  scripts/  assets/
```

### Step 3: Verify MCP Servers

Test that MCP servers are accessible:

```bash
# Start kilocode-cli
kilocode

# In the kilocode-cli prompt, check MCP servers:
> /mcp list
```

You should see `searxng`, `context7`, `sequentialthinking`, and `filesystem` listed.

### Step 4: Test the Skill

In kilocode-cli, try invoking the skill:

```bash
> How do I optimize my Orange Pi Zero 2W for SD card longevity?
```

The agent should automatically recognize the skill and provide detailed guidance.

## 📖 Usage

Once installed, the skill activates automatically when you ask questions about:

- Orange Pi Zero 2W administration
- Ubuntu 24.04 ARM optimization
- SD card write reduction
- System performance tuning
- Thermal management
- Network configuration
- Troubleshooting hardware-specific issues

### Example Queries

```bash
# SD Card Optimization
> Help me set up write reduction on my Orange Pi Zero 2W

# Performance Tuning  
> My Orange Pi is running hot, how do I reduce CPU temperature?

# Network Configuration
> Configure Wi-Fi on my Orange Pi Zero 2W with static IP

# Troubleshooting
> My Orange Pi is slow and unresponsive, how do I diagnose the issue?

# System Monitoring
> Show me how to monitor SD card write activity

# Package Management
> What's the best way to update packages without wearing out my SD card?
```

## 🛠️ Quick Start: Optimize Your System

For first-time setup, run the included optimization script:

```bash
# On your Orange Pi Zero 2W, run:
cd ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin
sudo bash scripts/setup_optimization.sh
```

This script will:
- ✅ Install Log2Ram (moves logs to RAM)
- ✅ Configure Zram (compressed swap in RAM)
- ✅ Set up Tmpfs (RAM-based `/tmp`)
- ✅ Optimize `/etc/fstab` with `noatime`
- ✅ Configure systemd journal for volatile storage

**Reboot after running the script** to activate all optimizations.

## 📚 Key Features

### 🔧 Comprehensive Workflows

The skill provides step-by-step guidance for:

1. **Initial System Setup** - Complete optimization from fresh install
2. **SD Card Health Monitoring** - Track and minimize wear
3. **Thermal Management** - CPU governor tuning and temperature control
4. **Network Configuration** - Wi-Fi, Ethernet, power management
5. **Package Management** - SD card-aware apt usage
6. **System Monitoring** - Essential diagnostic commands
7. **Backup and Recovery** - Strategies for system resilience
8. **Troubleshooting** - Common issues and solutions

### 📖 Reference Documentation

- [`references/hardware_specs.md`](orangepi-zero-2w-ubuntu-admin/references/hardware_specs.md): Complete hardware specifications
- [`references/sd_card_optimization.md`](orangepi-zero-2w-ubuntu-admin/references/sd_card_optimization.md): Detailed write-reduction strategies
- [`references/troubleshooting_guide.md`](orangepi-zero-2w-ubuntu-admin/references/troubleshooting_guide.md): Comprehensive troubleshooting procedures for common issues
- [`references/monitoring_commands.md`](orangepi-zero-2w-ubuntu-admin/references/monitoring_commands.md): Quick reference for system monitoring commands

### 🤖 Automation Scripts

- [`scripts/setup_optimization.sh`](orangepi-zero-2w-ubuntu-admin/scripts/setup_optimization.sh): One-command system optimization

## 🎓 Understanding the Optimizations

### Why These Optimizations Matter

SD cards use **NAND flash memory** with limited write cycles (typically 10,000-100,000 writes per cell). Without optimization:

- **System logs**: Constant writes to `/var/log` (every few seconds)
- **Package manager**: Frequent database updates
- **File access times**: Updates on every file read
- **Swap usage**: Random writes can quickly wear out cells

With proper optimization, you can **extend SD card life from months to years**.

### The Write-Reduction Strategy

1. **Log2Ram** 📝: Keeps logs in RAM, syncs to SD card periodically (reduces 90% of writes)
2. **noatime mount option** ⏱️: Prevents updating file access times (eliminates read-triggered writes)
3. **Zram** 🗜️: Compressed swap in RAM (avoids SD card swap entirely)
4. **Tmpfs** 💾: Temporary files in RAM (never touch SD card)
5. **Volatile journald** 📰: System journal in RAM (logs lost on reboot, but SD card survives)

**Trade-off**: Some logs are lost on unexpected power loss, but the system gains massive reliability.

## 🔍 Troubleshooting

### Skill Not Activating

If the skill doesn't activate automatically:

```bash
# Verify skill installation
ls ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/SKILL.md

# Check skill metadata
head -20 ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/SKILL.md
```

Ensure the YAML frontmatter has correct `name` and `description` fields.

### MCP Servers Not Working

```bash
# Check MCP configuration
cat ~/.kilocode/mcp_settings.json

# Verify Node.js installation (required for npx)
node --version  # Should be 18+

# Verify Python/uvx (required for searxng)
python3 --version
uvx --version
```

### Script Execution Issues

```bash
# Ensure script is executable
chmod +x ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/scripts/setup_optimization.sh

# Run with explicit bash
bash ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/scripts/setup_optimization.sh
```

## 🤝 Contributing

Improvements and additional reference material are welcome! Please submit pull requests or open issues.

## 📜 License

This skill is provided under the MIT License. See [`LICENSE`](LICENSE) for details.

## 🌟 Acknowledgments

- Orange Pi community for hardware documentation
- Ubuntu ARM maintainers
- Log2Ram, Zram, and tmpfs developers
- kilocode-cli and MCP protocol developers

## 📞 Support

For issues specific to:
- **This skill**: Open an issue in this repository
- **Orange Pi hardware**: Visit [Orange Pi forums](http://www.orangepi.org/orangepibbsen/)
- **Ubuntu 24.04**: Check [Ubuntu ARM documentation](https://wiki.ubuntu.com/ARM)
- **kilocode-cli**: See [kilocode-cli support](https://github.com/kilocode/kilocode-cli/issues)

---

**Happy administering! May your Orange Pi Zero 2W run forever! 🍊🚀**
