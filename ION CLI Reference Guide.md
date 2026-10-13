# ION CLI Reference Guide

Personal quick-reference built from recurring commands across case notes.
All commands link to the [official ION CLI reference](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands).

---

## Device Overview & Health

| Command | What it tells you |
|---|---|
| `dump overview` | Quick snapshot: device state, uptime, software version, controller status, WAN/LAN interface summary |
| `dump device date` | Current system time on the ION — useful to confirm NTP sync |
| `dump time status` | NTP sync status and configured time sources |
| `dump controller status` | Connectivity state to the Prisma SD-WAN controller |
| `inspect memory summary` | Memory usage summary — quick check for pressure |
| `inspect memory all` | Full memory breakdown per process |
| `inspect dpdk cpu` / `dump dpdk cpu` | DPDK CPU utilisation — check for fast-path saturation |

> Official reference: [dump overview](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands) · [inspect memory](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Interfaces

| Command | What it tells you |
|---|---|
| `dump interface status <id>` | Operational state, speed, link status for a physical or virtual interface |
| `dump interface status <id> module` | Includes SFP/transceiver info |
| `dump interface config <id>` | Configured parameters for an interface |
| `dump interface config <id> \| grep BW` | Quickly extract configured bandwidth |
| `dump waninterface summary` | Summary of all WAN interfaces |
| `inspect interface stats <id>` | RX/TX counters for an interface |

> Official reference: [dump interface](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## VPN / Tunnels

| Command | What it tells you |
|---|---|
| `dump vpn ha RemoteSite=<name>` | Which DC ION is **active** for a branch tunnel — use at branch side |
| `dump vpn summary RemoteSite=<name>` | Summary of VPN tunnels toward a remote site |
| `dump vpn status VpnLinkID=<id>` | Detailed status of a specific VPN link |
| `dump vpn status VpnLinkID=<id> \| grep Reason` | Extract tunnel down/up reason |
| `dump intra-cluster-tunnel status` | HA cluster tunnel state between paired IONs |
| `dump intra-cluster-tunnel config` | HA cluster tunnel configuration |

> Official reference: [dump vpn](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Routing

| Command | What it tells you |
|---|---|
| `dump routing route prefix=<prefix> vni=<id>` | Route lookup for a specific prefix in a VNI |
| `dump routing route prefix=<prefix>` | Route lookup without VNI scope |
| `dump routing peer status all` | BGP/routing peer state for all peers |
| `dump routing peer status all \| grep <ASN>` | Filter peer status by AS number |
| `dump routing peer advertised-routes all \| grep Total` | Count of advertised routes per peer |
| `dump routing peer advertised-routes vrf-name=<vrf> \| grep <prefix>` | Check if a specific prefix is being advertised |
| `dump routing peer received-routes vrf-name=<vrf> \| grep <prefix>` | Check received routes from a peer |
| `dump routing prefix-reachability prefix=<prefix>` | Reachability info for a prefix |
| `dump routing prefix-reachability vni=<id> prefix=<prefix>` | Reachability scoped to a VNI |
| `dump routing static-route config` | All configured static routes |
| `dump routing vpn-host-tracker status` | VPN host tracker state — used for DC failover decisions |
| `inspect fib vni=<id> \| grep <prefix>` | FIB (forwarding table) lookup in a VNI |
| `inspect fib vni=<id> lan \| grep <prefix>` | FIB LAN entries |
| `inspect fib vni=<id> vpn \| grep <prefix>` | FIB VPN entries |
| `inspect fib path-id=<id>` | Path details for a specific FIB path |
| `inspect vrf all` | All VRF/VNI routing table entries |

> Official reference: [dump routing](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands) · [inspect fib](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Flow & Traffic Inspection

| Command | What it tells you |
|---|---|
| `inspect flow brief srcv4=<ip>` | Active flows from a source IP |
| `inspect flow brief srcv4=<ip> dstv4=<ip>` | Flows between specific src/dst pair |
| `inspect flow brief srcv4=<ip> dstport=<port>` | Flows from a source to a specific destination port |
| `inspect flow brief dstport=<port>` | All flows toward a destination port |
| `inspect flow brief dstport=<port> \| grep DENY` | Denied flows on a port — quick security check |
| `inspect flow brief srcport=<port>` | Flows originating from a source port |
| `inspect flow detail srcv4=<ip>` | Detailed flow info including path and policy hits |
| `inspect flow detail srcv4=<ip> dstv4=<ip>` | Per-flow detail between a specific pair |
| `dump flow count-summary` | Flow count totals — useful to spot flow table pressure |
| `inspect user-app-session all \| grep App \| sort \| uniq -c \| sort -r` | Top applications by active session count |

> Official reference: [inspect flow](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Security Policy

| Command | What it tells you |
|---|---|
| `inspect security-policy size` | Size of compiled security policy — check after policy compilation failures |
| `dump security-policy config policy-set-stack all` | Full policy-set stack as configured |
| `dump security-policy config policy-rules source-zone=<zone>` | Policy rules for a specific source zone |
| `dump security-policy config prefix-filters prefix-filter="<name>"` | Contents of a named prefix filter |

> Official reference: [inspect security-policy](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Performance Policy & QoS

| Command | What it tells you |
|---|---|
| `dump performance-policy config policy-set-stack all` | Full performance policy stack |
| `inspect qos-bwc queue-snapshot` | Instantaneous QoS bandwidth controller queue state |
| `inspect qos-bwc queue-history` | Historical queue data |
| `inspect qos-bwc queue-history latest` | Most recent queue history entry |
| `inspect qos-bwc debug-state` | Internal QoS BW controller debug state |

---

## App Probe & Path Quality

| Command | What it tells you |
|---|---|
| `dump app-probe prefix server-ip=<ip> application=<app>` | App probe results toward a server IP for an application |
| `dump app-probe prefix application=<app>` | All app probe results for an application |

---

## DHCP

| Command | What it tells you |
|---|---|
| `dump dhcp-server config all` | Full DHCP server configuration |
| `dump dhcp-relay stat interface=<id>` | DHCP relay statistics on an interface |

---

## ARP & System

| Command | What it tells you |
|---|---|
| `inspect system arp all` | Full ARP table |
| `inspect system arp all \| grep <mac>` | Find ARP entry by MAC address |

---

## Logs & Debugging

| Command | What it tells you |
|---|---|
| `debug logs tail flow-ctrl` | Live-tail flow-controller logs |
| `debug logs tail user` | Live-tail user/auth logs |
| `debug logs tail mrl_agent` | Live-tail MRL agent logs |
| `debug logs follow flow-ctrl` | Follow (persistent tail) flow-ctrl logs |
| `debug logs dump event \| grep FAIL` | Historical events — filter for failures |
| `debug logs dump event \| grep boot` | Reboot events from event log |
| `debug logs dump event \| grep NETWORK_DIRECTINTERNET_DOWN` | Direct-internet down events |
| `debug logs dump event \| grep SECURITY` | Security-related events |
| `debug logs dump flow-ctrl \| grep err` | Errors from flow-ctrl daemon |
| `debug logs dump start=<ISO8601> <facility>` | Dump logs from a timestamp (`daemon`, `event`, `flow-ctrl`, `elem-mgr`, `emif`, `ham`) |
| `debug logs dump start=<ISO8601> end=<ISO8601> <facility>` | Dump logs in a time window |

**Example — isolate a specific time window:**
```
debug logs dump start=2026-09-22T05:00:00 end=2026-09-22T05:06:00 flow-ctrl
debug logs dump start=2026-08-14T02:00:00 end=2026-08-14T12:00:00 event | grep NETWORK_DIRECTINTERNET_DOWN
debug logs dump start=2026-10-01 ham | grep "peer connection"
```

> Official reference: [debug logs](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)

---

## Processes

| Command | What it tells you |
|---|---|
| `debug process status all` | Status of all monitored processes |
| `debug process status name=<proc>` | Status of a specific process (e.g. `vpnd`, `rtr_mgr_api`) |
| `debug process restart name=<proc>` | Restart a named process (e.g. `fc-cp`) — use with care |

**Common process names:** `vpnd`, `rtr_mgr_api`, `fc-cp`, `elem-mgr`, `sanmon`

---

## Logging Verbosity

| Command | What it turns on |
|---|---|
| `debug logging facility=flow-ctrl module=flow level=trace` | Trace-level flow logs |
| `debug logging facility=flow-ctrl module=flow_ext level=trace` | Trace-level extended flow logs |
| `debug logging facility=flow-ctrl module=policy level=trace` | Trace-level policy decision logs |
| `debug logging facility=flow-ctrl module=wan_path level=trace` | Trace-level WAN path selection logs |

> Always turn off trace logging when done — it generates significant volume.

---

## Fast-Path / DPDK (Low-Level)

| Command | What it tells you |
|---|---|
| `fp-cli dpdk-port-stats <port>` | DPDK port statistics for a physical port |
| `fp-cli dpdk-port-stats <port> \| grep drop` | Drop counters on a DPDK port |
| `fp-cli dpdk-port-stats <port> \| grep -i drop` | Case-insensitive drop filter |

**Mapping physical ports to DPDK ports** is device-specific — use `dump interface status` output and the port numbering documented per ION model.

---

## Service Links

| Command | What it tells you |
|---|---|
| `dump servicelink summary all` | Summary of all service link tunnels |

---

## Controller Reachability

| Command | What it tells you |
|---|---|
| `debug controller reachability 3` | Controller reachability test (level 3 verbosity) |

---

## Useful Combinations

```bash
# Check if an IP is reachable via a specific VNI
dump routing route prefix=<ip>/32 vni=<id>
inspect fib vni=<id> | grep <ip>

# Diagnose a specific flow end-to-end
inspect flow brief srcv4=<client-ip>
inspect flow detail srcv4=<client-ip> dstv4=<server-ip>

# Confirm VPN HA active/standby at a branch
dump vpn ha RemoteSite=<DC-site-name>        # run on branch
dump vpn ha RemoteSite=<branch-site-name>    # run on DC

# Find what's filling the policy/memory
inspect security-policy size
inspect memory summary

# Tail logs while reproducing an issue
debug logs tail flow-ctrl
debug logs follow flow-ctrl

# Find top apps by sessions
inspect user-app-session all | grep App | sort | uniq -c | sort -r

# Check DPDK drop counters (map interface → dpdk port number first)
fp-cli dpdk-port-stats <N> | grep -i drop
```

---

*Generated from personal case notes. Official docs: [Prisma SD-WAN ION CLI Reference](https://docs.paloaltonetworks.com/prisma-sd-wan/ion-cli-reference/use-cli-commands)*
