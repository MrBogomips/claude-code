# Legal Map — Protected Grounds, Pay Transparency and AI Screening

> Reference file for the compliance-check skill, and the one place in the plugin that says which
> statute covers which protected ground. The other files name the ground and point here, so a
> correction made here reaches every skill.
>
> **Not legal advice.** This map comes from reviewer analysis, not from counsel. Verify it with
> counsel before relying on it, and check that each statute and article is still current.

---

## 1. Protected Grounds

Cite the statute in the row of the ground a finding touches. In the EU without Italian specifics,
cite the EU source instead. A proxy (a question or requirement that reveals a ground indirectly)
takes the row of the ground it reveals.

| Ground | Italy | EU source | Articles to cite |
|---|---|---|---|
| Race and ethnic origin | D.Lgs. 215/2003 | Directive 2000/43/EC | Art. 2 (direct and indirect discrimination), Art. 3(1)(a) (access to employment) |
| Religion or belief, disability, age, sexual orientation | D.Lgs. 216/2003 | Directive 2000/78/EC | Art. 2 (direct and indirect discrimination), Art. 3(1)(a) (access to employment) |
| Sex and gender, including marital and family status, pregnancy, maternity and paternity | D.Lgs. 198/2006 | Directive 2006/54/EC; Directive 92/85/EEC (pregnancy) | Art. 25 (definitions), Art. 27(1) (access to employment), Art. 27(2)(a) (marital or family status, pregnancy, maternity, paternity), Art. 27(2)(b) (ads and pre-selection that name a sex) |
| Political opinion, trade-union membership | L. 300/1970 | — (GDPR Art. 9 for the data) | Art. 8 (no investigation of opinions or of facts not relevant to professional aptitude), Art. 15 (acts that discriminate on these grounds are void) |
| Nationality | D.Lgs. 286/1998 | TFEU Art. 45 (free movement of EU workers) | Art. 43 (discrimination on national origin) |
| Disability — targeted hiring | L. 68/1999 | — | Targeted placement and hiring quotas; reasonable accommodation is D.Lgs. 216/2003 Art. 3(3-bis) |
| Relevance of candidate data (every ground) | L. 300/1970 Art. 8; D.Lgs. 276/2003 Art. 10; D.Lgs. 196/2003 Art. 113 | GDPR Art. 5(1)(c) | See Section 2 |
| Special category data (health, beliefs, union membership, sexual orientation, ethnic origin, biometrics, genetics) | D.Lgs. 196/2003 as amended by D.Lgs. 101/2018 | GDPR Art. 9 | Art. 9(1) prohibition; exceptions in Art. 9(2) are rare in recruitment |

## 2. Relevance and Genuine Occupational Requirements

- **Relevance test.** L. 300/1970 Art. 8 forbids investigating a candidate's political, religious or
  trade-union opinions and any fact not relevant to professional aptitude. D.Lgs. 196/2003 Art. 113
  keeps Art. 8 and D.Lgs. 276/2003 Art. 10 in force for data processing; it is not a lawful basis of
  its own (the lawful bases are in GDPR Art. 6, see `gdpr-guidelines.md`).
- **Intermediaries.** D.Lgs. 276/2003 Art. 10 applies to employment agencies and other authorized or
  accredited intermediaries. It bans investigations, data processing and pre-selection on protected
  grounds, even with the candidate's consent, and any processing of data not strictly related to
  professional aptitude.
- **Genuine occupational requirement.** A difference in treatment is lawful only when the
  characteristic is an essential and determining requirement of the work, the aim is legitimate and
  the requirement is proportionate:
  - race and ethnic origin: D.Lgs. 215/2003 Art. 3(3);
  - religion or belief, disability, age, sexual orientation: D.Lgs. 216/2003 Art. 3(3);
  - sex: D.Lgs. 198/2006 Art. 27 (only fashion, art and entertainment, where sex is essential to the work);
  - intermediaries: D.Lgs. 276/2003 Art. 10 (same test).

A document that states a justification gets the context-dependent treatment in compliance-check's
Self-Check Rules; it is not cleared automatically.

## 3. Pay Transparency — EU Directive 2023/970

The directive's transposition deadline was 7 June 2026. **Check the current national transposition
status** (in Italy, whether the implementing decree is in force and what it adds) before citing it
as national law. Until then, cite the directive itself.

| Rule | Article | Severity in EU jurisdictions |
|---|---|---|
| Applicants receive the initial pay or its range, based on objective, gender-neutral criteria, before the interview (for example in the job ad) | Art. 5(1) | A JD without a pay range, and without a statement of how the range is given before the interview: **WARNING** |
| The employer must not ask about current or past pay | Art. 5(2) | A pay-history question in any form, questionnaire or script: **CRITICAL** |
| Job titles and vacancy notices are gender-neutral, and recruitment is non-discriminatory | Art. 5(3) | A masculine-only or feminine-only job title: **CRITICAL** in Italy (with D.Lgs. 198/2006 Art. 27(2)(b)), **WARNING** elsewhere in the EU |

Asking for salary *expectations* is allowed; state the pay range first, so the answer is informed.

## 4. AI-Assisted Screening

- **GDPR Art. 22.** A candidate may not be subject to a decision based solely on automated processing
  that significantly affects them. Screening, ranking or rejection by a tool needs meaningful human
  review, and the candidate can ask for it and contest the decision.
- **AI Act (Regulation (EU) 2024/1689).** Annex III, point 4 classifies AI systems used to place job
  ads, filter applications or evaluate candidates as high-risk. The employer, as deployer, must ensure
  human oversight, use the system as instructed and tell candidates that such a system is used. Check
  the current application date of the high-risk obligations.
- **Disclosure.** The candidate privacy notice states that AI-assisted tools are used, what for, and
  that a person makes every decision (template line in `gdpr-guidelines.md` Section 6).

This plugin drafts documents and suggests ratings; the people using it decide. Its outputs therefore
say so wherever they propose a threshold, a score or a recommendation.
