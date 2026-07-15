#!/usr/bin/env bash
# Waybar network indicator: WireGuard icon when VPN is up, otherwise Wi‑Fi/Ethernet.
# Always emits a single-line JSON object (return-type: json).
# Usage:
#   network-status.sh           # status JSON for waybar
#   network-status.sh toggle-vpn

set -u
export LC_ALL=C

WG_IF="${WG_IF:-wg0}"
WG_UNIT="${WG_UNIT:-wg-quick@${WG_IF}.service}"

# Nerd Font icons (JetBrainsMono Nerd Font)
ICON_VPN="󰖂"
ICON_ETH=""
ICON_LINKED="󱘖"
ICON_DISC="󰤣"
ICON_DISABLED="󰤮"
ICON_WIFI=( "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" )

json_escape() {
  # Escape a string for JSON double quotes
  local s=${1-}
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

emit() {
  # emit text class tooltip [percentage]
  local text=$1 class=$2 tooltip=$3
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$class")" \
    "$(json_escape "$tooltip")"
}

wifi_radio_on() {
  local r
  r=$(nmcli -t -f WIFI general 2>/dev/null | head -1 || true)
  [[ "$r" == "enabled" ]]
}

find_wifi_device() {
  nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "wifi" && $1 !~ /^p2p-/ { print $1; exit }'
}

find_ethernet_device() {
  nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }'
}

vpn_is_up() {
  local ifname=$1
  [[ -d "/sys/class/net/${ifname}" ]] || return 1
  # Must be administratively/data-plane up and have an IPv4 address
  ip -o link show dev "$ifname" 2>/dev/null | grep -qE '[,<]UP[,>]' || return 1
  ip -4 -o addr show dev "$ifname" 2>/dev/null | grep -q 'inet ' || return 1
  return 0
}

vpn_address() {
  ip -4 -o addr show dev "$1" 2>/dev/null \
    | awk '{print $4; exit}'
}

vpn_handshake_age() {
  # Returns age in seconds, or empty if unknown / never
  local line ts now
  line=$(sudo -n wg show "$WG_IF" latest-handshakes 2>/dev/null | head -1 || true)
  [[ -n "$line" ]] || return 0
  ts=$(awk '{print $2}' <<<"$line")
  [[ -n "$ts" && "$ts" =~ ^[0-9]+$ && "$ts" -gt 0 ]] || return 0
  now=$(date +%s)
  echo $((now - ts))
}

vpn_transfer() {
  # human rx/tx from wg, if permitted
  local line rx tx
  line=$(sudo -n wg show "$WG_IF" transfer 2>/dev/null | head -1 || true)
  [[ -n "$line" ]] || return 0
  rx=$(awk '{print $2}' <<<"$line")
  tx=$(awk '{print $3}' <<<"$line")
  [[ -n "$rx" && -n "$tx" ]] || return 0
  printf '↓ %s  ↑ %s' "$(numfmt --to=iec --suffix=B "$rx" 2>/dev/null || echo "$rx")" \
    "$(numfmt --to=iec --suffix=B "$tx" 2>/dev/null || echo "$tx")"
}

wifi_signal_icon() {
  local pct=${1:-0}
  if   (( pct >= 80 )); then echo "${ICON_WIFI[4]}"
  elif (( pct >= 60 )); then echo "${ICON_WIFI[3]}"
  elif (( pct >= 40 )); then echo "${ICON_WIFI[2]}"
  elif (( pct >= 20 )); then echo "${ICON_WIFI[1]}"
  else echo "${ICON_WIFI[0]}"
  fi
}

wifi_active_info() {
  # prints: ssid|signal|freq  (freq may be empty)
  local row ssid signal freq
  row=$(nmcli -t -f ACTIVE,SSID,SIGNAL,FREQ device wifi list 2>/dev/null \
    | awk -F: '$1 == "yes" { print; exit }')
  if [[ -z "$row" ]]; then
    return 1
  fi
  ssid=$(cut -d: -f2 <<<"$row")
  signal=$(cut -d: -f3 <<<"$row")
  freq=$(cut -d: -f4 <<<"$row")
  printf '%s|%s|%s' "${ssid:-unknown}" "${signal:-0}" "${freq-}"
}

underlying_link_summary() {
  # Short line for VPN tooltip: underlying wifi/eth
  local eth wifi info ssid signal freq
  eth=$(find_ethernet_device || true)
  if [[ -n "${eth:-}" ]]; then
    printf '󰈀  %s (ethernet)' "$eth"
    return
  fi
  wifi=$(find_wifi_device || true)
  if [[ -n "${wifi:-}" ]]; then
    if info=$(wifi_active_info); then
      IFS='|' read -r ssid signal freq <<<"$info"
      if [[ -n "${freq:-}" ]]; then
        printf '󱄙  %s (%s%%) · %s' "$ssid" "$signal" "$freq"
      else
        printf '󱄙  %s (%s%%)' "$ssid" "$signal"
      fi
      return
    fi
  fi
  printf 'No active underlay link'
}

