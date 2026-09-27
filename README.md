# ha-addons

Home Assistant add-ons maintained here. Each one documents its own options and architecture in
`addons/<slug>/README.md`.

## Host exposure: the raw IPv6 path

Tunnelling a service through Cloudflare does **not** make it unreachable from the internet, and the
tunnel is not a filter over the host's own addresses — `cloudflared` dials *outbound* to the edge, so
it is an additional entrance beside the raw address. IPv6 has no NAT: the ISP advertises a prefix,
every device self-assigns a global address, and any port the host publishes answers there. On Home
Assistant OS, Docker's userland proxy publishes each add-on port, so a service can even answer on the
host's IPv6 while binding IPv4-only.

Measured on this stack (HAOS behind a Freebox): the Home Assistant frontend and two add-on ports
(a stream aggregator and a music server) answered on the host's global IPv6 in plaintext HTTP,
bypassing the Cloudflare Access policies and WAF rules completely. The other published ports — the
stream proxy, the web UI, the personal app — answer on IPv4 only.

IPv4 was never the problem: with no port-forward, NAT keeps it closed. IPv6 has no such implicit
barrier, so it needs an explicit inbound filter — and some consumer routers ship that filter disabled,
which is why nothing in any dashboard looks exposed.

**Close it (Freebox):** Freebox OS → *Paramètres de la Freebox* → **Mode avancé** → **Configuration
IPv6** → section **Général** → enable the firewall → **Appliquer**. The firmware then drops all
inbound IPv6 and offers no selective openings, so anything that needs direct inbound access later has
to go through the tunnel (or an IPv4 port-forward). LAN traffic and outbound connections are
unaffected: the local port checks keep answering, which is expected and not a sign the filter failed.

**Verify:** read the host's global address from Home Assistant (Paramètres → Système → Réseau, or the
supervisor API's `network.ipv6_addresses`), then open `http://[<host-ipv6>]:<port>/` from a phone —
it must load on Wi-Fi (that is the control) and time out with Wi-Fi off. Use a port that actually
listens on IPv6: a service that only listens on IPv4 fails from every network and looks like a pass.

Addresses leak rather than being guessed — any service you contact logs yours, and once a prefix is
known it can be scanned deliberately. The interface identifier rotates, the ISP prefix does not, so
"nobody can find it" is not a control.
