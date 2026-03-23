# Kaizen Methodology Reference

## Core Principles

**Kaizen** (改善) means "change for better" in Japanese. It is a philosophy of continuous, incremental improvement involving everyone in the organization.

### The 5 Kaizen Principles

1. **Know your customer** — understand who benefits from the process
2. **Let it flow** — eliminate waste so work flows smoothly
3. **Go to gemba** — observe the actual process where it happens
4. **Empower people** — involve the people who do the work in improving it
5. **Be transparent** — make problems visible, track metrics openly

## PDCA Cycle (Deming Cycle)

The foundation of every kaizen iteration:

### Plan
- Identify the problem or opportunity
- Analyze root causes (5 Whys, Ishikawa)
- Develop a hypothesis and proposed change
- Define success criteria and metrics

### Do
- Implement the change on a small scale
- Document what was done
- Collect data during implementation

### Check
- Compare results against the plan
- Analyze what worked and what didn't
- Look for unintended consequences

### Act
- If successful: standardize the change (update SOPs, checklists)
- If unsuccessful: analyze why and try a different approach
- Document learnings for future iterations

## 5S Methodology

For workplace/process organization:

| Step | Japanese | English | Application |
|------|----------|---------|-------------|
| 1 | Seiri | Sort | Remove unnecessary steps, tools, artifacts |
| 2 | Seiton | Set in order | Organize remaining elements for optimal flow |
| 3 | Seiso | Shine | Clean up processes, remove workarounds |
| 4 | Seiketsu | Standardize | Document the improved process |
| 5 | Shitsuke | Sustain | Maintain the improvement over time |

## 7 Wastes (Muda)

Look for these in any process:

| Waste | Process Equivalent | Example |
|-------|-------------------|---------|
| Transport | Unnecessary handoffs | Forwarding emails through 3 people |
| Inventory | Work in progress queues | 50 tickets waiting for review |
| Motion | Context switching | Switching between 5 tools for one task |
| Waiting | Blocked work | Waiting for approvals, dependencies |
| Over-processing | Excessive detail | Writing 10-page reports nobody reads |
| Overproduction | Doing too much | Building features nobody asked for |
| Defects | Rework | Fixing mistakes from unclear requirements |

## Root Cause Analysis

### 5 Whys

Start with the problem. Ask "Why?" 5 times to reach the root cause.

**Example:**
1. Why is delivery slow? → Approvals take too long
2. Why do approvals take too long? → Approvers are overloaded
3. Why are approvers overloaded? → Every change needs senior approval
4. Why does every change need senior approval? → Policy was set after a major incident
5. Why hasn't the policy been updated? → Nobody reviewed it after the incident was resolved

**Root cause:** Outdated approval policy that was appropriate for a crisis but not for normal operations.

### Ishikawa (Fishbone) Diagram

Categorize causes into 6 areas:
- **People** — skills, training, availability
- **Process** — steps, sequence, handoffs
- **Technology** — tools, systems, automation
- **Materials** — inputs, data quality, templates
- **Environment** — culture, priorities, competing demands
- **Measurement** — metrics, feedback loops, visibility

## Value Stream Mapping

For each step in the process:

1. **Name** the step
2. **Classify** as value-adding (VA), necessary non-value-adding (NNVA), or waste (W)
3. **Measure** processing time (how long the step takes when actively worked)
4. **Measure** lead time (how long from entering to leaving the step, including waiting)
5. **Calculate** efficiency: processing time / lead time

**Target:** Improve flow efficiency by reducing the gap between processing time and lead time.
