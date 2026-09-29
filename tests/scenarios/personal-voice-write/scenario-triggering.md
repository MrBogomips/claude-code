# Scenario: Description triggering

## Setup
No fixture needed. Run each prompt with `trigger.sh` in a new scratch directory, at least twice.

## Invocation
| Prompt | Expected |
|---|---|
| "Scrivi una mail breve al team per dire che il report trimestrale è pronto per la revisione." | `personal-voice:write` |
| "Rédige un court message pour l'équipe : la réunion de lundi est déplacée à 10h." | `personal-voice:write` |
| "Schreib einen kurzen Bericht für meinen Chef über den Stand der Migration." | `personal-voice:write` |
| "Draft an email to our client explaining that the delivery moves to next Tuesday." | `personal-voice:write` |
| "Mi prepari un post LinkedIn per annunciare che sabato parlo al meetup sul testing?" | `personal-voice:write` |
| "Write a commit message for a change that adds a /health endpoint." | not invoked |
| "Scrivi il messaggio di commit per la correzione del bug di login." | not invoked |
| "Write a Python docstring for a function that parses ISO dates." | not invoked |
| "Write a GitHub Actions YAML workflow that runs npm test on push." | not invoked |
| "Explain in two sentences what a mutex is." | not invoked |

## Acceptance Criteria
- [ ] At least 9 of 10 runs of the first five prompts invoke `personal-voice:write`
- [ ] No run of the last five prompts invokes it

Result on 2026-09-29: 10 of 11 human-facing runs invoked the skill (one French run did not); 0 of 5 excluded runs did.
