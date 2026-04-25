# Deployment Diagrams

## Purpose

Show where software components physically run: nodes (hosts, pods,
containers, VMs), artifacts deployed on them, and the communication
paths between nodes.

## Choose this when / avoid when

- ✅ Explaining environment topology to ops/SRE
- ✅ Documenting cloud architecture (regions, AZs, services)
- ✅ Capacity or HA reviews
- ❌ Logical component wiring → use `component`
- ❌ Network packet flows → use `nwdiag-family`

## Detail-level presets

- `minimal`: top-level nodes (e.g., "API Tier", "DB", "Queue"),
  connection labels, no artifacts.
- `standard`: nodes + deployed artifacts, connection protocols,
  grouped by environment or region.
- `detailed`: ports, versions, redundancy (active/passive), specific
  instance types/sizes.

## Layout tips

- Direction: follow traffic (user → edge → app → data) LR or TB as
  suits the shape.
- Nest nodes to show containment (`cloud { node { … } }`).
- Use stereotypes `<<AWS>>`, `<<Kubernetes>>` to hint platform.

## Snippet

```plantuml
@startuml Deployment_Prod
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

cloud "AWS eu-west-1" {
  node "ALB" as ALB
  node "ECS Fargate" as ECS {
    artifact "api:1.4.2" as API
  }
  database "RDS PostgreSQL" as DB
  queue "SQS orders" as Q
}

actor User
User --> ALB : HTTPS
ALB --> API  : HTTP/2
API --> DB   : TCP/5432
API --> Q    : HTTPS (publish)
@enduml
```

## Common pitfalls

- Conflating logical and physical. Fix: a deployment diagram shows
  *where things run*; logical wiring belongs in `component`.
- Missing protocols/ports. Fix: label every connection with its
  protocol at `standard` and up.
- Over-nesting (cloud → region → AZ → VPC → subnet → node) until the
  diagram is unreadable. Fix: omit layers that don't support the
  message.
