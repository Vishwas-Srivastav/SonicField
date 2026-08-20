# Engineering PR & Workflow Protocol

Whenever working on features or bug fixes in this repository, ALWAYS enforce the following protocol:

## 1. Branch Naming
- Always branch off `development`.
- Use the format `<PROJECT_INITIALS>-<NUMBER>` (e.g. `SF-03`, `SF-04`). Avoid `feature/` prefix unless explicitly requested.

## 2. Commit & PR Title Format
- All commit messages AND the Pull Request Title MUST follow [Conventional Commits](https://www.conventionalcommits.org/):
  `feat: <description>` or `fix: <description>` or `chore: <description>` or `docs: <description>`.

## 3. Pull Request Body Structure
All Pull Request descriptions MUST be pre-filled with complete technical details matching `.github/PULL_REQUEST_TEMPLATE.md`:
- `## Summary`: Detailed technical breakdown of changes.
- `## Why`: Problem context and architectural rationale referencing specifications.
- `## Testing`: Empirical proof of unit tests passed, guardrail results, and manual build verification.
- `## Related Work`: Task references (e.g. `Refs SF-03`).
- `## Checklist`: All items checked (`[x]`).

## 4. Verification Guardrails
- Run `./scripts/check-guardrails.sh` before pushing.
- Run `./scripts/build.sh` and `./bin/SonicFieldTests` to confirm zero errors and zero warnings.
