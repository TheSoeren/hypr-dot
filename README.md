# Dotfiles

Based on ml4w with custom configuration.

<a href="https://mylinuxforwork.github.io/dotfiles-installer/" target="_blank">
  <img src="https://mylinuxforwork.github.io/dotfiles-installer/dotfiles-installer-badge.png" style="border:0;margin-bottom:10px">
</a>

## caps2esc setup

Install all necessary dependencies for udevmon to work.

1. Create the file `udevmon.service` at `/usr/lib/systemd/system/udevmon.service` and fill the
   file with following content

```
[Unit]
Description=Monitor input devices for launching tasks
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service
Documentation=man:udev(7)

[Service]
ExecStart=/usr/bin/udevmon -c /etc/interception/udevmon.yaml
Nice=-20
Restart=on-failure
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
```

3. Create the file `/etc/interception/udevmon.yaml` and fill the file with following content

```
- JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
```

4. Reload system and start and enable the service

```
sudo systemctl daemon-reload
```

```
sudo systemctl enable udevmon.service
```

```
sudo systemctl start udevmon.service
```
