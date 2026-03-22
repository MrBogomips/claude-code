# Scenario: Language Detection

## Setup
Three test inputs:
- **Input A**: Italian project brief (100% Italian)
- **Input B**: English project brief (100% English)
- **Input C**: Mixed-language brief (60% Italian, 40% English)

## Invocation
For each input: "Write a SOW from this brief"

## Expected Behavior
- **Input A**: auto-detects Italian, loads `it.md` language pack, produces Italian output
- **Input B**: auto-detects English, loads `en.md` language pack, produces English output
- **Input C**: detects ambiguity, asks user to choose language

## Acceptance Criteria
- [ ] Input A: section headers in Italian (e.g., "Perimetro" not "Scope")
- [ ] Input A: legal boilerplate in Italian
- [ ] Input B: section headers in English
- [ ] Input C: skill asks "I detected mixed languages — which language should I use for the SOW?"
- [ ] Language pack loaded only after detection (progressive disclosure)

## Edge Cases
- Input with technical English terms in an Italian document → should still detect Italian
- Input with only 2-3 sentences → may not have enough tokens for reliable detection
