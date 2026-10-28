# vBrawl

vBrawl is vanilla Super Smash Bros. Brawl mod with quality-of-life features added. It uses some of the infrastructure as the Project+ codebase, but character balance, physics and stages stay as they are in Brawl unless you change them yourself in the Code Menu.

There are two builds:

- **Offline**: `RSBE01.GCT` + `BOOST.GCT` (Wii, or Dolphin through `Brawl Offline Launcher.elf`)
- **Netplay**: `NETPLAY.GCT` + `NETBOOST.GCT` (Dolphin only, through `Brawl Netplay Launcher.elf`)

## Features

Everything below differs from vanilla Brawl.

### Gameplay

- **Tripping is disabled.** [Kapedani]
- **Controller input lag fix.** Use the initial set of polled inputs polled during the current frame. Reduces input lag by a variable 0-2 frames. [Magus]
- **Gameplay is vanilla by default.** Every Code Menu gameplay setting (hitstun, hitlag, shield values, staling, item grabs, input buffer, jumpsquat) defaults to the vanilla brawl value. Nothing changes until you change it.
- **Default ruleset:** 3 stocks, 8-minute time limit, team attack on, pausing off. You can still change any of these in Rules. [vBrawl]

### Menus and Character Select

- **Boot directly to Character Select Screen** Hold **L/R** while booting to go to Training, **Z** to go to Replays, or **Start** to go to the title screen. [PyotrLuzhin, SammiHusky, QuickLava]
- **Character Select Screen preserved in VS Mode** (characters, colors, tags) when you leave for other menus and come back. [Magus]
- **Faster Character Select.** Fighter files aren't loaded until the match starts, and the cursor moves faster. [MarioDox, Dantarion]
- **Custom controls from Character Select.** Hold **L** when choosing a name to jump into the controls menu and back. Press Y on an existing name to change the controls within the menu, and press START to move that name to the top of the list. [ChaseMcDizzle, Fracture, DukeItOut] vBrawl removes the "Charge" C-stick option, so you can't set up charge smash.
- **Rumble toggle on Character Select.** Press **X** on your tag to toggle rumble. Tags with rumble on are shown colored. [ChaseMcDizzle, Fracture, Yohan1044, DukeItOut, Eon]
- **Better name tags.** You can type Japanese characters in the name maker and use names that are normally rejected [Dantarion, standardtoaster]. Tags show on the results screen [PyotrLuzhin] and in replays [Y.S]. Your tag resets when your controller is unplugged [standardtoaster].
- **The Rules button on Character Select opens the full main-menu Rules screen.** [MarioDox, Squidgy]
- **Everything is unlocked.** All characters, stages, modes (All-Star, Boss Battles), Target Smash levels, trophies, stickers and challenges. [Kapedani, Magus, Spigel, eric]

### Stage Select

- **Stage lists and striking.** Use the Random Stage Switch pages to pick a tournament stage list preset, then strike stages right on the Stage Select Screen with the X button. B reverts all strikes. [Magus, InternetExplorer, DukeItOut, Kapedani]
- Stagesets include:
  - Supernova/GOML 2026
  - Supernova 2025
  - Sweet Spot X Crimson
  - Sweet Spot X Blue
  - Ohio Ruleset 2025
  - Mushi League
  - All Stages (vanilla behaivor)
- **Press L + R + A on Stage Select to go back to Character Select.** [ds22, Magus]
- **Custom Stage Select Screen engine** with alternate stage support and a stage-list display. [Spunit, Phantom Wings, SOJ, Yohan1044, DukeItOut, JOJI, Kapedani]

### Training Mode

- **More CPU behaviors.** Besides the usual options, the Training CPU can hold shield, crouch, or DI in a set direction or at random. [Eon, PyotrLuzhin]
- **Free pause camera.** The camera isn't restricted while paused.

### Code Menu

