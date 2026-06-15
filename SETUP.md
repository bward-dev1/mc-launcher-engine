# MC Launcher — Setup & Play Guide

## 1. Install (via LiveContainer)
- Download **MCLauncher.ipa** from the [v1.0 release](https://github.com/bward-dev1/mc-launcher-engine/releases/tag/v1.0), or on the same Wi-Fi: `http://192.168.86.178:8910/MCLauncher.ipa`
- Open **LiveContainer → + → select the .ipa** → wait for install.
- Enable JIT for it (StikDebug or SideStore JIT) for full speed. *(Without JIT it still runs, just slower.)*

## 2. Play OFFLINE right now (no Microsoft login)
1. **Accounts → Add (+) → "Local"**
2. Type any username → OK
3. Pick a version → **Play**. Single-player works fully offline & serverless.

## 3. Recommended settings (A12Z iPad Pro)
- **Renderer:** Zink for 1.17+, GL4ES for ≤1.16.5 (fastest). Avoid `auto` (black-screens here).
- **RAM:** ~2.5–3 GB (the build includes the increased-memory entitlement).
- **Java:** 8 for ≤1.16.5, 17 for 1.17–1.20.4, 21 for 1.20.5+. (All three JREs are bundled — offline.)

## 4. Mods
- Built-in installers: Fabric / Forge / Modrinth / CurseForge (in the version/profile screens).
- Pick your version + loader, then browse & install.

## 5. Cheats + Shield (your custom features)
- Tap the **✨ wand toolbar button** → **Extras**:
  - **Cheats:** tap any command → copies to clipboard → paste in chat (cheats-enabled worlds).
  - **Shield:** toggle chat/grief/explicit protection; install safety mods from the Mods screen.

## 6. Online play (servers/Realms) — coming
Microsoft login is being fixed (Microsoft disabled the old client ID). Needs a free Azure Client ID — see the iMessage steps. Offline single-player works without it.
