#!/usr/bin/env bash
# Top-level orchestrator. Steps:
#   1. Generate variants (copy from test-variants/ into a fresh run dir)
#   2. Render to SVG + PNG
#   3. (Agent responsibility) Dispatch adversarial reviewers — NOT done here
#   4. Aggregate reviews (must be run after reviews exist)
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$SKILL_DIR/scripts"

echo "1/3 Generating variants…"
"$SCRIPTS/generate-variants.sh"
RUN_DIR="$(cat /tmp/plantuml-tests-latest)"

echo
echo "2/3 Rendering…"
"$SCRIPTS/render-variants.sh" "$RUN_DIR" || echo "(render had failures — see above)"

echo
echo "3/3 Reviewer dispatch is an agent step."
echo "See SKILL.md §\"Test harness — reviewer dispatch\" for the protocol."
echo
echo "After agent produces review.md files, run:"
echo "  $SCRIPTS/aggregate-reviews.sh $RUN_DIR"
echo
echo "Run directory: $RUN_DIR"
