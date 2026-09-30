# Scenario: Triggering

## Setup
The whole marketplace installed, so that sow-write competes with the other skills for the same
requests.

## Invocation
Run each prompt in a fresh session and note which skill loads.

## Should trigger sow-write
- "Write a SOW for this project brief"
- "Create a statement of work from these meeting notes"
- "Turn this service contract into a summary SOW"
- "Scrivi un SoW per questo progetto"
- "Prepara il capitolato tecnico per la gara"
- "Prepara un'offerta tecnica a partire da questo brief"

## Should not trigger sow-write
- "Draft a proposal for our marketing campaign" (a general proposal, not a SOW)
- "Write a project plan for the migration" (a plan, not a SOW)
- "Draft a business case for the new CRM"
- "Review this SOW" (sow-review)
- "Estimate this SOW" (sow-estimate)

## Acceptance Criteria
- [ ] Every "should trigger" prompt loads sow-write
- [ ] No "should not trigger" prompt loads sow-write
- [ ] The review and estimate prompts load sow-review and sow-estimate respectively
