# Scenario: Research Subagent Activation

## Setup
Provide a deliberately vague project brief with:
- Undefined technical stack ("a modern web application")
- Unclear regulatory context ("must comply with relevant regulations")
- No domain terminology for the target industry

## Invocation
"Write a SOW from this brief"

## Expected Behavior
1. Input Analysis: rates maturity as "thin", identifies 3+ knowledge gaps
2. Research Prompt: skill presents gaps to user: "I've identified gaps in [technical stack, regulatory requirements, domain terminology]. Should I research these before proceeding?"
3. On approval: dispatches up to 3 parallel subagents with focused research questions
4. Research Results: presents findings to user for review
5. Clarification Round: informed by research findings (fewer questions needed)
6. Continues normal pipeline with enriched context

## Acceptance Criteria
- [ ] Skill detects knowledge gaps (not just missing sections)
- [ ] Asks user before dispatching research (doesn't auto-research)
- [ ] Subagents receive focused prompts (not full session history)
- [ ] Research results are presented before incorporation
- [ ] Subsequent sections reflect research findings

## Edge Cases
- User declines research → skill proceeds with clarification questions instead
- Research returns conflicting information → skill presents options to user
- User requests research explicitly on a rich brief → should dispatch even if not auto-triggered
