# NixOS for a Lenovo Thinkpad X395

Because of the various and sundry complications with getting NixOS to work on this machine, I'm posting my system level configuration files here.

**Be sure to disable secure boot. NixOS cannot boot with secure boot mode enabled in UEFI**

| Feature | Status |
| ------- | ------ |
| Suspend/Resume | working |
| Restart | working |
| X | working |
| Sound | not working |
| Backlight brightness | partially working |
| Webcam | |

## Hardware

* Ryzen 7 PRO 3700U 2.3G
* 16GB DDR4 2666
* Graphics: ???
* Wireless: Intel 9260
* Storage: 1TB M.2 2280 NVMe

## Acknowledgements

Graham Christensen for introducing me to NixOS originally.

adisbladis in the #nixos-chat channel for pointing me to the correct kernel and for providing an install image.

