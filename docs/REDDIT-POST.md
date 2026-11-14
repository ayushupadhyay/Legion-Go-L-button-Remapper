# Reddit post draft

Title: I made a small Legion Go S listener to open Game Bar with Legion L — preview, source included

I wanted Legion L to open Windows Game Bar while keeping Lenovo's power and fan controls, so I built a small Windows listener for my Legion Go S.

It reads the vendor button interface and sends Windows+G when Legion L is pressed. It starts at sign-in through Task Scheduler rather than waiting for desktop mode. No controller driver or firmware changes are needed.

This opens Game Bar; it is not a virtual Xbox Guide button and does not pause games.

The listener does not suppress Lenovo's own response. There is an optional reversible launcher-filename workaround that keeps Space available through a manual shortcut. It affects old shortcuts and can be undone by updates. Already-running Space behaviour needs testing, so please read the limitations first.

Tested on one Legion Go S 83N6 / 8APU1 in X-input mode. The prototype button action works; the packaged installer still needs clean-machine testing. Other Legion models are not claimed as supported.

Source, build instructions, uninstall steps and known limitations: https://github.com/ayushupadhyay/legion-l-gamebar.

Sharing this as a preview for review and feedback, not as an official Lenovo/Microsoft tool.

