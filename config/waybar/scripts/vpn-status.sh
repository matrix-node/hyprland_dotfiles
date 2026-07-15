#!/usr/bin/env bash
# Waybar VPN status indicator (WireGuard-aware, non-fatal if tools missing)
set -u
export LC_ALL=C

WG_IF="${WG_IF:-wg0}"

# Nerd Font icons (JetBrainsMono Nerd Font)
ICON_ON=$(printf '\xf3\xb0\x95\xa5')   # shield-check
ICON_OFF=$(printf '\xf3\xb0\x95\xa6')  # shield-off

vpn_is_up() {
  local ifc="$1"
  [[ -d "/sys/class/net/${ifc}" ]] || return 1
  command -v ip >/dev/null 2>&1 || return 1
  ip -o link show dev "$ifc" 2>/dev/null | grep -qE '[,<]UP[,>]' || return 1
  ip -4 -o addr show dev "$ifc" 2>/dev/null | grep -q 'inet ' || return 1
  return 0
}

# Also treat common nm WireGuard connection names as up (best-effort)
nm_vpn_up() {
  command -v nmcli >/dev/null 2>&1 || return 1
  nmcli -t -f TYPE,STATE connection show --active 2>/dev/null \
    | grep -qiE '^(wireguard|vpn):activated' || return 1
  return 0
}

if vpn_is_up "$WG_IF"; then
  addr=$(ip -4 -o addr show dev "$WG_IF" 2>/dev/null | awk '{print $4; exit}')
  printf '{"text":"%s","class":"connected","tooltip":"VPN Connected\\n%s\\nClick to disconnect"}\n' \
    "$ICON_ON" "${addr:-$WG_IF}"
elif nm_vpn_up; then
  printf '{"text":"%s","class":"connected","tooltip":"VPN Connected\\nClick to disconnect"}\n' \
    "$ICON_ON"
else
  printf '{"text":"%s","class":"disconnected","tooltip":"VPN Disconnected\\nClick to connect"}\n' \
    "$ICON_OFF"
fi
