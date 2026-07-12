# lockshell (unused)

Idle and manual lock both use **hyprlock**.

This directory is intentionally empty so Quickshell is not used as a locker.
If you want a Quickshell lock again, add `shell.qml` here and point
`hypridle.conf` `lock_cmd` at `quickshell -c lockshell --no-duplicate`.
