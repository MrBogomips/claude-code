# Redaction Audit Template

This audit is an internal verification artifact. It is written to the working-documents folder only and is **never**
shared with the customer or referenced from the client deliverable. Its purpose is to let a human
confirm that nothing confidential leaked and that nothing essential was lost.

Write it to `<working-docs>/<doc-name>-client-v<N>-redaction-audit.md`, with the same `v<N>` as the
deliverable it audits, so the audit of an earlier version is never overwritten. Populate the template
below from the audit buffer.

```markdown
# Redaction Audit — [Document Name]

Source: [source path/title]
Client deliverable: [deliverables]/[doc-name]-client-v[N].md
Language: [en | it]
Date: [date]

## Summary

- Total items removed: [count]
- Removed by category: [A: n, B: n, C: n, D: n, E: n, catch-all: n]
- Step 6 residual scan (Grep on the written deliverable): [Clean | n items removed | n hits kept for review]
- Verdict: [SAFE TO SHARE | REVIEW NEEDED]

## Removals

### Step 3 — Source removals

| # | Location | Category | Removed snippet | Reason |
|---|----------|----------|-----------------|--------|
| 1 | [section] | [category] | [short excerpt] | [why unsuitable] |

### Step 6 — Residual markers caught in the written deliverable

| # | Location | Pattern | Category | Marker | Reason |
|---|----------|---------|----------|--------|--------|
| 1 | [section, line] | [R1–R14, V1–V5, or "read-through"] | [category] | [marker text] | [why unsuitable] |

### Step 6 — Hits kept for review

| # | Location | Pattern | Text kept | Why it is technical substance |
|---|----------|---------|-----------|-------------------------------|
| 1 | [section, line] | [V1–V5] | [e.g. "internal load balancer"] | [e.g. network component of the solution] |

## Verdict rationale

[One or two sentences. SAFE TO SHARE when Step 6 was clean, nothing was kept for review and every
removal is accounted for. REVIEW NEEDED when Step 6 caught residual items, kept a REVIEW hit, or any
removal was ambiguous and warrants a human second look before the deliverable leaves the building.]
```

## Verdict logic

| Condition | Verdict |
|-----------|---------|
| Step 6 residual scan clean, no hit kept for review, all removals categorized with reasons | **SAFE TO SHARE** |
| Step 6 caught residual markers, kept a REVIEW hit, a REMOVE pattern still matched after three passes, or any removal was borderline | **REVIEW NEEDED** |
