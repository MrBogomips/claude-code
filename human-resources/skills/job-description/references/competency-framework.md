# Competency Framework & JD Structure Guide

This reference provides two frameworks for writing job descriptions: **competency-based** for technical roles and **outcome-based** for non-technical roles. It also includes a framework selection guide and the standard JD structure template.

---

## 1. Competency-Based Framework (Technical Roles)

Use this framework when the role requires specific technical skills, domain expertise, or measurable proficiency levels. It focuses on identifying 4-6 core competencies and defining expected proficiency for each.

### 1.1 Identifying Core Competencies

Select 4-6 competencies that are genuinely essential for the role. Apply these filters:

1. **Day-one necessity** — would the person need this competency within the first 30 days?
2. **Differentiation** — does this competency distinguish a successful hire from an unsuccessful one?
3. **Measurability** — can proficiency be assessed in an interview or work sample?
4. **Non-redundancy** — does this competency overlap significantly with another already selected?

If a competency fails two or more filters, demote it to "Preferred Qualifications" rather than "Required."

### 1.2 Technical Competency Examples by Domain

#### Software Engineering
- Programming languages (specify: Python, Java, TypeScript, Go, etc.)
- System design and architecture (distributed systems, microservices, event-driven)
- Testing and quality assurance (TDD, integration testing, CI/CD pipelines)
- Database design and optimization (relational, NoSQL, query tuning)
- API design (REST, GraphQL, gRPC)
- DevOps and deployment (containerization, orchestration, IaC)

#### Data & Analytics
- Data modeling and warehousing (star schema, data lake architecture)
- Statistical analysis and machine learning (regression, classification, NLP)
- Data pipeline engineering (ETL/ELT, streaming, batch processing)
- Visualization and storytelling (dashboards, executive reporting)
- Data governance and quality (lineage, cataloging, validation)

#### Infrastructure & Cloud
- Cloud platform expertise (AWS, Azure, GCP — specify services)
- Networking and security (VPN, firewall, zero-trust architecture)
- Infrastructure as Code (Terraform, CloudFormation, Pulumi)
- Monitoring and observability (logging, metrics, tracing, alerting)
- Capacity planning and cost optimization

#### Security
- Threat modeling and risk assessment
- Application security (OWASP Top 10, secure coding practices)
- Identity and access management (IAM, SSO, MFA)
- Compliance frameworks (ISO 27001, SOC 2, GDPR technical controls)
- Incident response and forensics

### 1.3 Soft Skill Competencies

Include 1-2 soft skill competencies alongside technical ones. Select from:

| Competency | When to include |
|------------|-----------------|
| **Collaboration** | Cross-functional roles, team-based delivery, open-source contributors |
| **Communication** | Client-facing roles, technical writing, architecture decision records |
| **Leadership** | Team leads, tech leads, senior ICs who mentor |
| **Problem-solving** | Roles with ambiguous requirements, R&D, incident response |
| **Adaptability** | Startups, rapidly evolving domains, multi-project environments |
| **Stakeholder management** | Roles bridging technical and business teams |

### 1.4 Proficiency Level Definitions

| Level | Label | Description | Typical experience |
|-------|-------|-------------|--------------------|
| L1 | **Foundational** | Understands core concepts, can perform tasks with guidance, follows established patterns | 0-2 years in the domain |
| L2 | **Intermediate** | Works independently, handles standard scenarios, contributes to design decisions | 2-4 years in the domain |
| L3 | **Advanced** | Designs solutions for complex problems, mentors others, drives technical direction | 4-7 years in the domain |
| L4 | **Expert** | Sets organizational standards, solves novel problems, recognized authority in the field | 7+ years in the domain |

**Important:** Years of experience are indicative, not prescriptive. Some individuals reach L3 in 3 years; others remain at L2 after 6. Use proficiency descriptions, not year counts, in the JD. Year ranges are provided here only as calibration guidance for the JD author.

### 1.5 Behavioral Indicators per Level

For each competency, define observable behaviors at the required proficiency level:

| Level | Behavioral indicator pattern |
|-------|------------------------------|
| **Foundational** | "Applies [skill] to routine tasks following documented procedures. Asks for guidance on edge cases." |
| **Intermediate** | "Independently designs and implements [skill area] solutions for standard use cases. Identifies risks and proposes mitigations." |
| **Advanced** | "Architects [skill area] solutions for complex, cross-system scenarios. Mentors team members and establishes best practices." |
| **Expert** | "Defines organizational strategy for [skill area]. Evaluates emerging technologies and drives adoption decisions. Resolves novel, high-impact problems." |

---

## 2. Outcome-Based Framework (Non-Technical Roles)

Use this framework when the role is defined primarily by the results it delivers rather than specific technical skills. It focuses on responsibilities framed as measurable outcomes.

### 2.1 Action + Object + Purpose Pattern

Every responsibility should follow this structure:

> **[Action verb]** + **[what]** + **[to achieve what purpose]**

Examples:

| Weak (task-based) | Strong (outcome-based) |
|--------------------|------------------------|
| "Manage social media accounts" | "Develop and execute social media campaigns to increase brand engagement by 20% quarter-over-quarter" |
| "Handle customer complaints" | "Resolve customer escalations within 24 hours to maintain a 95%+ satisfaction rating" |
| "Prepare financial reports" | "Produce monthly financial reports and variance analyses to support executive decision-making" |
| "Coordinate meetings" | "Organize cross-departmental meetings and track action items to ensure project milestones are met on schedule" |

