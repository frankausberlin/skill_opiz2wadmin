<font size=-2>
A small note: the skill was completely created by kilocode (sonnet 4.5 / skill: skill-creator) (~ $2).
</font><hr><br>
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
- 64GB+ SD card (SanDisk recommended, but any quality Class 10 or UHS-1 works)
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
git clone https://github.com/frankausberlin/skill_opiz2wadmin
cd skill_opiz2wadmin
```

Or download and extract the ZIP file.

### Step 2: Install the Skill

The skill directory name **must match** the `name` field in `SKILL.md`. Copy the entire skill directory to your Kilo Code skills folder:

**For global access (all projects):**

```bash
# Create skills directory if it doesn't exist
mkdir -p ~/.kilocode/skills

# Copy the entire directory (ensure the directory name matches the skill name)
cp -r . ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/

# Verify installation
ls ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin
```

**For project-specific access:**

```bash
# In your project directory
mkdir -p .kilocode/skills

# Copy the entire directory
cp -r /path/to/skill_opiz2wadmin .kilocode/skills/orangepi-zero-2w-ubuntu-admin/
```

You should see:
```
SKILL.md  README.md  references/  scripts/  assets/
```

⚠️ **Important**: The directory name **must** match the `name` field in the SKILL.md frontmatter (in this case: `orangepi-zero-2w-ubuntu-admin`).

### Step 3: Reload VSCode

Skills are loaded when Kilo Code initializes. After installing the skill:

```
Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows/Linux)
→ "Developer: Reload Window"
```

Or simply restart VSCode.

### Step 4: Verify the Skill is Loaded

Open Kilo Code and ask:

```
Do you have access to the orangepi-zero-2w-ubuntu-admin skill?
```

If the agent confirms it has access, the skill is properly installed. If not, check the Output panel (`View` → `Output` → Select "Kilo Code") for any error messages.

### Step 5: Test the Skill

Try a query that should trigger the skill:

```
How do I optimize my Orange Pi Zero 2W for SD card longevity?
```

The agent should automatically recognize the skill and provide detailed guidance. You'll see it read the `SKILL.md` file in the conversation.

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
- ✅ **Set up Agent Journaling System** (creates `~/labor/agent_journal` and documentation)

**Reboot after running the script** to activate all optimizations.

## 📝 Agent Journaling

To ensure continuity and transparency, all agents using this skill are required to document their activities.

- **Journal Directory**: `~/labor/agent_journal`
- **Instructions**: See [`INSTRUCTION_FOR_AGENT_JOURNAL.md`](INSTRUCTION_FOR_AGENT_JOURNAL.md) for naming conventions and report structure.
- **Purpose**: Allows future agent sessions to quickly understand what was done, why, and how.

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

- [`references/hardware_specs.md`](references/hardware_specs.md): Complete hardware specifications
- [`references/sd_card_optimization.md`](references/sd_card_optimization.md): Detailed write-reduction strategies
- [`references/troubleshooting_guide.md`](references/troubleshooting_guide.md): Comprehensive troubleshooting procedures for common issues
- [`references/monitoring_commands.md`](references/monitoring_commands.md): Quick reference for system monitoring commands

### 🤖 Automation Scripts

- [`scripts/setup_optimization.sh`](scripts/setup_optimization.sh): One-command system optimization

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

### Skill Not Loading

If the skill doesn't activate automatically:

1. **Check the Output panel**: Open `View` → `Output` → Select "Kilo Code" from dropdown. Look for skill-related errors.

2. **Verify frontmatter**: Ensure the `name` in SKILL.md **exactly matches** the directory name:

```bash
# Check your skill's frontmatter
head -5 ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/SKILL.md
```

Should show:
```yaml
---
name: orangepi-zero-2w-ubuntu-admin
description: ...
---
```

3. **Verify file location**: Ensure `SKILL.md` is directly inside the skill directory:

```bash
ls ~/.kilocode/skills/orangepi-zero-2w-ubuntu-admin/SKILL.md
```

4. **Reload VSCode**: Skills are loaded at startup. Use `Cmd+Shift+P` → "Developer: Reload Window"

5. **Ask the agent**: Verify the skill is available:
```
Do you have access to the orangepi-zero-2w-ubuntu-admin skill?
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "missing required 'name' field" | No `name` in frontmatter | Add `name: orangepi-zero-2w-ubuntu-admin` |
| "name doesn't match directory" | Mismatch between frontmatter and folder name | Make `name` match directory name exactly |
| Skill not appearing | Wrong directory structure | Verify path follows `skills/orangepi-zero-2w-ubuntu-admin/SKILL.md` |

### Checking if Skill Was Used

To see if the skill was actually used during a conversation, look for a `read_file` tool call in the chat that targets the `SKILL.md` file. When the agent uses a skill, it reads the full skill file into context—this appears as a file read operation in the conversation.

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

## ⚠️ Disclaimer

**NO WARRANTY OR RESPONSIBILITY**: This skill and all associated scripts, configurations, and documentation are provided "AS IS" without warranty of any kind, express or implied. The author takes no responsibility for any damage, data loss, system instability, or other issues that may arise from using this skill. Use at your own risk.

**By using this skill, you acknowledge that:**
- You are responsible for backing up your data before applying any optimizations
- System modifications can have unintended consequences
- SD card wear reduction strategies involve trade-offs (e.g., log data may be lost on power failure)
- You should test all changes in a non-production environment first
- The author is not liable for any damages or losses

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
