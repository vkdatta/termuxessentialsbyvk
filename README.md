## termuxessentialsbyvk

A lightweight tool for Termux that lets you:  

- **`copy <filename>`**  

  Copy a file’s contents to your system clipboard.

- **`erase <filename>`**  

  Completely wipe out a file’s contents, leaving an empty file behind.

- **`delete <path> or <filename>`**  

  Remove a single file or directory (recursively) with a single command.

- **`overwrite <filename>`**  

  Replace a file’s entire contents with whatever is currently in your clipboard.

- **`create <path> or <filename>`**  

  Create a single file **or** directory in one go.  

- **`open`** (or simply: **`o`**)  

  The “omni-tool” we all hoped for would have made things much easier. It lets you drill into any file or folder and choose from options like view, edit, share, move, rename, delete, and more. It also supports batch editing, deleting, and creating. You can change directories and do anything you’ve ever wished for to make the Termux environment far more powerful.

 
- **`xtract`**  

  Scrape **all** HTML tables and hyperlinks from one or more paginated web pages in a single invocation. Perfect for harvesting catalogues, reports, or any tabular data spread across multiple pages.
  
## Pre Requirements

```bash
pkg install termux-api
pkg install python -y
pkg install root-repo
pkg uninstall tur-repo -y
pkg update -y
pkg upgrade -y
pkg install tur-repo -y
pkg install clang libopenblas libffi libzmq build-essential -y
```
```bash
pkg update
pkg install clang make cmake pkg-config
pkg install python-dev
pkg install ninja
pkg install libandroid-spawn
pkg install libffi-dev
pkg install rclone
```
```bash
pip install numpy
```
```bash
pip install pandas
```
```bash
pkg install -y termux-api python git curl
```
```bash
pip install requests pandas beautifulsoup4 tqdm 
```
```bash
pip install openpyxl 
```

## Storage Setup

Enable Storage Access in Termux. In Termux, execute: 

```bash
termux-setup-storage
```

Grant the requested storage permission when prompted by Android. This creates symlinks in ~/storage/ for shared directories like Downloads and ensures Termux can read from /storage/emulated/0/.

Configure Termux to Allow External App Access:

In Termux, edit the configuration file: 

```bash
nano ~/.termux/termux.properties
```

Locate or add the line: ```allow-external-apps = true``` (uncomment it if present by removing the #). Save and exit the editor. Restart the Termux app completely (force-stop it via Android Settings > Apps > Termux > Force Stop, then relaunch). This enables the content provider (com.termux.files) to grant read access to URIs for apps like Chrome.


## Rclone Config

```bash
rclone config
```
Create a New Google Drive Remote

1. Select **n** → New remote  
2. **Name**: `gdrive`  
3. **Storage**: Choose **Google Drive**  
4. **Client ID / Secret**: Leave empty  
5. **Scope**: `1` (Full access)  
6. **Root folder**: Leave empty  
7. **Advanced config**: `n`  
8. **Auto config**: `y`


## Installation

```bash
pip install git+https://github.com/vkdatta/termuxessentialsbyvk.git
```

## Upgrade

If the commands are not working as intended, there might be a possible update in this code. As this is a tiny personal project, no upgrades are directly provided, and all changes are made to the main version itself. So force install the code for better performance. 

```bash
pip install --upgrade --force-reinstall git+https://github.com/vkdatta/termuxessentialsbyvk.git
```
## Usage

| Command                       | Example                                         | What It Does                                                                                 |
| ----------------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `copy <filename>`             | `copy xyz.py`                                   | Copy the entire contents of `xyz.py` into your clipboard.                                   |
| `erase <filename>`            | `erase notes.txt`                               | Wipe out **all** content of `notes.txt`, leaving it empty.                                  |
| `overwrite <filename>`        | `overwrite draft.md`                            | Replace the contents of `draft.md` with whatever is in your clipboard.                      |
| `delete <filename> or <path>`               | `delete old_project`                            | Remove the file or directory (and its contents) named `old_project`.                         |
| `create <filename> or <path>`    | `create notes.txt`               | Create a file named `notes.txt`                             |
| `open` (alias: `o`)           | `open` or just `o`                              | Launch the “omni-tool” to view, edit, rename, move, delete, etc.       |
| `xtract`     | `xtract`   | Scrape **all** HTML tables & links from the specified pages or ranges across one or more sites. |

---

> __**Tips for `xtract`**__  

>  Enter: `example.com/article/p.html` to extract tables/links from that URL only  

>  Enter: `example.com/article/100` [if the same URL has multiple pages] to extract tables/links from the 100th page only.

>  Enter: `example.com/article/{100}` [if the same URL has multiple pages] to extract tables/links from 1st page to 100th page [Observe flower brackets]
