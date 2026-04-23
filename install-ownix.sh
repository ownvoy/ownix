#!/usr/bin/env bash

######################################
# Install script for ownix
# Author:  Don Williams 
# Date: June 27, 2005 
#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="$(dirname "$0")"
LOG_FILE="${LOG_DIR}/install_$(date +"%Y-%m-%d_%H-%M-%S").log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# Hostname validation and sanitization helpers
HOSTNAME_REGEX='^[[:alnum:]]([[:alnum:]_-]{0,61}[[:alnum:]])?$'

is_valid_hostname() {
  local hn="$1"
  [[ "$hn" =~ $HOSTNAME_REGEX ]]
}

sanitize_hostname() {
  local hn="$1"
  # Lowercase
  hn=$(printf '%s' "$hn" | tr '[:upper:]' '[:lower:]')
  # Replace invalid chars (including dots/spaces) with '-'
  hn=$(printf '%s' "$hn" | sed -E 's/[^[:alnum:]_-]+/-/g')
  # Collapse consecutive - or _ to a single -
  hn=$(printf '%s' "$hn" | sed -E 's/[-_]{2,}/-/g')
  # Trim leading/trailing non-alnum
  hn=$(printf '%s' "$hn" | sed -E 's/^[^[:alnum:]]+//; s/[^[:alnum:]]+$//')
  # Truncate to 63 characters (hostname label limit)
  hn=${hn:0:63}
  # Ensure start/end are alnum in case truncation left a non-alnum at edges
  hn=$(printf '%s' "$hn" | sed -E 's/^[^[:alnum:]]+//; s/[^[:alnum:]]+$//')
  printf '%s' "$hn"
}

ensure_safe_hostname() {
  # Usage: ensure_safe_hostname <input> <default>
  local input="$1"; local def="$2"
  local candidate="$input"
  if [ -z "$candidate" ]; then candidate="$def"; fi
  local sanitized
  sanitized=$(sanitize_hostname "$candidate")
  if [ -z "$sanitized" ]; then sanitized="$def"; fi
  if ! is_valid_hostname "$sanitized"; then return 1; fi
  printf '%s' "$sanitized"
}

