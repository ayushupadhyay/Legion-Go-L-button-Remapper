# Legion Go L button Remapper

A small Windows listener that opens **Xbox Game Bar** when you press **Legion L** on a supported **Lenovo Legion Go S**.

**Preview:** tested on one Go S (83N6 / 8APU1), in X-input mode. The working prototype was confirmed by physical button tests. The packaged installer and restoration workflow still need clean-machine testing.

## Features

- Reads Legion L from the controller's vendor HID interface.
- Sends Windows + G once per press.
- Starts at sign-in through Task Scheduler without waiting for desktop mode.
- Leaves Lenovo services, power, fan, RGB, firmware and controller mappings alone.
- Tray icon with a stop command; no third-party driver or runtime library.
- No network access or telemetry.

This opens Game Bar. It does **not** emulate an Xbox Guide button, pause games, or add Guide hold behaviour.

## Keeping Legion Space available

The listener alone does **not** suppress Lenovo's response to Legion L. Both Space and Game Bar may open.

The optional launcher workaround preserves the signed Lenovo executable as `LegionSpace.Manual.exe` in the same folder and creates **Legion Space (Manual)** in Start. Space remains available manually; Lenovo's background service is not disabled.

This is a **launcher-path workaround, not a native button-only remap**:

- Existing shortcuts targeting the original filename may stop working. Use the new manual shortcut.
- Space may still respond to Legion L while already running. This combination needs testing; the listener does not suppress the running app.
- Lenovo updates may recreate the original launcher path and restore its button action.
- If all original Space shortcuts and running-app behaviour must stay unchanged, do not use the optional workaround. A true native button-only suppression method is not implemented.

## Requirements

- Windows 11 x64, .NET Framework 4.8 and Windows PowerShell 5.1.
- Xbox Game Bar installed; confirm Windows + G works first.
- Tested device: Legion Go S 83N6 / 8APU1; controller `VID_1A86 / PID_E310`, interface 06, vendor usage page FFA0.
- Go 1, Go 2, D-input mode and other firmware layouts are not validated.

## Install

Download and extract the project. Keep its folder structure. Read the scripts before running them.

Open Windows PowerShell in the extracted project folder:

```powershell
.\scripts\Build.ps1
.\scripts\Install.ps1
```

Installation copies the listener to `%LOCALAPPDATA%\LegionLGameBar` and creates the per-user task **Legion L Game Bar Community**. It runs five seconds after sign-in, at normal privilege, including on battery. Organisation policies may prevent task creation.

If the original prototype is installed, stop it and disable its older startup task first. A shared single-instance lock prevents duplicate listeners, but an old version could otherwise take precedence.

### Optional: prevent the button from launching Space

Save any work in Space first. This closes launcher processes at the exact selected path; it does not close games or change Lenovo services.

Find `LegionSpace.exe` inside `C:\Program Files\Lenovo\LegionSpace\<version>`. Open PowerShell as administrator **using the same Windows account**:

```powershell
.\scripts\Block-LegionL-SpaceLaunch.ps1 -LauncherPath 'C:\Program Files\Lenovo\LegionSpace\<version>\LegionSpace.exe'
```

Replace `<version>` with your installed folder name. Do not run against a launcher already modified by the prototype. The script requires a valid Lenovo signature, refuses existing backups, and saves a recovery record. Space can then be opened using **Legion Space (Manual)** in Start.

### Test your device

1. Press Legion L on the desktop. Game Bar should open once.
2. Check Legion R, Lenovo power/fan controls and normal gameplay.
3. Open **Legion Space (Manual)** and confirm it works. Check the already-running-Space limitation above.
4. Restart directly into Xbox mode, wait 10–15 seconds and test Legion L.

Do not assume compatibility until these checks pass. The package remains a preview until clean-machine testing is complete.

## Stop or uninstall

For this session, right-click the tray icon **Legion L → Game Bar**, then select **Stop Legion L mapping**. It returns at next sign-in.

To stop the installed listener and remove its startup task:

```powershell
.\scripts\Uninstall.ps1
```

Files and recovery records are kept. To restore the original Space launcher filename, run as administrator under the same Windows account:

```powershell
.\scripts\Restore-Space.ps1
```

Restoration checks the saved checksum and refuses to overwrite a launcher recreated by an update. It removes only its own manual shortcut. Keep the recovery record until restoration is complete.

## Troubleshooting

| Problem | Check |
| --- | --- |
| Game Bar never opens | Test Windows + G directly. Check the local log below. |
| No controller-connected entry | Check supported hardware and X-input mode. The listener retries disconnected devices every two seconds. |
| `Shortcut sent: 4/4`, no overlay | Windows accepted the shortcut; that does not prove the overlay appeared. Check Game Bar and other shortcut-handling apps. |
| Works only after desktop loads | Check the **Legion L Game Bar Community** task and its executable path. |
| Space and Game Bar both open | See the launcher workaround limitations. Updates and an already-running Space app can cause this. |

Log: `%LOCALAPPDATA%\LegionLGameBar\Legion L status.log`. It records connection/errors and Legion L timestamps, not keyboard typing or complete controller reports. It resets after exceeding approximately 1 MiB.

The source/download folder can move after installation because the executable is copied locally. Keep the restoration scripts and backup record.

## Build, releases and trust

`scripts/Build.ps1` uses the Windows .NET Framework C# compiler, produces `dist/LegionLGameBar.exe` and prints its SHA-256 digest. No third-party packages are required. GitHub Actions builds the same source and uploads an artifact; public release publishing is manual.

Executables are unsigned. Inspect and build the source or wait for a trusted release if Windows blocks a download. No Lenovo, Steam or Winhanced binaries are redistributed.

See [implementation notes](docs/IMPLEMENTATION.md), [release checklist](docs/RELEASE-CHECKLIST.md) and [Reddit draft](docs/REDDIT-POST.md).

## Credits and license

The vendor-interface approach and Go S layout were investigated using [OpenController](https://github.com/Brunovncs/OpenController), [GoTweaks](https://github.com/corando98/GoTweaks) and physical report tests. This repository contains a small Windows implementation and no external runtime library.

MIT licensed. Unofficial community project; not affiliated with Lenovo or Microsoft.

