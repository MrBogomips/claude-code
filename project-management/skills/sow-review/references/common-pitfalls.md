# Common SOW Pitfalls

Anti-patterns and exploitation scenarios for the adversarial review pass. Each pitfall includes the pattern, who it hurts, and how to fix it.

---

## Scope Pitfalls

### P1: The Vague Scope Trap
**Pattern:** Scope uses qualitative language ("comprehensive solution", "all necessary features") without enumeration.
**Exploited by:** Vendor (delivers minimum interpretation) OR Client (demands maximum interpretation).
**Fix:** Enumerate every feature/capability in scope. If it's not listed, it's not in scope.

### P2: Missing Exclusions
**Pattern:** No out-of-scope section, or exclusions are too narrow.
**Exploited by:** Client ("I assumed data migration was included — it's obviously needed").
**Fix:** For each in-scope item, explicitly state what adjacent work is excluded. Pay special attention to: data migration, training, documentation, infrastructure provisioning, third-party licenses, ongoing support.

### P3: Scope-Schedule Disconnect
**Pattern:** Ambitious scope with a compressed timeline, but no phasing or prioritization.
**Exploited by:** Client (demands everything by deadline) AND Vendor (cherry-picks easy items, defers hard ones).
**Fix:** Phase the scope with priority-based delivery. Define what happens if the timeline is at risk: scope flex, timeline extension, or resource increase.

### P4: The "Reasonable Efforts" Escape
**Pattern:** Obligations qualified with "reasonable efforts", "best efforts", or "commercially reasonable".
**Exploited by:** Vendor (effort was reasonable, outcome wasn't achieved — not our fault).
**Fix:** Replace effort-based language with outcome-based obligations. Define what "done" looks like, not how hard someone tried.

---

## Commercial Pitfalls

### P5: Unbounded Obligations
**Pattern:** "The vendor shall provide support as needed" or "The client shall make resources available."
**Exploited by:** Either party — the one NOT providing interprets "as needed" broadly; the one providing interprets it narrowly.
**Fix:** Quantify: "up to 40 hours/month of support" or "2 dedicated client SMEs available 4 hours/week."

### P6: Payment Without Acceptance Gates
**Pattern:** Payment tied to calendar dates or milestones defined as "completion of Phase X" without acceptance criteria.
**Exploited by:** Vendor (declares completion, collects payment, quality is debatable).
**Fix:** Tie payment to formal acceptance with defined criteria. Include a review period and explicit acceptance/rejection process.

### P7: Penalty Asymmetry
**Pattern:** Vendor has late-delivery penalties but client has no penalties for delayed feedback, approvals, or dependency delivery.
**Exploited by:** Client (delays reviews, vendor absorbs schedule impact while penalties accrue).
**Fix:** Make penalties bidirectional. Client delays that exceed defined response windows should extend the vendor timeline by at least the same duration.

### P8: No Change Cost Visibility
**Pattern:** Change process exists but doesn't require cost/impact assessment before approval.
**Exploited by:** Client (approves changes without understanding cost, then disputes the bill).
**Fix:** Require written impact assessment (scope, timeline, cost) with client sign-off before any change work begins.

---

## Risk Pitfalls

### P9: Generic Risk Register
**Pattern:** Risks are all generic: "scope creep", "key person dependency", "technology risk", with no project-specific analysis.
**Exploited by:** Both parties — generic mitigations provide false confidence; real risks are unaddressed.
**Fix:** Every risk should be traceable to a specific project element (deliverable, dependency, constraint, assumption).

### P10: Assumption Bombs
**Pattern:** Assumptions are listed but never referenced. If an assumption proves invalid, there's no defined consequence.
**Exploited by:** Vendor ("Assumption A3 is invalid, therefore the entire timeline is void").
**Fix:** Each assumption should have: an impact-if-invalid assessment, a trigger for re-evaluation, and a defined process for handling invalidation (CR, renegotiation, or termination right).

---

## Collaboration Pitfalls

### P11: The RACI Trap
**Pattern:** RACI has multiple A's per activity, or key stakeholders are C (Consulted) on everything.
**Exploited by:** Nobody benefits — this just causes delays and confusion.
**Fix:** Exactly one A per activity. Limit C assignments to people who genuinely need to provide input. Most people should be I (Informed), not C.

### P12: Substitution Without Controls
**Pattern:** Team composition is listed but there's no substitution policy.
**Exploited by:** Vendor (replaces senior developers with juniors at the same rate, or swaps named individuals without notice).
**Fix:** Define: minimum qualifications for each role, notice period for substitution, client approval requirement for key roles, rate adjustments if seniority changes.

### P13: The Governance Vacuum
**Pattern:** No steering committee, no escalation path, no decision-making authority defined.
**Exploited by:** Both parties — disagreements have no resolution mechanism, leading to stalemates or unilateral decisions.
**Fix:** Define governance with: decision authority levels, escalation triggers, meeting cadence, and quorum requirements.

---

## Technical Pitfalls

### P14: NFR Hand-Waving
**Pattern:** Non-functional requirements are vague ("the system must be fast and secure") without targets or measurement methods.
**Exploited by:** Client (interprets "fast" as sub-second; vendor interprets it as sub-minute).
**Fix:** Every NFR needs: a numeric target, a measurement method, a measurement environment (production vs. staging), and a frequency of measurement.

### P15: Integration Assumptions
**Pattern:** Integration requirements listed without specifying: who owns the integration, what happens when the external system is unavailable, who provides test environments.
**Exploited by:** Both parties — integration failures become a blame game.
**Fix:** For each integration: define owner, API contract, error handling, fallback behavior, test environment availability, and SLA for external system uptime.

---

## Legal Pitfalls

### P16: IP Ambiguity
**Pattern:** IP clause doesn't address: open-source components, pre-existing vendor IP, derivative works, or what happens if the contract terminates early.
**Exploited by:** Either party — vendor reuses client-funded IP elsewhere; client claims ownership of vendor's pre-existing framework.
**Fix:** Explicitly categorize: new IP (work-for-hire → client owns), pre-existing IP (vendor retains, grants license), open-source (governed by their licenses), and derivative works (clarify ownership based on what was derived from what).

### P17: The Infinite Warranty
**Pattern:** Warranty covers "all defects" without defining what constitutes a defect vs. a new requirement, or without a time limit.
**Exploited by:** Client (reports enhancement requests as "defects" during warranty period).
**Fix:** Define: warranty duration, what counts as a defect (deviation from accepted criteria), what counts as an enhancement (new behavior), response time SLAs, and whether warranty extends when defects are found.

### P18: Missing Termination Rights
**Pattern:** No termination clause, or termination only "for cause" without defining cause.
**Exploited by:** Either party — trapped in a failing engagement with no exit.
**Fix:** Include: termination for convenience (with notice period and payment for completed work), termination for cause (with defined triggers), and transition obligations (knowledge transfer, data return, handover period).
