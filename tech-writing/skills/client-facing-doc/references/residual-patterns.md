# Residual Patterns

Step 6 runs these patterns on the **written draft** (`<working-docs>/<doc-name>-client-v<N>-draft.md`),
not on the source or on text held in memory; the draft is copied to the deliverables folder only
when no REMOVE row matches it. A pattern either matches the file or it does not, so a leak that slipped through the
rewrite shows up as a concrete line.

## How to run them

- Use the Grep tool with the draft's path, output mode `content` and line numbers on. Set
  `-i` (case-insensitive) when the row says so; the other rows are case-sensitive on purpose.
- Pass the pattern exactly as written in its code block. The syntax is ripgrep's (Rust regex):
  no look-ahead or look-behind.
- The file's code blocks and tables are scanned like the prose: a `TODO` in a code sample is still
  an internal marker.

There are two kinds of rows:

- **REMOVE** rows match labels and figures that never belong in a client document. Remove every hit
  with the Edit tool, rewriting the sentence so no seam shows, and log it as a Step 6 removal.
- **REVIEW** rows match words that are also ordinary technical vocabulary ("internal load balancer",
  "error budget", "CAP theorem"). Judge each hit (see [Judging REVIEW hits](#judging-review-hits)).

Run all REMOVE rows first, fix the hits, and run them again until none matches. Stop after three
passes: if a REMOVE row still matches, report the lines and set the audit verdict to REVIEW NEEDED.
Then run the REVIEW rows once.

## REMOVE rows

### R1 — Currency symbols and amounts (case-sensitive)

```
[€£¥]|\$\s?\d[\d.,]*\s?(k|K|M|bn)\b|\$\s?\d{1,3}(,\d{3})+|\$\s?\d+\.\d{2}\b
```

Any `€`, `£`, `¥` (also `k€`), and dollar amounts shaped like money (`$40k`, `$40,000`, `$400.00`).
A bare `$` followed by a digit is also a shell variable, so it is a REVIEW row (V3).

### R2 — Currency codes and words next to a figure (`-i`)

```
\b(EUR|USD|GBP|CHF)\s?\d|\d[\d.,]*\s?(k|m|mln|mila|million|thousand)?\s?(EUR|USD|GBP|CHF|euros?|dollars?|pounds?)\b
```

`EUR 40k`, `40 k EUR`, `12 euro`, `USD 5,000`.

### R3 — Rate and pricing labels (`-i`)

```
\b(day rate|daily rate|hourly rate|rate card|per diem|tariffa (giornaliera|oraria)|list price|prezzo di listino|offerta economica)\b
```

### R4 — Effort units after a figure (`-i`)

```
\b\d+([.,]\d+)?\s*(md|pd|gg|man[- ]?days?|person[- ]?days?|dev[- ]?days?|giorni[ /-]?uomo|giornate[ /-]?uomo|g/u|man[- ]?hours?|person[- ]?hours?|ore[ /-]?uomo|story points?)\b
```

`30 MD`, `0,5 PD`, `12 gg`, `12 gg/uu`, `12 giornate/uomo`, `5 giorni uomo`, `120 man-hours`,
`40 ore uomo`, `8 story points`. A customer-facing duration such as a response time is written out
in full by the style rewrite ("5 giorni lavorativi"), so an abbreviated `gg` never needs to survive.

### R5 — FTE (`-i`)

```
\bFTE\b
```

Full-time-equivalent counts are staffing assumptions for costing (taxonomy B).

### R6 — Hours stated as effort (`-i`)

```
\b(effort|impegno)\b.{0,40}\b\d+([.,]\d+)?\s*(h|hrs?|hours?|ore)\b|\b\d+([.,]\d+)?\s*(h|hrs?|hours?|ore)\s+(of|di)\s+(effort|work|lavoro|impegno|sviluppo|development)\b
```

`effort for the migration: 120 hours`, `80 ore di sviluppo`. Hours outside an effort context
(a recovery time objective, a support window) are service levels and are not matched. An
"estimated" duration may be customer-facing ("the estimated downtime is 2 hours"), so it is a
REVIEW row (V6).

### R7 — Work-in-progress markers (case-sensitive)

```
\b(TODO|FIXME|WIP|XXX)\b
```

### R8 — Internal-status labels (`-i`)

```
\b(internal use only|for internal use only|solo (per |ad )?uso interno|riservato all'uso interno|do not share|do not distribute|not for (the )?(client|customer)|non condividere|non divulgare|non diffondere)\b|\[(internal|interno|riservato|confidential|confidenziale|draft|bozza|wip)\]|^[\s#>*_-]*(draft|bozza|internal notes?|note interne)[*_]*\s*:
```

Labels only: "internal use only", "solo per uso interno", "do not share", a bracketed tag such as
`[DRAFT]`, or a line that starts with `Draft:`, `Bozza:`, `Internal notes:`. Phrases that are also
technical ("the metrics endpoint is internal only", "API per uso interno", a line starting with
`Internal:` that describes an admin interface) are judged through V1.

### R9 — Upper-case stamps (case-sensitive)

```
^[\s#>]*[*_]*(INTERNAL|INTERNO|RISERVATO|RISERVATA|CONFIDENTIAL|CONFIDENZIALE|DRAFT|BOZZA)[*_]*\s*$|\b(INTERNAL|INTERNO|RISERVATO|CONFIDENTIAL|CONFIDENZIALE|DRAFT|BOZZA):
```

A stamp on a line of its own (`RISERVATO`, `**DRAFT**`) or followed by a colon (`INTERNAL:`). A list
item such as `- DRAFT` (a document status in a lifecycle list) is not a stamp and goes to V1.

### R10 — Assistant and reasoning phrasing (`-i`)

```
\b(as an ai|as a language model|come modello linguistico|let me think|let's think|step 1: i will|i will now|here is the (revised|rewritten|updated|final) (version|document|draft|text)|ecco (la|il) (versione|bozza|testo|documento) (rivista|rivisto|aggiornata|aggiornato|finale))\b|\bfirst,? i('ll|’ll| will)\b
```

### R11 — Prompt text (`-i`)

```
^[\s>"*_-]*(act as|agisci come|comportati come|you are an? \w+ (assistant|expert|consultant|architect|writer))\b|\b(your task is|il tuo compito è)\b|^\s*(system|user|assistant|prompt)\s*:
```

Instructions addressed to a model. "The gateway will act as the entry point" is not matched,
because the pattern needs "act as" at the start of a line.

### R12 — The content described as AI-written (`-i`)

```
\b(this|the|questo|il|la|questa) (document|documento|section|sezione|text|testo|content|contenuto|report|draft|bozza|analysis|analisi|summary|sintesi)\b.{0,30}\b(ai[- ]generated|(generated|written|drafted|produced) (by|with|using) (an? )?(ai|llm|language model|chatbot)|(generat[oa]|scritt[oa]|redatt[oa]|prodott[oa]) (da|con) (un'|una |un |l')?(ia|ai|llm|intelligenza artificiale|chatbot))\b
```

Only statements that the document or its text came from an AI. An AI model or feature that is part
of the proposed solution is architecture and is not matched.

### R13 — References to internal documents (`-i`)

```
\b(see (the )?internal|per the (internal|estimation)|internal (deck|wiki|sheet|spreadsheet|document|notes?|ticket)|estimation (sheet|workbook|spreadsheet|file|model)|documento interno|documentazione interna|wiki interna|foglio (di stima|delle stime)|slide interne|deck interno)\b
```

### R14 — Placeholders (`-i`)

```
\[(\.\.\.|…|tbd|tbc|placeholder|inserire[^\]]*|da completare|to be completed|fill in[^\]]*)\]|\b(fill in later|to be confirmed internally|da confermare internamente)\b
```

## REVIEW rows

### V1 — Internal, confidential, draft as ordinary words (`-i`)

```
\b(internal|interno|interna|interni|interne|confidential|confidenziale|riservat[oaie]|draft|bozza|bozze|provisional|provvisori[oaie])\b
```

Kept when technical: "internal load balancer", "internal API", "internal network", "the metrics
endpoint is internal only", `Internal:` heading an admin interface, "API per uso interno",
"confidential data is encrypted at rest", "draft standard", `- DRAFT` in a status list. Removed when
the word marks the document or the passage itself as internal to the author's organization ("This
section is internal only", "Documento ad uso interno", `Riservato:` before commercial notes).

### V2 — Budget, cap, cost and price words (`-i`)

```
\b(budget|cap|envelope|plafond|stanziamento|costs?|costo|costi|pricing|prezz[oi]|margins?|margine|discount|sconto|quotation|preventivo)\b
```

Kept when technical: "error budget", "CAP theorem", "rate cap", "cost-optimized storage tier",
"safety margin".

### V3 — Figures that may be rates (`-i`)

```
\$\s?\d|\b\d+([.,]\d+)?\s*k?\s?/\s?(day|gg|giorno|hour|ora)\b
```

`600/day` may be a day rate or a throughput; `$1` may be a price or a shell variable.

### V4 — AI-authorship words (`-i`)

```
\b(ai[- ]generated|ai[- ]assisted|generated (by|with) (an? )?(ai|llm)|generat[oa] (da|con) (l'|un'?)?(ia|ai|llm))\b
```

Removed when they describe how the document was written; kept when they describe what the solution
does ("the portal shows AI-generated summaries to operators").

### V5 — Links to document stores and @-mentions (`-i`)

```
https?://\S*(intranet|internal|sharepoint|confluence|atlassian\.net|jira|wiki|notion\.so)\S*|(^|\s)@[a-z][\w.-]+
```

Kept when the link or handle belongs to the customer or to public documentation; removed when it
points into the author's organization or names a colleague.

### V6 — Estimated durations (`-i`)

```
\b(estimated?|estimates|stima|stimat[oaie])\b.{0,40}\b\d+([.,]\d+)?\s*(h|hrs?|hours?|ore)\b
```

Kept when the duration is a customer-facing fact ("the estimated downtime for the cut-over is 2
hours", "la stima del fermo è di 3 ore"); removed when it is the effort of the work ("estimated
at 120 hours").

## Judging REVIEW hits

For each REVIEW hit, read the whole sentence:

- **Remove** it when the word carries commercial, effort, internal-status, internal-reference or
  AI-authorship meaning (a budget envelope, "see the internal notes", "this draft was generated with
  AI"). Log it as a Step 6 removal with its taxonomy category.
- **Keep** it when it is part of the technical substance that `preserve-checklist.md` keeps, such as
  the examples under each row. Log it in the audit's "Kept for review" table with the reason.
- **When unsure, remove it.** The doubt rule of the taxonomy still holds; REVIEW rows exist so that
  technical vocabulary is judged instead of deleted by reflex.

A kept REVIEW hit makes the audit verdict REVIEW NEEDED, so a human confirms it before the
deliverable is shared.

## What no pattern can see

After the scan, read the draft once more for leaks that have no fixed shape: figures, names
or plans taken from sections the user marked Remove, and chain-of-thought or prompt text phrased
in ways the rows above do not cover. Remove and log them like REMOVE hits.
