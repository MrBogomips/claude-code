# Integration Test: Multi-Language Pipeline

## Objective
Verify language detection and language pack usage across the pipeline.

## Test Cases

### Test A: Italian Brief → Italian SOW
**Input**: Italian version of the sample brief (translate key sections to Italian)
**Invoke**: "Scrivi un SoW da questo brief"

**Verify**:
- [ ] Language detected as Italian
- [ ] Section headers use Italian language pack (e.g., "Perimetro" not "Scope")
- [ ] Legal boilerplate in Italian
- [ ] Domain terminology uses Italian terms (e.g., "Committente", "Fornitore")
- [ ] RACI legend in Italian
- [ ] Risk strategies in Italian ("Mitigare", "Trasferire")

### Test B: English Brief → English SOW
**Input**: `sample-brief.md` (already in English)
**Invoke**: "Write a SOW from this brief"

**Verify**:
- [ ] Language detected as English
- [ ] Section headers use English language pack
- [ ] Legal boilerplate in English
- [ ] All subsection headers in English

### Test C: Mixed Language → Clarification
**Input**: Brief with Italian executive summary but English technical sections
**Invoke**: "Create a SOW from this document"

**Verify**:
- [ ] Skill detects mixed language (< 80% single language)
- [ ] Asks user to choose: "I detected mixed languages (Italian ~55%, English ~45%). Which language should I use for the SOW?"
- [ ] Proceeds in chosen language after user response

### Test D: sow-review on Italian SOW
**Input**: Italian SOW from Test A
**Invoke**: "Revisiona questo SoW"

**Verify**:
- [ ] Review report in Italian (matching SOW language)
- [ ] Dimension names localized
- [ ] Adversarial challenges use Italian context (e.g., references to Codice degli Appalti if applicable)

## Success Criteria
- Language detection is reliable across all tests
- Language packs are loaded correctly (not hardcoded English)
- Review skill respects the SOW's language
- Pipeline maintains language consistency end-to-end
