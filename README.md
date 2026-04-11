[English](README.md) | [Español](README.es.md)

<div align="center">

## ownix ❄️ NixOS configs

** Updated: June 3rd,2025

ownix is a simple way of reproducing my configuration on any NixOS system.
This includes the wallpaper, scripts, applications, config files, and more.

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo.png" />

**Inspiration for the Waybar config
[here](https://github.com/justinlime/dotfiles).**

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo-img2.png" />

**Third waybar option**

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo-img3.png" />

</div>

### Cheatsheets and Guides

- Nix Beginner Guide: [English](cheatsheets/nix-beginner-guide.md) |
  [Español](cheatsheets/nix-beginner-guide.es.md)
- Hyprland Customization Guide:
  [English](cheatsheets/hyprland-customization-guide.md) |
  [Español](cheatsheets/hyprland-customization-guide.es.md)

### Please note:

> **This project has a [Wiki](https://zaney.org/wiki/ownix-2.3/). Find out how
> to use ownix here!** **ddubs has put a lot of effort into the
> [FAQ](https://zaney.org/wiki/ownix-2.3/faq) so it should be accurate.
> However, please if you notice that something is wrong with it create an issue
> or reach out to us on Discord.**

#### 🍖 Requirements

- You must be running on NixOS, version 23.11+.
- The `ownix` folder (this repo) is expected to be in your home directory.
- You must have installed NIXOS using **GPT** parition with booting with
  **UEFI**.
- ** 500MB minimum /boot partition required. **
- Systemd-boot is what is supported.
- For GRUB you will have to brave the internet for a how-to. ☺️
- Manually editing your host specific files.
- The host is the specific computer your installing on.

#### 🎹 Pipewire & Notification Menu Controls

- We are using the latest and greatest audio solution for Linux. Not to mention
  you will have media and volume controls in the notification center available
  in the top bar.

#### 🏇 Optimized Workflow & Simple Yet Elegant Neovim

- Using Hyprland for increased elegance, functionality, and efficiency.
- No massive NeoVIM project here. This is my simple, easy to understand, yet
  incredible NeoVIM setup. With language support already added in.

#### 🖥️ Multi Host & User Configuration

- You can define separate settings for different host machines and users.
- Easily specify extra packages for your users in the `modules/core/user.nix`
  file.
- Easy to understand file structure and simple, but encompassing, configuration.

#### 👼 An Incredible Community Focused On Support

- The entire idea of ownix is to make NixOS an approachable space.
- NixOS is actually a great community that you will want to be a part of.
- Many people who are patient and happy to spend their free time helping you are
  running similar NixOS setups.
- Feel free to reach out on the Discord for any help with anything.

<div align="center">

Please do yourself a favor and
[read the wiki](https://zaney.org/wiki/ownix-2.3/).

</div>

#### 📦 How To Install Packages?

- You can search the [Nix Packages](https://search.nixos.org/packages?) &
  [Options](https://search.nixos.org/options?) pages for what a package may be
  named or if it has options available that take care of configuration hurdles
  you may face.
- To add a package there are the sections for it in `modules/core/packages.nix`
  and `modules/core/user.nix`. One is for programs available system wide and the
  other for your users environment only.

#### 🙋 Having Issues / Questions?

- Please feel free to raise an issue on the repo, please label a feature request
  with the title beginning with [feature request], thank you!
- Contact us on [Discord](https://discord.gg/2cRdBs8) as well, for a potentially
  faster response.

- Don't forget to checkout the [FAQ](https://zaney.org/wiki/ownix-2.3/faq)

# Hyprland Keybindings

Below are the keybindings for Hyprland, formatted for easy reference.

## Application Launching

- `$modifier + Return` → Launch `terminal`
- `$modifier + K` → List keybinds
- `$modifier + Shift + Return` → Launch `rofi-launcher`
- `$modifier + Shift + W` → Open `web-search`
- `$modifier + Alt + W` → Open `wallsetter`
- `$modifier + Shift + N` → Run `swaync-client -rs`
- `$modifier + W` → Launch `Web Browser`
- `$modifier + Y` → Open `kitty` with `yazi`
- `$modifier + E` → Open `emopicker9000`
- `$modifier + S` → Take a screenshot
- `$modifier + D` → Open `Discord`
- `$modifier + O` → Launch `OBS Studio`
- `$modifier + C` → Run `hyprpicker -a`
- `$modifier + G` → Open `GIMP`
- `$modifier + V` → Show clipboard history via `cliphist`
- `$modifier + T` → Toggle terminal with `pypr`
- `$modifier + M` → Open `pavucontrol`

## Window Management

- `$modifier + Q` → Kill active window
- `$modifier + P` → Toggle pseudo tiling
- `$modifier + Shift + I` → Toggle split mode
- `$modifier + F` → Toggle fullscreen
- `$modifier + Shift + F` → Toggle floating mode
- `$modifier + Alt + F` → Float all windows
- `$modifier + Shift + C` → Exit Hyprland

## Window Movement

- `$modifier + Shift + ← / → / ↑ / ↓` → Move window left/right/up/down
- `$modifier + Shift + H / L / K / J` → Move window left/right/up/down
- `$modifier + Alt + ← / → / ↑ / ↓` → Swap window left/right/up/down
- `$modifier + Alt + 43 / 46 / 45 / 44` → Swap window left/right/up/down

## Focus Movement

- `$modifier + ← / → / ↑ / ↓` → Move focus left/right/up/down
- `$modifier + H / L / K / J` → Move focus left/right/up/down

## Workspaces

- `$modifier + 1-10` → Switch to workspace 1-10
- `$modifier + Shift + Space` → Move window to special workspace
- `$modifier + Space` → Toggle special workspace
- `$modifier + Shift + 1-10` → Move window to workspace 1-10
- `$modifier + Control + → / ←` → Switch workspace forward/backward

## Window Cycling

- `Alt + Tab` → Cycle to next window
- `Alt + Tab` → Bring active window to top

## Installation:

> **⚠️ IMPORTANT:** These installation methods are for **NEW INSTALLATIONS
> ONLY**. If you already have this setup installed and want to upgrade to v2.4, see
> the [Upgrade Instructions](#upgrading-from-ownix-23-to-24) below. Note: Do
> NOT use upgrade script at this time. It will be restored later.

<details>
<summary><strong> ⬇️ Install with script (NEW INSTALLATIONS ONLY)</strong></summary>

### 📜 Script:

This is the easiest and recommended way of starting out for **new
installations**. The script is not meant to allow you to change every option
that you can in the flake or help you install extra packages. It is simply here
so you can get my configuration installed with as little chances of breakages
and then fiddle to your hearts content!

> **⚠️ WARNING:** This script will completely replace any existing `~/ownix`
> directory. Do NOT use this if you already have ownix installed and
> configured.

Simply copy this and run it:

![ownix First Install Command](img/first-install-cmd.jpg)

```
nix-shell -p git curl pciutils
```

Then:

![ownix Install Script Command](img/install-script.jpg)

```
sh <(curl -L https://github.com/ownvoy/ownix/raw/main/install-ownix.sh)
```

#### The install process will look something like this:

![First Part Of Install](img/1.jpg)

![Second Part Of Install](img/2.jpg)

#### After the install completes your environment will probably look broken. Just reboot and you will see this as your login:

![Display Manager](img/3.jpg)

#### Then after login you should see a screen like this:

![Desktop Example](img/4.jpg)

</details>

<details>
<summary><strong> 🦽 Manual install process:  </strong></summary>

1. Run this command to ensure Git & Vim are installed:

```
nix-shell -p git vim
```

2. Clone this repo & enter it:

```
cd && git clone https://github.com/ownvoy/ownix.git ~/ownix
cd ~/ownix

You can still run the `install.sh` script if you want to.
```

- _You should stay in this folder for the rest of the install_

3. Create the host folder for your machine(s) like so:

```
cp -r hosts/default hosts/<your-desired-hostname>
git add .
```

4. Edit `hosts/<your-desired-hostname>/variables.nix`.

5. Edit `flake.nix` and fill in your username, machine profile, and hostname.

6. Generate your hardware.nix like so:

```
nixos-generate-config --show-hardware-config > hosts/<your-desired-hostname>/hardware.nix
```

7. Run this to enable flakes and install the flake replacing hostname with
   profile. I.e. `intel`, `nvidia` `nvidia-laptop`, or `vm`

```
NIX_CONFIG="experimental-features = nix-command flakes" 
sudo nixos-rebuild switch --flake .#profile
```

Now when you want to rebuild the configuration you have access to an alias
called `fr` that will rebuild the flake and you do not have to be in the
`ownix` folder for it to work.

</details>

## Upgrading from ownix 2.3 to 2.4 -- Do NOT use the upgrade script at this timel.

> **🚀 IMPORTANT:** If you already have ownix 2.3 or an earlier fork installed, use the automated
> upgrade system instead of reinstalling!

### ✅ Automated Upgrade Process:

ownix includes a comprehensive upgrade system that safely migrates your
configuration:

```bash
cd ~/ownix
./upgrade-ownix-2.3-to-2.4.sh
```

### 🔍 What the Upgrade System Does:

1. **Pre-Upgrade Analysis** - Comprehensive scan of your customizations
2. **Complete Backup** - Full backup of your current configuration
3. **Automatic Migration** - Preserves all your settings and customizations
4. **Safe Upgrade** - Uses `boot` option to prevent display manager conflicts
5. **Easy Revert** - One-command rollback if needed

### 📋 What Gets Automatically Migrated:

- ✅ All host configurations and variables
- ✅ Hardware configurations
- ✅ Custom packages (both global and per-host)
- ✅ Themes, wallpapers, and monitor settings
- ✅ Git configuration and personal settings
- ✅ Terminal preferences with automatic enabling

### ⚠️ What Requires Manual Attention:

- Custom flake.nix inputs
- Personal shell configuration files (zshrc-personal.nix, etc.)
- Custom module modifications

### 📚 Complete Documentation:

For detailed upgrade instructions, troubleshooting, and safety information:

- **Read**: `UPGRADE-2.3-to-2.4.md` in your `ownix` directory
- **Analysis Report**: Saved automatically as
  `~/ownix-upgrade-analysis-TIMESTAMP.txt`

### 🔄 Easy Revert:

If anything goes wrong, easily revert to 2.3:

```bash
cd ~/ownix
./upgrade-ownix-2.3-to-2.4.sh --revert
```

---

### Special Recognitions:

Thank you for all your assistance

- Jakookit https://github.com/jakookit
- Justaguylinux https://github.com/drewgrif
- Jerry Starke https://github.com/JerrySM64

## Hope you enjoy!
