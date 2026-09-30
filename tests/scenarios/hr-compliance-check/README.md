# hr-compliance-check Test Scenarios

Layer 2 scenarios for the `human-resources:compliance-check` skill. They check that the
Italian bias lexicon, the pay-transparency rules and the CV-gap proxy produce the right
severity (CRITICAL / WARNING / INFO only) and a citation taken from
`human-resources/skills/compliance-check/references/legal-map.md`.

## Setup

Use a scratch output folder outside any git repository, for example `<scratch>/hr-out`.
Load the plugin (`claude --plugin-dir ./human-resources`) or install it from the marketplace.
The fixtures in this folder are fictional and anonymized.

## Fixtures

| File | Content |
|------|---------|
| fixture-jd-it.md | Italian JD for a remote backend role with "Sviluppatore", "madrelingua italiana", "bella presenza", "automunito", "residente in zona", and no pay range |
| fixture-questionnaire-it.md | Italian screening questionnaire with a pay-history question, a CV-gap question, and no privacy notice |

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-italian-jd-lexicon.md | Italian lexicon rows, severities and legal-map citations on a JD; embedded call |
| scenario-pay-history-and-gap.md | Pay-history question is CRITICAL in the EU; gap question is a WARNING proxy; form without privacy notice is CRITICAL |
