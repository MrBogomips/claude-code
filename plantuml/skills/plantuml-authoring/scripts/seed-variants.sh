#!/usr/bin/env bash
# Seed test-variants/<type>/{minimal,standard,detailed}.puml from the
# snippet inside each diagrams/<type>.md.
# Standard = snippet as-is, with its ../.plantuml/ includes rewritten to
# .plantuml/: generate-variants.sh puts the templates next to each variant.
# Minimal and detailed are seeded from the standard with a TODO marker;
# they require hand-editing per type.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAR_DIR="$SKILL_DIR/test-variants"
DIAG_DIR="$SKILL_DIR/diagrams"

mkdir -p "$VAR_DIR"

for f in "$DIAG_DIR"/*.md; do
  type=$(basename "$f" .md)
  [ "$type" = "INDEX" ] && continue

  # Extract the first @start.../@end... block from the file.
  block=$(awk '
    /^@start(uml|mindmap|wbs|gantt|salt|json|yaml|nwdiag)/ { p=1 }
    p { print }
    /^@end(uml|mindmap|wbs|gantt|salt|json|yaml|nwdiag)/ { if (p) { p=0; exit } }
  ' "$f")

  if [ -z "$block" ]; then
    echo "SKIP $type: no @start/@end block"
    continue
  fi

  mkdir -p "$VAR_DIR/$type"

  # Variants live one directory deeper than the snippets assume, next to a
  # copy of the templates; no absolute path is written into them.
  std="$VAR_DIR/$type/standard.puml"
  echo "$block" | sed 's|!include \(\.\./\)*\.plantuml/|!include .plantuml/|g' > "$std"

  # Minimal and detailed variants require hand-editing.
  if [ ! -f "$VAR_DIR/$type/minimal.puml" ]; then
    cp "$std" "$VAR_DIR/$type/minimal.puml"
    printf "\n' TODO: reduce to minimal variant (<= 1/3 of standard)\n" >> "$VAR_DIR/$type/minimal.puml"
  fi
  if [ ! -f "$VAR_DIR/$type/detailed.puml" ]; then
    cp "$std" "$VAR_DIR/$type/detailed.puml"
    printf "\n' TODO: expand to detailed variant (1.5-2x standard with notes)\n" >> "$VAR_DIR/$type/detailed.puml"
  fi

  echo "Seeded $type"
done

echo
echo "Done. Hand-edit minimal and detailed per type before running the test suite."
