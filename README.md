# Dotfiles

Based on ml4w with custom configuration.

<a href="https://mylinuxforwork.github.io/dotfiles-installer/" target="_blank">
  <img src="https://mylinuxforwork.github.io/dotfiles-installer/dotfiles-installer-badge.png" style="border:0;margin-bottom:10px">
</a>

## udev caps and escape swap

1. Create the file `/etc/udev/hwdb.d/90-keyboard-ext.hwdb` and add the following content:

```
evdev:input:b*
 KEYBOARD_KEY_70029=capslock
 KEYBOARD_KEY_70039=esc
```

(Optional for laptop keyboard) Create the file `/etc/udev/hwdb.d/90-keyboard-int.hwdb` and add the following content:

```
evdev:atkbd:*
 KEYBOARD_KEY_3a=esc
 KEYBOARD_KEY_01=capslock

```

2. Reload the config:

```
sudo systemd-hwdb update
sudo udevadm trigger
```
