<div align="center">
  <img src="https://localai.io/assets/localai.png" alt="LocalAI Logo" width="150" />

  <h1>🚀 LocalAI on NixOS</h1>

  <p>
    <strong>A complete guide to building and running <a href="https://localai.io/">LocalAI</a> natively on NixOS using Flakes—no Docker required!</strong>
  </p>

  <!-- Badges -->
  <p>
    <a href="https://nixos.wiki/wiki/Flakes"><img src="https://img.shields.io/badge/Nix-Flakes_Enabled-blue.svg?logo=NixOS&logoColor=white" alt="Nix Flakes"></a>
    <a href="https://github.com/Azteczek/LocalAI-On-NixOS/releases"><img src="https://img.shields.io/github/v/release/Azteczek/LocalAI-On-NixOS?color=success&label=Release" alt="Release"></a>
    <a href="#"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License"></a>
  </p>
</div>

---

Welcome to the **LocalAI-On-NixOS** repository! This project provides a reproducible `flake.nix` configuration to compile and run [LocalAI](https://github.com/mudler/LocalAI) locally on a NixOS system. By ditching the heavy Docker setup, you get a clean, native Go binary perfectly integrated into your Nix ecosystem.

## 📑 Table of Contents

- [Requirements](#-requirements)
- [Installation Guide](#-installation-guide)
- [Configuration & Usage](#-configuration--usage)
- [Desktop Integration](#-desktop-integration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🛠 Requirements

You need to have **Nix** with **Flakes** enabled on your system to use this repository. 
If you haven't enabled them yet or don't know how, please follow the official tutorial:
**[Tutorial: How to install Nix and enable Flakes](https://nixos.wiki/wiki/Flakes)**

*Note: You do NOT need to install Go, Protoc, or CMake manually. Nix will handle all build dependencies for you!*

---

## 💻 Installation Guide

Follow these steps to compile LocalAI on your machine.

**1. Clone the repository**
```bash
git clone https://github.com/Azteczek/LocalAI-On-NixOS.git
cd LocalAI-On-NixOS
```

**2. Build the Package**
Run the following Nix command to build the LocalAI binary. This will fetch all dependencies and compile the project (it may take a few minutes the first time).
```bash
nix build
```

Once the build is complete, a `result` symlink will appear in your project root containing the compiled binary at `result/bin/localai`.

---

## ⚙️ Configuration & Usage

To use LocalAI, you need a directory to store your models (e.g., GGUF, GGML). 

**1. Create a models directory**
```bash
mkdir -p ~/localai/models
```
*Note: Download your preferred AI models to this folder.*

**2. Run LocalAI**
You can use the provided `run.sh` script to quickly start the server. 
```bash
# Ensure the script is executable
chmod +x run.sh

# Run the server
./run.sh
```
*(The script binds LocalAI to `127.0.0.1:8080` and looks for models in `/home/krystian/localai/models`. Open it in an editor to adjust the paths to match your username/setup!)*

---

## 🖥 Desktop Integration

Want to launch LocalAI quickly from your application launcher (like Rofi or application menu)? 

If you run the `.desktop` file without specifying a working directory, LocalAI will create its default folders (`models`, `data`, `backends`, `configuration`) directly inside `~/.local/share/applications/`. To prevent this, ensure your `Exec` command changes into a dedicated directory first!

1. Create or edit `localai.desktop` in your applications directory:
```bash
nano ~/.local/share/applications/localai.desktop
```
2. Paste the following configuration. Be sure to replace `/path/to/your/result/bin/localai` with the actual path to your compiled binary:
```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=LocalAI
Comment=Uruchom lokalne modele AI
# Notice the `mkdir` and `cd` commands! This prevents folders from leaking into your applications dir.
Exec=sh -c "mkdir -p $HOME/localai && cd $HOME/localai && /path/to/your/result/bin/localai run --address 127.0.0.1:8080 --models $HOME/localai/models & sleep 2 && xdg-open http://127.0.0.1:8080"
Terminal=false
Icon=cpu
Categories=Development;Network;ArtificialIntelligence;
```
3. Update the desktop database to make it appear in your launcher (optional):
```bash
update-desktop-database ~/.local/share/applications/
```
Now you can search for **LocalAI** in your launcher to start the server safely and open the Web UI instantly!

---

## ⚠️ Troubleshooting

Here are some common problems you might encounter and how to fix them.

### 1. `EADDRINUSE: address already in use`
**Cause**: Another process is already running on port `8080`.
**Fix**: Open `run.sh` and change `--address 127.0.0.1:8080` to an open port like `8081`. 

### 2. Missing Models / Model not found
**Cause**: The `--models` path in `run.sh` doesn't point to the correct folder, or the download failed.
**Fix**: Edit `run.sh` and change `/home/krystian/localai/models` to exactly match where your downloaded models live (`/home/username/...`).

### 3. Hash Mismatches During `nix build`
**Cause**: If the `sources` code updates, the `vendorHash` in the flake might be outdated.
**Fix**: Edit `flake.nix`, change `vendorHash` to an empty string (`""`), run `nix build`, copy the "got" hash from the error message, and paste it back as the new `vendorHash`.

---

## 🤝 Contributing

This is a very open project—feel free to use it, fork it, modify it, or do anything you want with it! 

If you happen to find a bug or want to make it better (e.g., updating the Nix `vendorHash` for a newer LocalAI version), pull requests are always welcome.

1. Fork it
2. Make your changes
3. Open a PR against `master`

---

<div align="center">
  <p>Maintained by <a href="https://github.com/Azteczek">Azteczek</a></p>
</div>
