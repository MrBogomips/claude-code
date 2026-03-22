# GDPR Guidelines for HR Recruitment

> Reference file for the compliance-check skill. Provides GDPR principles and practical rules for processing candidate data throughout the recruitment lifecycle.

---

## 1. GDPR Principles Applied to Candidate Data

### 1.1 Lawful Basis (Article 6)

Processing candidate data requires at least one lawful basis. In recruitment, the most common are:

| Lawful Basis | GDPR Article | When It Applies |
|---|---|---|
| Legitimate interest | Art. 6(1)(f) | Evaluating candidates for a specific vacancy; must pass the balancing test |
| Consent | Art. 6(1)(a) | Storing CVs in a talent pool beyond the current vacancy; must be freely given, specific, informed, and withdrawable |
| Pre-contractual measures | Art. 6(1)(b) | Processing at the candidate's request prior to entering a contract (e.g., salary negotiation) |
| Legal obligation | Art. 6(1)(c) | Verifying right-to-work documentation as required by national law |

**Key rule**: Consent is rarely a valid basis for mandatory recruitment steps because of the power imbalance between employer and candidate. Prefer legitimate interest for standard recruitment processing.

### 1.2 Transparency (Articles 12-14)

- Inform candidates **before or at the time of data collection** about:
  - Identity and contact details of the data controller
  - Purpose and legal basis of processing
  - Categories of data collected
  - Recipients or categories of recipients
  - Retention period
  - Their rights (see Section 3)
- Use **clear, plain language** — no legal jargon
- Provide the information in a **privacy notice** (template in Section 6)

### 1.3 Data Minimization (Article 5(1)(c))

- Collect **only** data that is adequate, relevant, and limited to what is necessary for the recruitment decision
- Do NOT collect:
  - Photo (unless strictly necessary for the role, e.g., acting)
  - Date of birth (unless age is a legal requirement for the role)
  - Marital or family status
  - Nationality (ask only about right to work)
  - Social media profiles (unless job-relevant and disclosed in the privacy notice)

### 1.4 Purpose Limitation (Article 5(1)(b))

- Data collected for a specific vacancy must NOT be reused for other purposes without:
  - A compatible purpose assessment, OR
  - Fresh consent from the candidate
- Talent pool storage requires **separate, explicit consent**

### 1.5 Storage Limitation (Article 5(1)(e))

- Define and document a **retention period** before data collection begins
- Recommended retention periods:
  - **Unsuccessful candidates**: 6-12 months post-decision (longer only with consent for talent pool)
  - **Hired candidates**: Transfer relevant data to employee file; delete recruitment-only data
  - **Talent pool (with consent)**: Maximum 24 months; request renewal of consent before expiry
- Implement **automated deletion** or scheduled review processes

### 1.6 Integrity and Confidentiality (Article 5(1)(f))

- Restrict access to candidate data to authorized personnel only (hiring manager, HR)
- Use encrypted storage and secure transmission channels
- Maintain audit trails for access and modifications
- Ensure third-party recruiters and platforms comply via Data Processing Agreements (Art. 28)

---

## 2. Special Category Data (Article 9)

### 2.1 Definition

Special category data receives heightened protection under GDPR. The following must **NOT** be collected during recruitment unless a specific Art. 9(2) exemption applies (which is rare in standard recruitment):

| Special Category | Examples in Recruitment Context |
|---|---|
| Racial or ethnic origin | Nationality, ethnic background, skin color, photo revealing ethnicity |
| Political opinions | Party membership, political views, voting behavior |
| Religious or philosophical beliefs | Faith, religious practices, dietary restrictions linked to belief |
| Trade union membership | Union affiliation, union representative status |
| Genetic data | Family medical history, genetic test results |
| Biometric data (for identification) | Fingerprints, facial recognition data |
| Health data | Medical conditions, disability status, sick leave history, medication |
| Sexual orientation / sex life | Relationship status, partner gender, sexual identity |

### 2.2 Practical Implications

