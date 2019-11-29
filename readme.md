# NixOS for a Lenovo Thinkpad X395

Because of the various and sundry complications with getting NixOS to work on this machine, I'm posting my system level configuration files here.

**Be sure to disable secure boot. NixOS cannot boot with secure boot mode enabled in UEFI**

| Feature                       | Status                  |
| ----------------------------- | ----------------------- |
| Suspend/Resume                | sometimes working       |
| Restart                       | working                 |
| X                             | working                 |
| volume management with Thunar | working                 |
| Sound                         | working                 |
| Backlight brightness          | working                 |
| Webcam                        | working                 |
| Avahi                         | working                 |
| Lock on suspend               | delegated to user space |
| Disable Root user             | no                      |

Suspend/Resume sometimes fails. It appears to fail in the suspend step, in that the screen remains on, the laptop remains on, but the system remains unresponsive.

## Hardware

* Ryzen 7 PRO 3700U 2.3G
* 16GB DDR4 2666
* Graphics: Radeon Mobile Vega Gfx (processor integrated)
* Wireless: Intel 9260
* Storage: 1TB M.2 2280 NVMe

## Acknowledgements

Graham Christensen for introducing me to NixOS originally.

adisbladis in the #nixos-chat channel for pointing me to the correct kernel and for providing an install image.

## Others

I keep other Nix repositories for other parts of my environment

* [My Nix shell environment](https://github.com/savannidgerinel/nix-shell)
* [Derivations for Luminescent Dreams software](https://github.com/luminescent-dreams/luminescent-dreams-nixpkgs)
