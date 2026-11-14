# Legion Go L button Remapper

Open **Windows Game Bar** with the **Legion L button** on a supported **Legion Go S**. Lenovo's power and fan controls stay in place.

## Install — no commands needed

1. Open [Downloads](https://github.com/ayushupadhyay/Legion-Go-L-button-Remapper/releases) and download **Legion-Go-L-button-Remapper-Setup.zip** from the preview release.
2. Right-click the ZIP → **Extract All**.
3. Open the extracted folder and double-click **Install.cmd**.
4. Follow the prompts, then press Legion L to test it.

The installer starts the listener now and whenever you sign in, including Xbox mode. No PowerShell commands or separate build step are needed for the setup ZIP.

One optional prompt asks whether Legion L should stop opening Space. Choose **Yes** to keep Space accessible through a new **Legion Space (Manual)** Start shortcut; Windows then asks for administrator approval. Choose **No** to leave Space untouched.

## Uninstall

Search Start for **Uninstall Legion Go L button Remapper**, or double-click **Uninstall.cmd** in the extracted folder. Follow the prompts. It removes automatic startup and offers to restore the original Space launcher.

## Before you download

- **Preview:** tested on one Legion Go S 83N6 / 8APU1 in X-input mode. The new setup flow still needs a clean-machine test.
- **Go 1, Go 2 and D-input are not validated.**
- Opens Game Bar using Windows + G; it does not emulate an Xbox Guide button or pause games.
- The optional Space workaround changes its launcher filename. Existing Space shortcuts may need the new manual shortcut; Space can still react while already running, and updates can undo the workaround.
- The download is unsigned. If Windows blocks it, do not bypass protections just to run it; review/build the source or wait for a trusted release.
- No internet access, telemetry, third-party driver or controller firmware changes.

[Detailed instructions and troubleshooting](docs/ADVANCED.md) · [How it works](docs/IMPLEMENTATION.md) · [Testing checklist](docs/RELEASE-CHECKLIST.md)

## Source and license

Source is in `src/`; build instructions are in the detailed guide. The setup ZIP includes the prebuilt executable, source and scripts. MIT licensed; unofficial, not affiliated with Lenovo or Microsoft.

The Go S interface was investigated using [OpenController](https://github.com/Brunovncs/OpenController), [GoTweaks](https://github.com/corando98/GoTweaks) and physical tests. No external runtime binaries are bundled.
