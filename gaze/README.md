# Gaze Biometric Plugin for Noctalia Shell

Face authentication status, Control Center controls, and lockscreen badge for Noctalia Shell on Microsoft Surface Pro 8 using **Gaze** (`GunduLabs/gaze`).

---

## Features

- **Daemon Monitor (`service.luau`)**: Background service monitoring `gazed` and handling IPC commands.
- **Bar Status Widget (`widget.luau`)**: Shows biometric status (`󰈈 Scanning`, `󰄬 Verified`, `󰅚 Retry`) in the Noctalia top bar with click-to-auth.
- **Control Center Shortcut (`shortcut.luau`)**: Quick action button to trigger instant facial authentication.
- **Interactive Panel (`panel.luau`)**: Overlay card to test auth, check device status (`/dev/surface-ir-camera`), and enroll face templates.
- **Lockscreen Badge (`desktop_widget.luau`)**: Windows Hello–style face indicator for the Noctalia lock screen surface.

---

## 1. Prerequisites (Gaze Setup)

1. Install Gaze:
   ```bash
   paru -S gaze
   ```

2. Configure Gaze to use the Surface IR camera:
   Edit `/etc/gaze/config.toml`:
   ```toml
   device = "/dev/surface-ir-camera"
   ```

3. Enable the user service and enroll your face:
   ```bash
   systemctl --user enable --now gazed
   gaze add-face default
   ```

4. Enable PAM for Noctalia lockscreen:
   Add `pam_gaze.so` as `sufficient` to `/etc/pam.d/noctalia`:
   ```ini
   # /etc/pam.d/noctalia
   auth        sufficient    pam_gaze.so
   auth        include       system-auth
   ```

---

## 2. Install & Enable Plugin in Noctalia

Add this directory as a local plugin source:
```bash
noctalia msg plugins source add local path /home/veronoicc/noctalia-plugins
noctalia msg plugins enable veronoicc/gaze
```

### Adding to Bar / Control Center / Lock Screen

- **Top Bar**: Add `veronoicc/gaze:gaze_widget` to your bar widgets in Noctalia settings.
- **Control Center**: Add `veronoicc/gaze:gaze_shortcut` to your shortcuts list.
- **Lock Screen**: Run:
  ```bash
  noctalia msg lockscreen-widgets-edit
  ```
  and drag `veronoicc/gaze:gaze_lockscreen` onto your lock screen layout.
