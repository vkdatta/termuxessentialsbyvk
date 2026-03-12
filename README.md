<div align="center">

<img src="https://img.shields.io/badge/Platform-Termux%20%7C%20Android-3DDC84?style=for-the-badge&logo=android&logoColor=white"/>
<img src="https://img.shields.io/badge/Python-3.8%2B-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white"/>
<img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Install-pip-blue?style=for-the-badge&logo=pypi&logoColor=white"/>

<br/><br/>

# 🐚 bashbasicsbyvk

### **A power-user shell toolkit for Termux — file management, web scraping, and cloud sync, all from a single keystroke.**

<br/>

[📦 Install](#-installation) · [🚀 Usage](#-usage) · [⚙️ Setup Guide](#%EF%B8%8F-setup-guide) · [☁️ Cloud Sync](#%EF%B8%8F-rclone--google-drive-setup) · [🔄 Upgrade](#-upgrade)

</div>

---

## ✨ What's Inside

| Command | Purpose |
|---|---|
| [`o`](#-o--the-omni-file-manager) | 🗂️ Omni file manager — browse, edit, share, move, delete, batch ops & more |
| [`xtract`](#-xtract--web-scraper) | 🕷️ Scrape all HTML tables & hyperlinks from single or paginated URLs |

---

## 🗂️ `o` — The Omni File Manager

> Launch with a single character. Do everything.

```bash
o
```

Drill into **any file or folder** from your shell and act on it instantly. No flags, no paths — just `o`.

<details>
<summary><strong>📋 Supported Operations</strong></summary>

<br/>

| Category | Operations |
|---|---|
| 📁 **Files** | View, Edit, Rename, Move, Delete, Share |
| 🗃️ **Batch** | Multi-select Edit, Batch Delete, Bulk Create |
| 🔍 **Search** | Find files by name, type, or content |
| 🗄️ **Organise** | Sort, Group, Restructure directories |

</details>

---

## 🕷️ `xtract` — Web Scraper

> Harvest the web. One command.

```bash
xtract
```

Scrapes **all** HTML tables and hyperlinks from one or more paginated web pages in a single invocation. Perfect for harvesting catalogues, reports, or any tabular data spread across multiple pages.

<details>
<summary><strong>📋 Usage Patterns</strong></summary>

<br/>

| Intent | Input Format | Example |
|---|---|---|
| Single page | Plain URL | `example.com/article/p.html` |
| Specific page number | URL with page number | `example.com/article/100` |
| Range of pages | URL with `{N}` | `example.com/article/{100}` |

> 💡 **`{100}`** means pages **1 through 100**. Curly braces = range. No braces = exact page.

</details>

---

## ⚙️ Setup Guide

### Step 1 — Prerequisites

Run the following blocks in order inside Termux:

```bash
# Core packages
pkg install termux-api
pkg install python -y
pkg install root-repo
pkg uninstall tur-repo -y
pkg update -y && pkg upgrade -y
pkg install tur-repo -y
pkg install clang libopenblas libffi libzmq build-essential -y
```

```bash
# Build tools
pkg update
pkg install clang make cmake pkg-config
pkg install python-dev ninja libandroid-spawn libffi-dev rclone
```

```bash
# Python dependencies
pip install numpy pandas
pip install requests beautifulsoup4 tqdm openpyxl
```

```bash
# Final essentials
pkg install -y termux-api python git curl
```

---

### Step 2 — Storage Access

> **Required** so Termux can read/write your Android shared storage.

```bash
termux-setup-storage
```

Grant the storage permission when prompted by Android. This creates symlinks under `~/storage/` (e.g. `~/storage/downloads`) and enables Termux to access `/storage/emulated/0/`.

**Allow external app access** (needed for sharing files via Chrome, etc.):

```bash
nano ~/.termux/termux.properties
```

Find or add this line:

```
allow-external-apps = true
```

> Remove the leading `#` if the line exists but is commented out.

Then fully restart Termux:
> **Android Settings → Apps → Termux → Force Stop → Relaunch**

---

## ☁️ Rclone + Google Drive Setup

<details>
<summary><strong>🖥️ Remote Shell (e.g. Google Cloud)</strong></summary>

<br/>

```bash
cd ~
curl -LO https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip -j rclone-current-linux-amd64.zip "*/rclone" -d ~/bin/
chmod 755 ~/bin/rclone
rm rclone-current-linux-amd64.zip

# Add to PATH if not already present
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi
```

</details>

<details>
<summary><strong>📱 Termux (Android)</strong></summary>

<br/>

```bash
pkg install rclone
```

</details>

### Configure Google Drive Remote

```bash
rclone config
```

Follow the interactive prompts:

| Step | Prompt | Value |
|---|---|---|
| 1 | New remote? | `n` |
| 2 | Name | `gdrive` |
| 3 | Storage type | `Google Drive` |
| 4 | Client ID / Secret | *(leave empty)* |
| 5 | Scope | `1` — Full access |
| 6 | Root folder ID | *(leave empty)* |
| 7 | Advanced config? | `n` |
| 8 | Auto config? | `y` |

---

## 📦 Installation

```bash
pip install git+https://github.com/vkdatta/bashbasicsbyvk.git
```

---

## 🔄 Upgrade

> ⚠️ This is a living personal project — all changes go directly to `main`. If a command behaves unexpectedly, force-reinstall to get the latest version.

```bash
pip install -vvv --progress-bar on --upgrade --force-reinstall \
  git+https://github.com/vkdatta/bashbasicsbyvk.git
```

---

## 🧭 Quick Reference

| Command | Example | Description |
|---|---|---|
| `o` | `o` | Launch the omni file manager |
| `xtract` | `xtract` | Launch the web scraper |

---

<div align="center">

Made with 🖤 for the terminal. Built for **Termux power users**.

</div>
