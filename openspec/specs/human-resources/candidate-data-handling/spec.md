# human-resources/candidate-data-handling Specification

## Purpose
Defines how the HR skills that write files about named candidates keep that data confidential,
time-limited and out of shared places.

## Requirements

### Requirement: Candidate files are marked, kept out of version control and out of memory
pre-screening, interview-prep and interview-close SHALL suggest an output folder outside
version control, and SHALL warn and ask for confirmation when the chosen folder is inside a git
repository. Every internal candidate file SHALL start with a one-line confidentiality and
retention header with a delete-by date from the organization's retention period. The skills
SHALL NOT save candidate data (names, CV content, answers, notes, scores, evaluations) to memory;
only corporate context MAY be saved there.

#### Scenario: Output folder inside a repository
- **WHEN** the user chooses an output folder inside a git work tree for interview-prep
- **THEN** the skill says the folder is version-controlled and asks the user to confirm or choose another before writing

#### Scenario: Evaluation file header
- **WHEN** interview-close writes `{candidate}-evaluation-{interviewer}.md`
- **THEN** its first line is the confidentiality line with a delete-by date, and nothing about the candidate is written to memory

#### Scenario: File sent to the candidate
- **WHEN** pre-screening writes the async questionnaire for the candidate
- **THEN** it carries the privacy notice instead of the internal confidentiality line
