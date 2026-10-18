#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"

# =============================================
# Configuration
# =============================================
GCT="sd_base/vBrawl/GCTRealMate.exe"
ENTER="sd_base/vBrawl/enter.txt"

BUILDER_DIR="Code Menu Builder"
BUILDER_EXE="PowerPC Assembly Functions - Offline.exe"
BUILDER_EXE_NET="PowerPC Assembly Functions - Netplay.exe"
CM_OUTPUT="$BUILDER_DIR/Code_Menu_Output"
CM_ADDONS_SRC="$CM_OUTPUT/CM_Addons"

# Both menus go to pf/menu3 and Source/CodeMenu. Like P+Ex, only the offline
# build's CM_Addons is deployed; both CodeMenu.asm and Net-CodeMenu.asm include it.
CM_CMNU_DST_DIR="sd_base/vBrawl/pf/menu3"
CM_ASM_DST_DIR="sd_base/vBrawl/Source/CodeMenu"
CM_ADDONS_DST="sd_base/vBrawl/Source/CM_Addons"

echo
echo "+==================================================+"
echo "|                  vBrawl Builder                  |"
echo "+==================================================+"
echo

# Check GCTRealMate and both builders
if [[ ! -e "$GCT" ]]; then
    echo "[ERROR] GCTRealMate.exe not found!" >&2
    echo "        Expected in: $GCT" >&2
    exit 1
fi
for exe in "$BUILDER_EXE" "$BUILDER_EXE_NET"; do
    if [[ ! -e "$BUILDER_DIR/$exe" ]]; then
        echo "[ERROR] $exe not found in $BUILDER_DIR!" >&2
        exit 1
    fi
done

# run_builder <exe name> <cmnu name>
# The builder blocks on _getch "Press any key", which ignores redirected stdin.
# Delete its old .cmnu, start it, poll until the new .cmnu appears, then kill it.
run_builder() {
    local exe="$1" cmnu="$CM_OUTPUT/$2" tries=0
    rm -f "$cmnu"
    ( cd "$BUILDER_DIR" && "./$exe" ) &
    while (( tries < 240 )); do
        if [[ -e "$cmnu" ]]; then
            sleep 1
            taskkill //F //IM "$exe" >/dev/null 2>&1
            wait 2>/dev/null
            return 0
        fi
        sleep 0.5
        (( tries++ ))
    done
    echo "  [WARNING] Builder did not produce $2 within 120 s, terminating."
    taskkill //F //IM "$exe" >/dev/null 2>&1
    wait 2>/dev/null
    return 1
}

# copy_file <file name in Code_Menu_Output> <destination dir>
copy_file() {
    if [[ -e "$CM_OUTPUT/$1" ]]; then
        cp -f "$CM_OUTPUT/$1" "$2/$1"
        echo "  Replaced $1"
    else
        echo "  [ERROR] $CM_OUTPUT/$1 not found!"
    fi
}

echo
echo "==========================================="
echo "[1/7] Running Code Menu Builder (Offline)..."
echo "==========================================="
run_builder "$BUILDER_EXE" "data.cmnu"
echo
echo "Deploying offline Code Menu Builder output:"
if [[ -d "$CM_ADDONS_SRC" ]]; then
    rm -rf "$CM_ADDONS_DST"
    cp -r "$CM_ADDONS_SRC" "$CM_ADDONS_DST"
    echo "  Replaced CM_Addons"
else
    echo "  [ERROR] $CM_ADDONS_SRC not found!"
fi
copy_file "data.cmnu" "$CM_CMNU_DST_DIR"
copy_file "CodeMenu.asm" "$CM_ASM_DST_DIR"
echo

echo
echo "==========================================="
echo "[2/7] Running Code Menu Builder (Netplay)..."
echo "==========================================="
run_builder "$BUILDER_EXE_NET" "dnet.cmnu"
echo
echo "Deploying netplay Code Menu Builder output:"
copy_file "dnet.cmnu" "$CM_CMNU_DST_DIR"
copy_file "Net-CodeMenu.asm" "$CM_ASM_DST_DIR"
# AddonAliases.asm holds addresses of addon lines inside the menu file. The shared
# CM_Addons comes from the offline build, so warn if the netplay menu's layout differs.
if [[ -e "$CM_ADDONS_SRC/AddonAliases.asm" && -e "$CM_ADDONS_DST/AddonAliases.asm" ]]; then
    if cmp -s "$CM_ADDONS_SRC/AddonAliases.asm" "$CM_ADDONS_DST/AddonAliases.asm"; then
        echo "  Netplay addon aliases match the offline ones"
    else
        echo "  [WARNING] Netplay AddonAliases.asm differs from the offline one. dnet.cmnu has a"
        echo "            different layout, so its addon lines may point at the wrong menu lines."
    fi
fi
echo

echo
echo "================================"
echo "[3/7] Building RSBE01..."
echo "================================"
"$GCT" "sd_base/vBrawl/RSBE01.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[4/7] Building BOOST..."
echo "================================"
"$GCT" "sd_base/vBrawl/BOOST.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[5/7] Building NETPLAY..."
echo "================================"
"$GCT" "sd_base/vBrawl/NETPLAY.txt" < "$ENTER"
echo

echo
echo "================================"
echo "[6/7] Building NETBOOST..."
echo "================================"
"$GCT" "sd_base/vBrawl/NETBOOST.txt" < "$ENTER"
echo

# VDS Sync
echo
echo "================================"
echo "[7/7] VDS Sync..."
echo "================================"
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