The Code Menu ("Vanilla Brawl Code Menu") has the options below. Gameplay options start off or at their vanilla value; a few convenience options are on by default in the Netplay build (see [Default settings by build](#default-settings-by-build)). Access this menu in the Offline build with L+R+Dpad-Down.

- **Debug Mode** (Code Menu → Debug Mode Settings):
  - Hitbox, hurtbox, ledge-grab box and collision displays [Magus, Eon]
  - Stage collision display, raycast display [Eon, QuickLava]
  - Draw DI: shows each hit's trajectory with SDI and ASDI
  - Frame advance, camera lock, HUD toggle, FPS counter [UnclePunch]
  - Overlays for armor, hitstun and body state [Magus]
  - Switch characters mid-match [Magus, Krisan Thyme, Eon]. A stock match no longer ends when you switch.
- **Per-player Code Menu pages.** Infinite shield, set your percent (or set it with the D-pad), switch character, and set your own input buffer (0–10 frames, default 10).
- **Match options.** Endless Friendlies, auto-skip results screen, crowd cheers on/off, staling on/off.
- **Gameplay Modifiers.** Hitstun, hitlag, SDI/ASDI distance, shield size, shield damage and shield tilt, wall bounce and walljump strength, knockback decay, and jumpsquat length. There's also a toggle for grabbing items with aerials and dash attacks (on by default, as in vanilla) [QuickLava].
- **Special Modes.**
  - Random Angle Mode [PyotrLuzhin, DesiacX, Eon, QuickLava]
  - Big Head Mode [Eon]
  - Flight Mode
  - Game speed modifier [Desi], character scale modifier [Desi]
  - Melee-style camera freeze on the final hit [Eon, QuickLava]
  - Parry taunts [QuickLava]
  - Universal walljumps [Dantarion, QuickLava]
- **Bonus Mechanics** (offline only) [QuickLava]. Per-player opt-in mechanics: Magic Series, Focus Attacks, and a "Rivals Mode" set (parries, hitfalling, baby dashes, tilt cancels, actionable airdodges, button walljumps and more).
- **Volume balance.** Adjusts how loud sound effects are compared to the music. [QuickLava]

#### Default settings by build

Different between the builds:

| Setting | Offline | Netplay |
| --- | --- | --- |
| Autoskip Results Screen | Off | **On** |
| Autosave Replays | Off | **On** (no save prompt after each match) |
| Code Menu Activation | On (L+R+Dpad-Down) | **Off** |
| Staling Toggle | On | Default (vanilla behavior) |

Everything else (debug displays, special modes, gameplay modifiers, Endless Friendlies, crowd cheers) starts off in both builds.

### Replays

- **Replays can be longer than 3 minutes.** [brkirch]
- **Replays can autosave**, skipping the save prompt after each match (on by default in Netplay, a Code Menu toggle offline). You can also save the previous match's replay after the fact (Code Menu). Replays go to the SD card's `vBrawl/rp` folder.
- **Replay fixes.** Replays play back correctly on custom/alternate stages, with Wiimotes, and with shared stocks. [Fracture, Kapedani, DukeItOut]
- **Free replay camera.** The camera isn't restricted during replays.

### Music

- **Custom My Music.** Each stage's song list is read from tracklist files, so you can add or change songs. Song titles display correctly, and Metal Cavern and the Training room can have their own playlists. [JOJI, DukeItOut, Kapedani]
- **Hanenbow is in My Music.** [Desi, JOJI, DukeItOut]
- **Netplay has its own tracklists** The Netplay build uses its own set of tracklists and cannot be modified (this is to prevent desyncs).

### Netplay

- **Separate Netplay build.** It has its own Code Menu, which is closed by default. Netplay-unsafe options (input buffer, speed and scale modifiers, bonus mechanics and similar) are hidden.
- **Dolphin netplay fixes.** The v-sync call is moved for smoother netplay [hannesmann, Dan Salvato, Achilles].
- **Fewer screens between matches.** Netplay skips the strap/health screen on boot [PyotrLuzhin], the results screen, and the save-replay prompt (replays autosave instead).
- **Salty Runback.** Restart the current match with the same characters and stage using a button combination. Music works on expansion stages too. [DukeItOut]
- **No Challenger Approaching screens** (included `gameconfig`). [ds22]

### Under the hood

These aren't visible in-game, but the features above depend on them:

- Loading files from the SD card instead of the disc: File Patch Code [Sammi Husky], SDHC/SDXC support [Bero, Exul Anima]
- Syriinge plugin loader [Sammi Husky, DukeItOut], and a second, expansion GCT [DukeItOut]
- Expansion stage system [DukeItOut, Kapedani, Phantom Wings, JOJI] and stage gimmick fixes [Kapedani, Eon]
- Faster loading: trimmed common files, PAC files used instead of PCS [DukeItOut]
- Code Menu framework [Desi, QuickLava and the Project+ team], built with the PowerPC Assembly Functions Code Menu builder
