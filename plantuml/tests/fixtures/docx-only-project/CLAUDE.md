# docx-only-project

Fixture for the plantuml plugin tests: a Policy that declares only the docx target,
a built-in theme (so no brand colors), and non-default layout, direction and font size.

## PlantUML Policy

- **Primary target**: `docx`             # web | docx | pdf | pptx
- **Additional targets**: none
- **Theme**: `cerulean-outline`          # built-in theme: brand colors not required
- **Layout engine**: `elk`               # smetana | elk | dot
- **Default direction**: `left-to-right`
- **Default detail level**: `standard`
- **Label language**: `en`
- **Font family**: `Inter, Arial, sans-serif`
- **Base font size**: `16`
- **Max width (docx)**: `5000`
- **Recorded on**: `2026-09-29`

## Unrelated section

Keys outside the Policy section are ignored:

- **Primary target**: `web`
