# BRIEF.md template - freeze the contract before the code

Copy this into your extension project, fill every section, and require every
contributing agent (and human) to read it first. It is the companion to the
speckl spec, not a replacement.

---

# <Kit/Extension name>: clean-room brief

## Context
<What is being built or rewritten, and why. The incident or motivation, in
two sentences.>

## Frozen contract (source of truth, extracted from the installed runtime)
<paste the exact types from the installed runtime's .d.ts files. Include the
grep commands used to extract them so the freeze is reproducible.>

```ts
// <verbatim from node_modules/.../types.d.ts>
```

## Decisions (approved by <owner>)
1. <scope>
2. <keep/drop decisions>
3. <location>
4. <who owns the cutover step>

## Secrets rules (hard)
- Never read <secrets files>. Never print key values.
- Credentials referenced by NAME only; resolution is an injectable seam so
  tests never touch real credential files.

## Behavior inventory to preserve
<For rewrites: extract, do not invent. Every tool, param, timeout, default,
and quirk the legacy implementation has.>

## Definition of done
1. Offline suite green (contract shape + differential parity + negatives)
2. Regression proof against the real failure (failing-first)
3. Live-boot smoke against the real loader and topology
4. Human review of evidence/claim delta; residual untested paths in writing
5. Rollback artifact preserved; revert command written down
6. `check-public-safe.sh` clean before any publication