# Function to print a section header
print_header() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ ${1} ${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print an error message
print_error() {
  echo -e "${RED}Error: ${1}${NC}"
}

# Function to print a success banner
print_success_banner() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                 ownix Installation Successful!                       ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║   Please reboot your system for changes to take full effect.          ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print a failure banner
print_failure_banner() {
  echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                 ownix Installation Failed!                           ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║   Please review the log file for details:                             ║${NC}"
  echo -e "${RED}║   ${LOG_FILE}                                                        ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

print_header "Verifying System Requirements"

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed."
  echo -e "Please install git and pciutils are installed, then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

# Check for lspci (pciutils)
if ! command -v lspci &> /dev/null; then
  print_error "pciutils is not installed."
  echo -e "Please install git and pciutils,  then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
  echo -e "${GREEN}Verified this is NixOS.${NC}"
else
  print_error "This is not NixOS or the distribution information is not available."
  exit 1
fi

print_header "Initial Setup"

echo -e "Default options are in brackets []"
echo -e "Just press enter to select the default"
sleep 2

print_header "Ensure In Home Directory"
cd "$HOME" || exit 1
echo -e "${GREEN}Current directory: $(pwd)${NC}"

print_header "Hostname Configuration"

# Critical warning about using "default" as hostname
echo -e "${RED}⚠️  IMPORTANT WARNING: Do NOT use 'default' as your hostname!${NC}"
echo -e "${RED}   The 'default' hostname is a template and will be overwritten during updates.${NC}"
echo -e "${RED}   This will cause you to lose your configuration!${NC}"
echo ""
echo -e "💡 Suggested hostnames: my-desktop, gaming-rig, workstation, nixos-laptop"
read -rp "Enter Your New Hostname: [ my-desktop ] " hostName
if [ -z "$hostName" ]; then
  hostName="my-desktop"
fi

# Double-check if user accidentally entered "default"
if [ "$hostName" = "default" ]; then
  echo -e "${RED}❌ Error: You cannot use 'default' as hostname. Please choose a different name.${NC}"
  read -rp "Enter a different hostname: " hostName
  if [ -z "$hostName" ] || [ "$hostName" = "default" ]; then
    echo -e "${RED}Setting hostname to 'my-desktop' to prevent configuration loss.${NC}"
    hostName="my-desktop"
  fi
fi

# Validate and sanitize hostname to meet NixOS constraints
safeHost=$(ensure_safe_hostname "$hostName" "my-desktop")
if [ "$safeHost" != "$hostName" ]; then
  echo -e "${RED}The hostname '$hostName' is not compliant (letters, numbers, '-', '_' only; 1-63 chars; start/end alnum).${NC}"
  echo -e "It will be adjusted to: ${GREEN}$safeHost${NC}"
  read -p "Use '$safeHost'? (Y/n): " -n 1 -r; echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    read -rp "Enter a hostname (letters, numbers, hyphens/underscores; 1-63 chars): " hostName
    safeHost=$(ensure_safe_hostname "$hostName" "my-desktop")
  fi
fi

if ! is_valid_hostname "$safeHost"; then
  print_error "Hostname '$hostName' is invalid even after sanitization."
  echo "Please rerun and choose a compliant hostname (letters, numbers, hyphens, underscores; 1-63 chars, start/end alphanumeric)."
  exit 1
fi

hostName="$safeHost"
echo -e "${GREEN}✓ Hostname set to: $hostName${NC}"

print_header "GPU Profile Detection"

# Attempt automatic detection
DETECTED_PROFILE=""

has_nvidia=false
has_intel=false
has_amd=false
has_vm=false

if lspci | grep -qi 'vga\|3d'; then
  while read -r line; do
    if echo "$line" | grep -qi 'nvidia'; then
      has_nvidia=true
    elif echo "$line" | grep -qi 'amd'; then
      has_amd=true
    elif echo "$line" | grep -qi 'intel'; then
      has_intel=true
    elif echo "$line" | grep -qi 'virtio\|vmware'; then
      has_vm=true
    fi
  done < <(lspci | grep -i 'vga\|3d')

  if $has_vm; then
    DETECTED_PROFILE="vm"
  elif $has_nvidia && $has_intel; then
    DETECTED_PROFILE="hybrid"
  elif $has_nvidia; then
    DETECTED_PROFILE="nvidia"
  elif $has_amd; then
    DETECTED_PROFILE="amd"
  elif $has_intel; then
    DETECTED_PROFILE="intel"
  fi
fi

# Handle detected profile or fall back to manual input
if [ -n "$DETECTED_PROFILE" ]; then
  profile="$DETECTED_PROFILE"
  echo -e "${GREEN}Detected GPU profile: $profile${NC}"
  read -p "Correct? (Y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}GPU profile not confirmed. Falling back to manual selection.${NC}"
    profile="" # Clear profile to force manual input
  fi
fi

# If profile is still empty (either not detected or not confirmed), prompt manually
if [ -z "$profile" ]; then
  echo -e "${RED}Automatic GPU detection failed or no specific profile found.${NC}"
  read -rp "Enter Your Hardware Profile (GPU)
Options:
[ amd ]
nvidia
nvidia-laptop
intel
vm
Please type out your choice: " profile
  if [ -z "$profile" ]; then
    profile="amd"
  fi
  echo -e "${GREEN}Selected GPU profile: $profile${NC}"
fi

print_header "⚠️  CRITICAL WARNING - Existing ownix Detected"

backupname=$(date +"%Y-%m-%d-%H-%M-%S")
if [ -d "ownix" ]; then
  echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                    ⚠️  IMPORTANT WARNING ⚠️                           ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║  An existing ownix installation was detected at ~/ownix             ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║  This installer will COMPLETELY REPLACE your existing configuration!  ║${NC}"
  echo -e "${RED}║  All customizations, packages, and settings will be LOST!            ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║  If you want to keep an existing ownix checkout:                    ║${NC}"
  echo -e "${RED}║  1. Press Ctrl+C to cancel this installer                            ║${NC}"
  echo -e "${RED}║  2. Back up ~/ownix manually before migrating to this checkout      ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║  This installer performs a fresh install and does not run upgrades.  ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${YELLOW}If you REALLY want to do a fresh installation (losing all customizations):${NC}"
  read -p "Type 'REPLACE' to continue with fresh install or Ctrl+C to cancel: " confirmation
  if [ "$confirmation" != "REPLACE" ]; then
    echo -e "${GREEN}Installation cancelled. Back up your existing checkout and migrate manually.${NC}"
    exit 0
  fi
  echo -e "${GREEN}ownix exists, backing up to .config/ownix-backups folder.${NC}"
  if [ -d ".config/ownix-backups" ]; then
    echo -e "${GREEN}Moving current version of ownix to backups folder.${NC}"
    mv "$HOME"/ownix .config/ownix-backups/"$backupname"
    sleep 1
  else
    echo -e "${GREEN}Creating the backups folder & moving ownix to it.${NC}"
    mkdir -p .config/ownix-backups
    mv "$HOME"/ownix .config/ownix-backups/"$backupname"
    sleep 1
  fi
else
  echo -e "${GREEN}Thank you for choosing ownix.${NC}"
  echo -e "${GREEN}I hope you find your time here enjoyable!${NC}"
fi

print_header "Cloning ownix Repository"
git clone https://github.com/ownvoy/ownix.git --depth=1 ~/ownix
cd ~/ownix || exit 1

print_header "Git Configuration"
echo "👤 Setting up git configuration for version control:"
echo "  This is needed for system updates and configuration management."
echo ""
installusername=$(echo $USER)
echo -e "Current username: ${GREEN}$installusername${NC}"
read -rp "Enter your full name for git commits [ $installusername ]: " gitUsername
if [ -z "$gitUsername" ]; then
  gitUsername="$installusername"
fi

echo "📧 Examples: john@example.com, jane.doe@company.org"
read -rp "Enter your email address for git commits [ $installusername@example.com ]: " gitEmail
if [ -z "$gitEmail" ]; then
  gitEmail="$installusername@example.com"
fi

echo -e "${GREEN}✓ Git name: $gitUsername${NC}"
echo -e "${GREEN}✓ Git email: $gitEmail${NC}"

print_header "Timezone Configuration"
echo "🌎 Common timezones:"
echo "  • US: America/New_York, America/Chicago, America/Denver, America/Los_Angeles"
echo "  • Europe: Europe/London, Europe/Berlin, Europe/Paris, Europe/Rome"
echo "  • Asia: Asia/Tokyo, Asia/Shanghai, Asia/Seoul, Asia/Kolkata"
echo "  • Australia: Australia/Sydney, Australia/Melbourne"
echo "  • UTC (Universal): UTC"
read -rp "Enter your timezone [ America/New_York ]: " timezone
if [ -z "$timezone" ]; then
  timezone="America/New_York"
fi
echo -e "${GREEN}✓ Timezone set to: $timezone${NC}"

print_header "Keyboard Layout Configuration"
echo "🌍 Common keyboard layouts:"
echo "  • us (US English) - default"
echo "  • us-intl (US International)"
echo "  • uk (UK English)"
echo "  • de (German)"
echo "  • fr (French)"
echo "  • es (Spanish)"
echo "  • it (Italian)"
echo "  • ru (Russian)"
echo "  • dvorak (Dvorak)"
read -rp "Enter your keyboard layout: [ us ] " keyboardLayout
if [ -z "$keyboardLayout" ]; then
  keyboardLayout="us"
fi
echo -e "${GREEN}✓ Keyboard layout set to: $keyboardLayout${NC}"

print_header "Console Keymap Configuration"
echo "⌨️  Console keymap (usually matches your keyboard layout):"
echo "  Most common: us, uk, de, fr, es, it, ru"
# Smart default: use keyboard layout as console keymap default if it's a common one
defaultConsoleKeyMap="$keyboardLayout"
if [[ ! "$keyboardLayout" =~ ^(us|uk|de|fr|es|it|ru|us-intl|dvorak)$ ]]; then
  defaultConsoleKeyMap="us"
fi
read -rp "Enter your console keymap: [ $defaultConsoleKeyMap ] " consoleKeyMap
if [ -z "$consoleKeyMap" ]; then
  consoleKeyMap="$defaultConsoleKeyMap"
fi
echo -e "${GREEN}✓ Console keymap set to: $consoleKeyMap${NC}"

print_header "Configuring Host and Profile"
mkdir -p hosts/"$hostName"
cp hosts/default/*.nix hosts/"$hostName"

git config --global user.name "$gitUsername"
git config --global user.email "$gitEmail"
git add .
git config --global --unset-all user.name
git config --global --unset-all user.email

echo "Updating configuration files with working awk commands..."

# Update flake.nix for the current multi-machine layout
cp ./flake.nix ./flake.nix.bak
awk \
  -v host="$hostName" \
  -v profile="$profile" \
  '
    BEGIN {
      inMachines = 0;
      inHost = 0;
      hostFound = 0;
      profileUpdated = 0;
    }
    /^[[:space:]]*machines[[:space:]]*=[[:space:]]*\{/ {
      inMachines = 1;
      print;
      next;
    }
    inMachines && $0 ~ "^[[:space:]]*" host "[[:space:]]*=[[:space:]]*\\{" {
      inHost = 1;
      hostFound = 1;
      print;
      next;
    }
    inHost && /^[[:space:]]*profile[[:space:]]*=/ {
      print "          profile = \"" profile "\";";
      profileUpdated = 1;
      next;
    }
    inHost && /^[[:space:]]*\};/ {
      if (!profileUpdated) {
        print "          profile = \"" profile "\";";
      }
      inHost = 0;
      profileUpdated = 0;
      print;
      next;
    }
    inMachines && !hostFound && /^[[:space:]]*\};/ {
      print "        " host " = {";
      print "          profile = \"" profile "\";";
      print "        };";
      hostFound = 1;
      print;
      inMachines = 0;
      next;
    }
    { print; }
  ' ./flake.nix.bak > ./flake.nix
cp ./flake.nix ./flake.nix.bak
awk -v newuser="$installusername" '/^      username = / { gsub(/"[^"]*"/, "\"" newuser "\""); } { print }' ./flake.nix.bak > ./flake.nix
rm ./flake.nix.bak

# Update timezone in system.nix  
cp ./modules/core/system.nix ./modules/core/system.nix.bak
awk -v newtz="$timezone" '/^  time\.timeZone = / { gsub(/"[^"]*"/, "\"" newtz "\""); } { print }' ./modules/core/system.nix.bak > ./modules/core/system.nix
rm ./modules/core/system.nix.bak

# Update variables in host file
cp ./hosts/$hostName/variables.nix ./hosts/$hostName/variables.nix.bak
awk -v newuser="$gitUsername" '/^  gitUsername = / { gsub(/"[^"]*"/, "\"" newuser "\""); } { print }' ./hosts/$hostName/variables.nix.bak > ./hosts/$hostName/variables.nix
cp ./hosts/$hostName/variables.nix ./hosts/$hostName/variables.nix.bak
awk -v newemail="$gitEmail" '/^  gitEmail = / { gsub(/"[^"]*"/, "\"" newemail "\""); } { print }' ./hosts/$hostName/variables.nix.bak > ./hosts/$hostName/variables.nix
cp ./hosts/$hostName/variables.nix ./hosts/$hostName/variables.nix.bak
awk -v newkb="$keyboardLayout" '/^  keyboardLayout = / { gsub(/"[^"]*"/, "\"" newkb "\""); } { print }' ./hosts/$hostName/variables.nix.bak > ./hosts/$hostName/variables.nix
cp ./hosts/$hostName/variables.nix ./hosts/$hostName/variables.nix.bak
awk -v newckm="$consoleKeyMap" '/^  consoleKeyMap = / { gsub(/"[^"]*"/, "\"" newckm "\""); } { print }' ./hosts/$hostName/variables.nix.bak > ./hosts/$hostName/variables.nix
rm ./hosts/$hostName/variables.nix.bak

echo "Configuration files updated successfully!"

print_header "Generating Hardware Configuration -- Ignore ERROR: cannot access /bin"
sudo nixos-generate-config --show-hardware-config > ./hosts/$hostName/hardware.nix

print_header "Setting Nix Configuration"
NIX_CONFIG="experimental-features = nix-command flakes"

print_header "Initiating NixOS Build"
read -p "Ready to run initial build? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Build cancelled.${NC}"
    exit 1
fi

sudo nixos-rebuild boot --flake ~/ownix#${hostName}

# Check the exit status of the last command (nixos-rebuild)
if [ $? -eq 0 ]; then
  print_success_banner
else
  print_failure_banner
fi
