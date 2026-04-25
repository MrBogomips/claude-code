# Diagram Type Decision Table

Use this when you know *what* you want to show but not *which diagram
type*. Load the specific `diagrams/<type>.md` only after selecting.

## "I want to show…"

| You want to show…                                   | Use                      |
|-----------------------------------------------------|--------------------------|
| Static class structure, inheritance, associations   | class                    |
| Runtime objects & their links                       | object                   |
| Package dependencies, namespacing                   | package                  |
| Software components and their interfaces            | component                |
| Internal structure of a complex component           | composite-structure      |
| Physical/cloud deployment of components             | deployment               |
| UML meta-model extensions, custom stereotypes       | profile                  |
| Temporal flow between participants (messages)       | sequence                 |
| Alternative view of sequence focusing on structure  | communication            |
| Control flow / business process                     | activity                 |
| State transitions of a single entity                | state                    |
| User goals and actor interactions                   | usecase                  |
| Overview of multiple interactions                   | interaction-overview     |
| Time-based behavior (signals, clocks, lifecycles)   | timing                   |
| System context / landscape (C4 L1)                  | c4 (Context)             |
| Containers inside a system (C4 L2)                  | c4 (Container)           |
| Components inside a container (C4 L3)               | c4 (Component)           |
| Code-level structure (C4 L4)                        | use `class` instead      |
| Data model, entities, relationships                 | er                       |
| Enterprise architecture, business capability map    | archimate                |
| Hierarchical concept map, brainstorm                | mindmap                  |
| Work Breakdown Structure (project decomposition)    | wbs                      |
| Project timeline, milestones                        | gantt                    |
| Low-fidelity UI wireframe                           | salt                     |
| Data structure (API response, config)               | json-yaml                |
| Network topology (rack, L2/L3, packet flow)         | nwdiag-family            |

## Tiebreakers

- **class vs er**: use `class` if methods matter; `er` if the story is
  "entities + cardinalities + attributes only".
- **sequence vs communication**: default to `sequence` (temporal
  flow is easier to read). Use `communication` only if the structural
  grouping matters more than the ordering.
- **activity vs state**: `activity` models a process *across* actors
  or phases; `state` models the lifecycle *of one thing*.
- **component vs c4-component**: `component` is a generic UML type;
  `c4 (Component)` is opinionated (specific shapes, relationship
  notation). Use C4 if the rest of the documentation is C4.
- **deployment vs c4-container**: `deployment` is node-centric (where
  things physically run); `c4 (Container)` is logical unit-centric.

## Anti-patterns

- Do NOT use a diagram type just because it's the project default if
  the content doesn't fit. Split the request instead.
- Do NOT combine types in one file (e.g., class + deployment). One
  file = one type.
- Do NOT pick `timing` unless the diagram is genuinely about time
  axes; the notation is unfamiliar and costly to learn for readers.
