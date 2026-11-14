# Implementation notes

The listener enumerates registered HID paths, narrows to the tested Go S vendor/product and interface 06, and checks vendor usage page FFA0 and input report length. The interface is opened read-only with shared access. No feature/output reports are sent.

On the tested Windows HID path, the first byte is the report ID; Legion L is bit 0 of byte 1. This was confirmed by isolated physical button presses. Other libraries may strip the report-ID byte, so their offsets may differ.

A rising-edge detector with 450 ms debounce emits Windows+G using SendInput. A session mutex prevents duplicate instances. A tray menu exits the process; a background reader retries device connections. The local log is capped at approximately 1 MiB.

No virtual Xbox input, pause/suspend feature, firmware writes, driver, keyboard hook, typing log, game-process manipulation or network client is included.

Startup uses an interactive per-user sign-in task, not a Windows service or desktop Startup shortcut. Normal privilege, no execution time limit, battery operation allowed.

## Launcher workaround boundary

There is no native-only suppression of Legion L inside Lenovo's running app. The optional script changes its expected launcher filename and creates a manual shortcut. It does not uninstall Space or disable Lenovo services. Existing shortcuts and updates are affected; already-running Space behaviour requires testing before making stronger claims.

Restoration treats the saved metadata as untrusted: paths are constrained to the expected installation tree, their filename relationship is checked, the checksum is checked and existing launchers are never overwritten.