1. **Job descriptions**: Must not contain requirements that would force disclosure of special category data (e.g., "must be physically fit" without a genuine occupational requirement)
2. **Application forms**: Must not include fields for any special category data
3. **Interview questions**: Must not probe any special category topic, even indirectly
4. **Evaluation forms**: Must not record observations about special category characteristics
5. **Background checks**: Must be limited to job-relevant information with explicit legal basis

### 2.3 Exception: Occupational Requirement

Article 9(2)(b) permits processing when it is necessary for exercising rights in the field of employment law, **but only when authorized by EU or Member State law** with appropriate safeguards. This applies to:
- Disability accommodations (when the candidate voluntarily discloses)
- Right-to-work verification (national law mandate)

Even in these cases, apply **strict necessity**: collect the minimum data needed, restrict access, and delete promptly when no longer required.

---

## 3. Candidate Rights

Candidates are data subjects with full GDPR rights. HR must be prepared to respond within **one month** of receiving a request.

| Right | GDPR Article | What It Means for HR |
|---|---|---|
| **Access** | Art. 15 | Candidate can request a copy of all personal data held about them, including interview notes and evaluation scores |
| **Rectification** | Art. 16 | Candidate can correct inaccurate data (e.g., wrong name spelling, outdated contact info) |
| **Erasure ("Right to be Forgotten")** | Art. 17 | Candidate can request deletion of their data when it is no longer necessary, or they withdraw consent |
| **Restriction of Processing** | Art. 18 | Candidate can request that data be stored but not actively processed (e.g., pending a dispute) |
| **Data Portability** | Art. 20 | Candidate can request their data in a structured, machine-readable format (applies to data provided by the candidate and processed by automated means) |
| **Objection** | Art. 21 | Candidate can object to processing based on legitimate interest; HR must cease unless compelling grounds override |

### Response Protocol

1. Verify the identity of the requester
2. Log the request with date received
3. Respond within **30 calendar days** (extendable by 60 days for complex requests, with notification)
4. Provide the response **free of charge** (except for manifestly unfounded or excessive requests)
5. Document the action taken

---

## 4. Practical Rules for HR Documents

### 4.1 Job Descriptions

| Rule | Rationale |
|---|---|
| List only skills, experience, and qualifications genuinely required for the role | Data minimization; prevents indirect collection of protected data |
| Use gender-neutral language | Avoid sex/gender discrimination signals |
| Do not require "native speaker" status — use "fluent" or "proficient" | "Native" is a proxy for national origin |
| Do not specify age ranges or experience ranges that serve as age proxies | Age discrimination prevention |
| Include only genuine occupational requirements for physical attributes | Disability and health data protection |
| State that reasonable accommodations are available | Demonstrates compliance and inclusivity |

### 4.2 Screening Questionnaires

| Rule | Rationale |
|---|---|
| Collect only: name, contact details, qualifications, work experience, right-to-work status | Data minimization |
| Do NOT ask for: photo, date of birth, nationality, marital status, number of children | Special category / unnecessary data |
| Do NOT ask for: salary history (banned in some jurisdictions) | Potential discrimination perpetuation |
| Include a link to the privacy notice | Transparency obligation |
| Provide opt-in checkbox for talent pool with separate consent text | Purpose limitation; consent must be specific |

### 4.3 Interview Scripts and Question Banks

| Rule | Rationale |
|---|---|
| All questions must relate to job competencies, skills, or experience | Data minimization; prohibited topics avoidance |
| Ban all questions from the prohibited topics list | See `prohibited-topics.md` |
| Structure interviews with a scoring rubric tied to job criteria | Evidence-based evaluation; reduces bias |
| Train interviewers on GDPR-compliant questioning | Accountability principle |

### 4.4 Evaluation Forms

| Rule | Rationale |
|---|---|
| Score candidates against pre-defined, job-relevant criteria only | Purpose limitation; prevents subjective bias |
| Do NOT record observations about appearance, accent, or personal characteristics | Special category data risk |
| Use structured rating scales (e.g., 1-5) with written justification | Facilitates access requests and audit |
| Store evaluations with the same retention policy as other candidate data | Storage limitation |

### 4.5 Retention Policy