### 2.2 Success Metrics by Role Category

| Category | Example metrics |
|----------|----------------|
| **Operations** | Process cycle time, error rate reduction, SLA compliance %, cost per transaction, throughput volume |
| **Marketing** | Lead generation volume, conversion rate, CAC (customer acquisition cost), brand awareness lift, campaign ROI |
| **Finance** | Reporting accuracy %, close cycle time, audit findings count, forecast variance %, compliance rate |
| **Administration** | Response time, stakeholder satisfaction score, event/meeting success rate, document accuracy, vendor management savings |
| **Sales** | Revenue targets, pipeline growth, deal close rate, customer retention rate, average deal size |
| **Customer Success** | NPS/CSAT scores, churn rate, expansion revenue, time-to-value, support ticket resolution time |

### 2.3 Defining "Good" Without Over-Specifying

- **Use ranges, not absolutes** — "Manage a team of 5-10" rather than "Manage a team of exactly 8"
- **Describe impact, not method** — "Improve onboarding completion rate" rather than "Create a 47-slide PowerPoint onboarding deck"
- **Allow for growth** — "Contribute to process improvement initiatives" rather than listing every process
- **Benchmark against outcomes** — "Maintain budget variance within 5%" rather than "Track every expense in Excel"
- **Signal autonomy level** — "Own the end-to-end hiring process" vs. "Support the hiring manager with scheduling"

---

## 3. Framework Selection Guide

Use this decision tree to select the appropriate framework:

```
Is the role primarily defined by specific technical skills or tools?
├── YES → Does the role require measurable proficiency levels?
│   ├── YES → Use COMPETENCY-BASED framework
│   └── NO  → Use HYBRID (competency for tech skills + outcome for responsibilities)
└── NO  → Is the role defined by deliverables and business results?
    ├── YES → Use OUTCOME-BASED framework
    └── NO  → Use HYBRID (outcome for responsibilities + competency for any required skills)
```

**Hybrid approach:** List 2-3 technical competencies with proficiency levels, then frame responsibilities using the outcome-based pattern. This works well for roles like product managers, technical project managers, and data analysts.

### Quick Reference

| Role type | Framework | Example roles |
|-----------|-----------|---------------|
| Pure technical | Competency-based | Backend engineer, DevOps engineer, security analyst |
| Pure non-technical | Outcome-based | Office manager, marketing coordinator, HR generalist |
| Hybrid | Both frameworks | Product manager, technical writer, data analyst, solutions architect |

---

## 4. JD Structure Template

Every job description must follow this structure. Sections may be renamed to match corporate style but all content areas must be present.

### Section 1: About the Role

- Role title (gender-neutral)
- Department and team
- Location (on-site / hybrid / remote) with any geographic constraints
- Reporting line (title, not name)
- Employment type (full-time, part-time, contract) and duration if fixed-term
- 2-3 sentence summary of the role's purpose and impact

### Section 2: Key Responsibilities

- 5-8 responsibilities (not more)
- Technical roles: frame as competency applications ("Design and implement...")
- Non-technical roles: frame as outcomes ("Drive X to achieve Y...")
- Order by importance, not frequency

### Section 3: Required Qualifications

- **Hard limit: 8 maximum** (see requirements inflation check)
- Technical roles: list competencies with proficiency level (e.g., "Advanced proficiency in Python")
- Non-technical roles: list outcome-enabling qualifications
- Prefer demonstrated ability over credentials (e.g., "Demonstrated ability to manage cross-functional projects" over "PMP certification")
- Do not use years of experience as a primary filter — use proficiency descriptions instead

### Section 4: Preferred Qualifications

- 3-5 nice-to-haves that genuinely differentiate candidates
- Clearly separate from required — candidates should not self-select out based on preferred items
- Include growth areas: "Interest in learning [technology/domain]"

### Section 5: What We Offer

- Compensation range (where legally required or culturally expected)
- Benefits highlights (top 3-5)
- Growth and development opportunities
- Work environment and culture signals (concrete, not buzzwords)
- Flexibility and work-life balance specifics

### Section 6: Equal Opportunity Statement

- Mandatory in all JDs
- Must be jurisdiction-appropriate
- Include reasonable accommodation language
- Reference specific anti-discrimination laws if required by jurisdiction

**Template (Italian jurisdiction):**

> [Company] e un datore di lavoro che garantisce pari opportunita. Tutte le candidature sono valutate senza distinzione di sesso, eta, origine etnica, orientamento sessuale, identita di genere, stato civile, disabilita, opinioni politiche, appartenenza sindacale, credo religioso o qualsiasi altra caratteristica protetta dalla legge (D.Lgs. 198/2006, D.Lgs. 215/2003, D.Lgs. 216/2003). Invitiamo a non includere nel curriculum informazioni personali non pertinenti alla posizione (fotografia, data di nascita, stato civile). Saranno garantiti ragionevoli adattamenti per candidati con disabilita.

**Template (English / general):**

> [Company] is an equal opportunity employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, sexual orientation, gender identity, national origin, disability, or veteran status. We are committed to providing reasonable accommodations to individuals with disabilities throughout the application and employment process.
