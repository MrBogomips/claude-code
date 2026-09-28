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
- **Input C**: detects mixed languages, recommends the dominant language (Italian) and asks the user to confirm

## Acceptance Criteria
- [ ] Input A: section headers in Italian (e.g., "Perimetro" not "Scope")
- [ ] Input A: legal boilerplate in Italian
- [ ] Input B: section headers in English
- [ ] Input C: skill recommends Italian and asks the user to confirm before proceeding
- [ ] Language pack loaded only after detection (progressive disclosure)

## Edge Cases
- Input with technical English terms in an Italian document → should still detect Italian
- Input with only 2-3 sentences → may not have enough tokens for reliable detection