toggle_vpn() {
  if vpn_is_up "$WG_IF"; then
    if sudo -n systemctl stop "$WG_UNIT" 2>/dev/null; then
      notify-send -a WireGuard -i network-vpn-disconnected-symbolic \
        "WireGuard" "Disconnected (${WG_IF})" 2>/dev/null || true
      exit 0
    fi
    notify-send -a WireGuard "WireGuard" "Failed to stop ${WG_UNIT} (need sudo)" 2>/dev/null || true
    exit 1
  fi
  if sudo -n systemctl start "$WG_UNIT" 2>/dev/null; then
    notify-send -a WireGuard -i network-vpn-symbolic \
      "WireGuard" "Connected (${WG_IF})" 2>/dev/null || true
    exit 0
  fi
  notify-send -a WireGuard "WireGuard" "Failed to start ${WG_UNIT} (need sudo)" 2>/dev/null || true
  exit 1
}

if [[ "${1-}" == "toggle-vpn" ]]; then
  toggle_vpn
fi

# ---------- status path ----------

# 1) WireGuard takes priority over the normal network logo
if vpn_is_up "$WG_IF"; then
  addr=$(vpn_address "$WG_IF" || true)
  under=$(underlying_link_summary)
  age=$(vpn_handshake_age || true)
  xfer=$(vpn_transfer || true)

  tooltip="󰖂  WireGuard connected"
  [[ -n "${addr:-}" ]] && tooltip+=$'\n'"󰩟  ${addr}"
  tooltip+=$'\n'"${under}"

  if [[ -n "${age:-}" ]]; then
    if (( age < 180 )); then
      tooltip+=$'\n'"󰔟  Handshake ${age}s ago"
    else
      tooltip+=$'\n'"󰔟  Handshake ${age}s ago (stale?)"
    fi
  fi
  [[ -n "${xfer:-}" ]] && tooltip+=$'\n'"${xfer}"
  tooltip+=$'\n\n'"Right-click: toggle VPN"

  emit "$ICON_VPN" "vpn" "$tooltip"
  exit 0
fi

# 2) Ethernet
eth=$(find_ethernet_device || true)
if [[ -n "${eth:-}" ]]; then
  ipaddr=$(ip -4 -o addr show dev "$eth" 2>/dev/null | awk '{print $4; exit}')
  tooltip="󰈀  ${eth} (Connected)"
  [[ -n "${ipaddr:-}" ]] && tooltip+=$'\n'"󰩟  ${ipaddr}"
  tooltip+=$'\n\n'"Right-click: toggle VPN"
  emit "$ICON_ETH" "ethernet" "$tooltip"
  exit 0
fi

# 3) Wi‑Fi radio off
if ! wifi_radio_on; then
  emit "$ICON_DISABLED" "disabled" "Wi-Fi is OFF"$'\n\n'"Scroll-up: enable Wi-Fi"$'\n'"Right-click: toggle VPN"
  exit 0
fi

# 4) Wi‑Fi connected
wifi=$(find_wifi_device || true)
if [[ -n "${wifi:-}" ]]; then
  state=$(nmcli -t -f DEVICE,STATE device status 2>/dev/null \
    | awk -F: -v d="$wifi" '$1 == d { print $2; exit }')
  case "$state" in
    connected|connected\ \(externally\))
      if info=$(wifi_active_info); then
        IFS='|' read -r ssid signal freq <<<"$info"
        icon=$(wifi_signal_icon "${signal:-0}")
        tooltip="󱄙  ${ssid} (${signal}%)"
        [[ -n "${freq:-}" ]] && tooltip+=$'\n\n'"󰐻  Freq: ${freq}"
        ipaddr=$(ip -4 -o addr show dev "$wifi" 2>/dev/null | awk '{print $4; exit}')
        [[ -n "${ipaddr:-}" ]] && tooltip+=$'\n'"󰩟  ${ipaddr}"
        tooltip+=$'\n\n'"Click: Wi-Fi menu · Right-click: toggle VPN"
        emit "$icon" "wifi" "$tooltip"
        exit 0
      fi
      # Connected but listing lagged — still show a mid-signal icon
      ipaddr=$(ip -4 -o addr show dev "$wifi" 2>/dev/null | awk '{print $4; exit}')
      if [[ -n "${ipaddr:-}" ]]; then
        emit "${ICON_WIFI[2]}" "wifi" "󱄙  ${wifi}"$'\n'"󰩟  ${ipaddr}"$'\n\n'"Right-click: toggle VPN"
        exit 0
      fi
      emit "$ICON_LINKED" "linked" "󱘖 ${wifi}: No IP Address"$'\n\n'"Right-click: toggle VPN"
      exit 0
      ;;
    connecting*|configuring*|ip-config*|preparing*)
      emit "${ICON_WIFI[1]}" "wifi" "Wi-Fi connecting…"$'\n\n'"Right-click: toggle VPN"
      exit 0
      ;;
  esac
fi

# 5) Disconnected
emit "$ICON_DISC" "disconnected" "No Connection"$'\n\n'"Click: Wi-Fi menu · Right-click: toggle VPN"
exit 0
