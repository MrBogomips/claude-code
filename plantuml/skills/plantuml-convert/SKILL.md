---
name: plantuml-convert
description: Convert PlantUML (.puml) files to PNG, SVG, or PDF using the CLI. Use when rendering or exporting diagrams, or when document skills (.docx, .pdf, .pptx) need diagram images as input.
compatibility: Requires plantuml and java CLI tools installed (macOS: brew install plantuml)
model: claude-haiku-4-5-20251001
allowed-tools: Bash
---

# PlantUML Converter

Convert PlantUML `.puml` files to image formats suitable for embedding in documents.

## Prerequisites

PlantUML CLI must be installed. On macOS:

```bash
brew install plantuml
```

If `plantuml` is not found, tell the user to install it before proceeding.

## Default Configuration

| Setting        | Default  | Rationale                                              |
|----------------|----------|--------------------------------------------------------|
| Output format  | PNG      | Best compatibility with Word, PowerPoint, and PDF      |
| Scale          | 3        | High-resolution output; crisp when printed or zoomed   |

## Conversion Command

The core command for a single file:

```bash
plantuml -t<format> -Sscale=<scale> -o <output_dir> <input_file>
```

- `<format>`: `png` (default), `svg`, `pdf`, `eps`, `txt`
- `<scale>`: integer, default `3`. Higher values = larger/crisper images.
- `<output_dir>`: **absolute path** to the output directory. PlantUML requires this to be absolute when using `-o`.
- `<input_file>`: path to the `.puml` file.

## Workflow

### Single file conversion

```bash
mkdir -p /absolute/path/to/output
plantuml -tpng -Sscale=3 -o /absolute/path/to/output path/to/diagram.puml
```

### Batch conversion (all .puml in a directory)

```bash
PUML_DIR="path/to/puml/files"
OUTPUT_DIR="$(pwd)/output/diagrams"
mkdir -p "$OUTPUT_DIR"
for puml in "$PUML_DIR"/*.puml; do
  [ -f "$puml" ] || continue
  echo "Converting: $(basename "$puml")"
  plantuml -tpng -Sscale=3 -o "$OUTPUT_DIR" "$puml"
done
```

### SVG conversion (for web or scalable contexts)

When the target is a web page or a context that supports vector graphics, use SVG:

```bash
plantuml -tsvg -o /absolute/path/to/output input.puml
```

Note: `-Sscale` has no effect on SVG since SVG is vector-based.

## Integration with Document Creation

When a document skill (/docx, /pdf, /pptx) needs diagram images:

1. **Identify** which .puml files are referenced or needed for the document.
2. **Convert** them to PNG (scale 3) into a suitable output directory.
3. **Reference** the generated PNG paths when assembling the document.

## Output Naming

PlantUML names output files based on the `@startuml Title` directive inside the `.puml` file, not the source filename. For example, a file `my-diagram.puml` containing `@startuml My_Diagram` produces `My_Diagram.png`. If no title is given, the output filename matches the source filename.

## Overriding Defaults

The user may override defaults per invocation:

- **Format**: "convert to SVG" → use `-tsvg`
- **Scale**: "use scale 5" → use `-Sscale=5`
- **Output directory**: "put them in /tmp/diagrams" → use `-o /tmp/diagrams`

Confirm non-default settings with the user if ambiguous.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `plantuml: command not found` | Run `brew install plantuml` |
| Blank or broken output | Check .puml syntax with `plantuml -checkonly file.puml` |
| Output filename unexpected | Check `@startuml Title` in the .puml file |
| Java errors | PlantUML needs Java; run `java -version` to verify |
