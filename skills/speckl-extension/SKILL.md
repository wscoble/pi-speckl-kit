---
name: speckl-extension
description: Spec-first development workflow for pi extensions. Use when building or rewriting a pi extension: freeze the runtime contract, author a speckl .speckdl behavior contract, turn constraints into executable tests (mock-host contract tests, differential parity, hostile-input negatives), prove regression failing-first, gate with live-boot smokes, and route cutover through human sign-off.
license: MIT
---

# speckl-extension - spec-first pi extension development

Write the behavior contract BEFORE the code. The speckl spec is the source of
truth; the extension implements it; tests are the spec's constraints made
executable; publication is gated, not promised.

## When to use

- Building a new pi extension with non-trivial behavior (state, permissions,
  error semantics)
- Rewriting an existing extension (spec first, then differential parity)
- Any change where "it works" needs to mean something checkable

## Workflow (in order, all required)

### 1. Freeze the contract

Extract the exact runtime types from the INSTALLED pi runtime - never from
memory or docs (they drift). Source of truth example:

```bash
# AgentToolResult + ToolDefinition live in the published package types
grep -n -A8 "interface AgentToolResult" node_modules/@earendil-works/pi-agent-core/dist/types.d.ts
grep -n -A20 "interface ToolDefinition" node_modules/@earendil-works/pi-coding-agent/dist/core/extensions/types.d.ts
```

Write these verbatim into a `BRIEF.md` alongside the behavior inventory and
the definition of done. This file is the spec's companion, not a replacement.

### 2. Author the speckl spec

Write `<Domain>.speckdl` capturing: types (mirrors of the runtime contract),
state, actions (what may happen, with requires), and constraints (what must
always hold). Constraint style guidance lives in the kit's examples. Compile
it to catch syntax/type errors:

```bash
speckl check specs/<Domain>.speckdl   # or the flake: nix run ~/Projects/speckl
```

### 3. Tests are the constraints, executed

- Mock-host contract tests: register every tool through a mock `pi`, call
  `execute`, assert the result shape against the frozen contract.
- Functional tests per tool: fixtures for local work, mocked network for
  anything remote. Offline by construction.
- Negative tests: malformed args, missing creds, network failure, hostile
  payloads (non-JSON, 5xx, wrong-shape bodies).
- Differential tests: if a legacy implementation exists, run IDENTICAL
  inputs through legacy and rebuild side by side and diff outputs. Byte
  parity on happy paths; error-path parity with documented message drift.

### 4. Regression proof against the real failure

Reproduce the original defect against the unpatched runtime and prove the
fix survives it. A fix without a failing-first test is a hypothesis.

### 5. Live-boot smoke against the REAL loader

Mocks prove the contract; only a real boot proves the deployment. Run the
actual binary with the actual deployment topology and exercise the exact
path that failed historically. Headless works:

```bash
pi -p --no-session -e <your-package> "call <tool>, reply ALIVE <n>"
```

### 6. Human review of the evidence/claim delta

A person other than the producing agent compares what the evidence covers
against what is about to be claimed. "Too easy" is a valid test result.
The agent states residual untested paths in writing - never silently dropped.

### 7. Rollback artifact

Preserve what you replace; write the revert command down before cutover.

## Anti-patterns this skill exists to prevent (all observed, all costly)

- **Mock-green ≠ deployed.** Import path resolution, loader topology, and
  symlinks exist only in reality. A suite can be 30/30 while the extension
  is dead at boot.
- **Checking one branch is checking nothing.** Publication scans must
  enumerate ALL git refs (branches, tags) - leaks live in side branches.
- **Clever pattern matching loses to dumb invariants.** "No reference to X
  at all" beats a verb-regex around X.
- **The agent cannot approve its own work.** Sign-off artifacts must be
  human-writable only; make self-approval a deliberate act of evasion, not
  an accident.

## Tooling

- speckl compiler: https://github.com/wscoble/speckl (nix flake, `speckl` binary)
- contract-safe results: https://github.com/wscoble/pi-tool-result-kit
- templates in this kit: `templates/` (BRIEF.md skeleton, verify.sh skeleton)