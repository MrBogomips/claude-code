# Redaction Audit Template

This audit is an internal verification artifact. It is written to the working-documents folder only and is **never**
shared with the customer or referenced from the client deliverable. Its purpose is to let a human
confirm that nothing confidential leaked and that nothing essential was lost.

Populate the template below from the audit buffer.

```markdown
# Redaction Audit — [Document Name]

Source: [source path/title]
Client deliverable: [deliverables]/[doc-name]-client-v[N].md
Language: [en | it]
Date: [date]

## Summary

- Total items removed: [count]
- Removed by category: [A: n, B: n, C: n, D: n, E: n, catch-all: n]
- Step 6 residual scan: [Clean | n items caught after rewrite]
- Verdict: [SAFE TO SHARE | REVIEW NEEDED]

## Removals

### Step 3 — Source removals

| # | Location | Category | Removed snippet | Reason |
|---|----------|----------|-----------------|--------|
| 1 | [section] | [category] | [short excerpt] | [why unsuitable] |

### Step 6 — Residual markers caught in the rewritten output

| # | Location | Category | Marker | Reason |
|---|----------|----------|--------|--------|
| 1 | [section] | [category] | [marker text] | [why unsuitable] |

## Verdict rationale

[One or two sentences. SAFE TO SHARE when Step 6 was clean and every removal is accounted for.
REVIEW NEEDED when Step 6 caught residual items or any removal was ambiguous and warrants a human
second look before the deliverable leaves the building.]
```

## Verdict logic

| Condition | Verdict |
|-----------|---------|
| Step 6 residual scan clean, all removals categorized with reasons | **SAFE TO SHARE** |
| Step 6 caught residual markers, or any removal was borderline | **REVIEW NEEDED** |
