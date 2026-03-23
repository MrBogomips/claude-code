# KPI Design Guide for Process Improvement

## Principles of Good Process KPIs

### 1. Measurable
The KPI must produce a number. If you can't measure it, you can't improve it.

**Bad:** "Customer satisfaction is good"
**Good:** "Customer satisfaction score is 4.2 out of 5"

### 2. Actionable
The team must be able to influence the KPI through process changes.

**Bad:** "Market share" (too many external factors)
**Good:** "Time to respond to customer requests" (directly controllable)

### 3. Relevant
The KPI must relate to the actual pain point the team wants to fix.

**Bad:** "Number of meetings" (doesn't measure outcomes)
**Good:** "Decisions made per week" (measures what meetings should produce)

### 4. Time-bound
The KPI must have a measurement frequency that matches the improvement cycle.

**Bad:** "Annual revenue growth" (too slow for weekly kaizen cycles)
**Good:** "Weekly throughput" (measurable at each iteration)

## Common Process KPIs

### Efficiency KPIs
| KPI | Formula | Unit | Direction |
|-----|---------|------|-----------|
| Cycle time | Time from start to finish of one unit | hours/days | minimize |
| Lead time | Time from request to delivery | hours/days | minimize |
| Throughput | Units completed per time period | count/week | maximize |
| Flow efficiency | Processing time / Lead time | percentage | maximize |
| First-time-right rate | Units without rework / Total units | percentage | maximize |

### Quality KPIs
| KPI | Formula | Unit | Direction |
|-----|---------|------|-----------|
| Defect rate | Defects found / Units produced | percentage | minimize |
| Rework rate | Units requiring rework / Total units | percentage | minimize |
| Escape rate | Defects found by customers / Total defects | percentage | minimize |

### Satisfaction KPIs
| KPI | Formula | Unit | Direction |
|-----|---------|------|-----------|
| Customer satisfaction | Survey score average | 1-5 scale | maximize |
| Internal NPS | Team satisfaction with the process | -100 to 100 | maximize |
| Ease of use | Self-reported ease rating | 1-5 scale | maximize |

## Measurement Protocols

### For Automated Metrics
If the process is tracked in a tool (Jira, Linear, etc.):
1. Define the query that extracts the metric
2. Document the query for reproducibility
3. Run at a consistent time (e.g., every Monday morning)

### For User-Reported Metrics
If the metric requires human observation:
1. Define exactly what to measure and how
2. Create a simple recording form (spreadsheet, checklist)
3. Assign responsibility for measurement
4. Set a measurement cadence (weekly, biweekly)

### For Survey-Based Metrics
1. Use consistent questions across measurements
2. Keep surveys short (3-5 questions maximum)
3. Use the same scale consistently
4. Measure at regular intervals, not ad-hoc

## Avoiding KPI Pitfalls

### Goodhart's Law
"When a measure becomes a target, it ceases to be a good measure."

**Mitigation:** Always pair efficiency KPIs with quality KPIs. If you optimize cycle time, also track defect rate.

### Vanity Metrics
Metrics that look good but don't drive improvement.

**Signs:** The metric always improves, nobody acts on it, it doesn't correlate with outcomes.
**Fix:** Ask "If this metric improves by 20%, what would change in practice?"

### Measurement Overhead
The act of measuring shouldn't be more expensive than the improvement.

**Rule of thumb:** If measurement takes >10% of the time spent on the process, simplify the metric.
