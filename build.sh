#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"

# =============================================
# Configuration
# =============================================
GCT="sd_base/vBrawl/GCTRealMate.exe"
ENTER="sd_base/vBrawl/enter.txt"

echo
echo "+==================================================+"
echo "|                  vBrawl Builder                  |"
echo "+==================================================+"
echo

# Check GCTRealMate
if [[ ! -e "$GCT" ]]; then
    echo "[ERROR] GCTRealMate.exe not found!" >&2
    echo "        Expected in: $GCT" >&2
    exit 1
fi

echo
echo "================================"
echo "[1/4] Building RSBE01..."
echo "================================"
"$GCT" "sd_base/vBrawl/RSBE01.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[2/4] Building BOOST..."
echo "================================"
"$GCT" "sd_base/vBrawl/BOOST.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[3/4] Building NETPLAY..."
echo "================================"
"$GCT" "sd_base/vBrawl/NETPLAY.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[4/4] Building NETBOOST..."
echo "================================"
"$GCT" "sd_base/vBrawl/NETBOOST.txt" < "$ENTER"
echo

# VDS Sync
if [[ -e "tools/VSDsync/VSDSync.exe" ]]; then
    echo "Syncing with VDS Sync..."
    "tools/VSDsync/VSDSync.exe" < "$ENTER"
    echo
    echo "Complete!"
else
    echo "[WARNING] VDS Sync not found - skipping."
fi

echo
echo "+==================================================+"
echo "|            ALL DONE!                             |"
echo "+==================================================+"
echo
