# Elden-Ring-Seamless-Co-op-Installer
A simple Windows batch script to make installing the [Seamless Co-op mod](https://github.com/LukeYui/EldenRingSeamlessCoopRelease) (authored by [Luke Yui](https://github.com/LukeYui)) easier. Google Gemini assisted.

As always, this is an administrative batch file from some random person on the Internet. Keep with best security practices and review the code. Don't get into the habit of blindly trusting random scripts from GitHub.

# Usage
0. Windows only.
1. Download the [Seamless Co-op mod from Nexus Mods](https://www.nexusmods.com/eldenring/mods/510?tab=files).
2. Download the `Install-ERSC-Mod.bat` file from this GitHub.
3. Ensure the Seamless Co-op mod .zip file is in the same directory as `Install-ERSC-Mod.bat`; easiest if done from `%USERPROFILE%\Downloads`.
4. Run `Install-ERSC-Mod.bat` and accept administrative elevation. When finished, close the CMD Prompt window, and done.

# Quirks
- Script can perform an initial install of the mod so long as Elden Ring is already installed.
- Script preserves the currently installed `ersc_settings.ini` file.
- Script cleans up temporary files and directories, but will not delete the original .zip file containing the mod.