| Data Category | Recommended Retention | Basis |
|---|---|---|
| Applications (unsuccessful) | 6 months post-decision | Legitimate interest (defense against discrimination claims) |
| Applications (unsuccessful, extended) | Up to 24 months | Requires explicit consent |
| Talent pool CVs | Maximum 24 months from consent | Consent; renew before expiry |
| Interview notes and evaluations | Same as application data | Consistent retention policy |
| Hired candidate recruitment data | Transfer relevant data to HR file; delete remainder within 3 months | Purpose limitation |

---

## 5. Data Protection Impact Assessment (DPIA)

A DPIA is **required** (Article 35) when recruitment processing is likely to result in a **high risk** to candidates' rights and freedoms. Triggers include:

| Trigger | Example |
|---|---|
| Large-scale processing | Recruiting for 100+ positions simultaneously |
| Automated decision-making with legal effects | AI-powered CV screening that auto-rejects candidates |
| Systematic monitoring | Video interviews with behavioral analysis |
| Special category data processing | Roles requiring health assessments |
| Innovative technology | Gamified assessments, psychometric profiling |
| Cross-border data transfers | Using a recruitment platform hosted outside the EEA |

### DPIA Minimum Content

1. Systematic description of processing operations and purposes
2. Assessment of necessity and proportionality
3. Assessment of risks to candidates' rights and freedoms
4. Measures to address those risks (safeguards, security, mechanisms to ensure GDPR compliance)

---

## 6. Template: Candidate Privacy Notice

Below is a brief, compliant template. Adapt it to your organization's specific details.

```
CANDIDATE PRIVACY NOTICE

Data Controller: [Organization Name]
Contact: [DPO email / HR privacy contact]

1. WHAT DATA WE COLLECT
   We collect: your name, contact details, CV/resume, cover letter, qualifications,
   work history, references (with your consent), and right-to-work documentation.

2. WHY WE COLLECT IT
   To evaluate your application for the role of [position title] and manage our
   recruitment process. Legal basis: legitimate interest (Art. 6(1)(f) GDPR).

3. WHO HAS ACCESS
   Your data is accessible only to the hiring manager and HR team involved in this
   vacancy. We may share data with [recruitment agency / assessment provider] under
   a Data Processing Agreement.

4. HOW LONG WE KEEP IT
   If your application is unsuccessful, we retain your data for [6/12] months to
   comply with legal obligations and defend against potential claims.
   [Optional: With your consent, we may retain your data for up to 24 months in our
   talent pool for future opportunities.]

5. YOUR RIGHTS
   You have the right to: access your data, correct inaccuracies, request deletion,
   restrict processing, receive your data in a portable format, and object to processing.
   To exercise any right, contact [DPO email].

6. COMPLAINTS
   If you believe your data has been mishandled, you may lodge a complaint with
   [national supervisory authority, e.g., Garante per la Protezione dei Dati Personali
   for Italy].

7. CONSENT FOR TALENT POOL (optional)
   [ ] I consent to my data being retained for up to 24 months for consideration
       in future vacancies. I understand I can withdraw this consent at any time.
```

---

## Validation Rules for Compliance-Check Skill

When scanning HR documents for GDPR compliance, flag content that:

1. **Collects unnecessary personal data** — fields or questions not justified by job requirements
2. **Lacks a privacy notice reference** — candidate-facing documents without a link to or inclusion of privacy information
3. **Requests special category data** — any field or question that would elicit Art. 9 data
4. **Uses vague retention language** — e.g., "we keep your data as long as necessary" without a defined period
5. **Implies automated decision-making** without mentioning human oversight or the right to contest
6. **Transfers data internationally** without stating the safeguard mechanism (e.g., SCCs, adequacy decision)

### Severity Levels

| Severity | Description | Example |
|---|---|---|
| CRITICAL | Direct collection of special category data or major transparency failure | Application form with "Religion" field |
| HIGH | Missing privacy notice or undefined retention period | No privacy notice linked in job posting |
| MEDIUM | Unnecessary data collection or vague language | Requesting photo with application |
| LOW | Minor transparency improvement needed | Privacy notice uses overly technical language |
