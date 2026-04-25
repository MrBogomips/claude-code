# Network Diagrams (nwdiag family)

## Purpose

Network topology: networks, hosts, subnets, and links. PlantUML
supports `nwdiag`, `rackdiag`, `packetdiag` via the legacy blockdiag
compat layer.

## Choose this when / avoid when

- ✅ Network architecture: subnets, zones, interconnects
- ✅ Rack layout documentation
- ❌ Cloud topology at service level → use `deployment`
- ❌ Application-level communication → use `sequence` or `component`

## Detail-level presets

- `minimal`: networks + hosts, no addressing.
- `standard`: CIDR on networks, IP/interface on hosts, zones.
- `detailed`: VLANs, ports, trunk/access, HA pairs.

## Layout tips

- `@startuml` + `nwdiag { … }` block.
- Order networks vertically (DMZ top, internal bottom).
- Keep to ≤ 4 networks per diagram.

## Snippet

```plantuml
@startnwdiag Nwdiag_Topology
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml
network dmz {
  address = "192.168.10.0/24"
  web01 [address = "192.168.10.11"]
  web02 [address = "192.168.10.12"]
}
network internal {
  address = "10.0.0.0/16"
  web01 [address = "10.0.1.11"]
  web02 [address = "10.0.1.12"]
  app01 [address = "10.0.2.21"]
  db01  [address = "10.0.3.31"]
}
@endnwdiag
```

## Common pitfalls

- Using nwdiag for cloud deployment. Fix: cloud services don't map
  well to subnets; use a `deployment` diagram with cloud nodes.
- Overloading with too many addresses. Fix: show representative hosts;
  refer to a source-of-truth IPAM system for the complete list.
