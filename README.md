# Marlin 2.x Firmware for a Geetech A20T printer with a BigTreeTech ZSYong 3in1 hotend

Can be flashed with avrdude like this:
```
avrdude.exe -C avrdude.conf -P COM3 -c wiring -p m2560 -b 115200 -U ../custom-a20t-btt3in1-firmware.hex
```
