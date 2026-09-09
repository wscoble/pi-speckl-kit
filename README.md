# @wscoble/pi-speckl-kit

Spec-first development kit for [pi](https://pi.dev) extensions. Write the
behavior contract before the code: a [speckl](https://github.com/wscoble/speckl)
`.speckdl` spec is the source of truth, the extension implements it, tests
are the spec's constraints made executable, and publication is gated - not promised.

## The pattern

```
.speckdl spec ──→ compiled constraints ──→ executable tests (DoD)
      │                                     │
      └── frozen runtime contract ──────────┴── live-boot smoke gates
```

1. **Freeze the contract** - exact runtime types extracted from the
   installed pi runtime, never from memory or docs
2. **Author the speckl spec** - types, actions, constraints; compile to
   validate
3. **Tests = constraints, executed** - mock-host contract tests, differential
   parity against any legacy implementation, negative + hostile-input tests
4. **Regression proof** - reproduce the original defect, failing-first
5. **Live-boot smoke** - mocks prove the contract; only a real boot proves
   the deployment topology
6. **Human review of the evidence/claim delta** - "too easy" is a valid
   test result
7. **Rollback artifact** - preserve what you replace

## Install

```bash
pi install git:github.com/wscoble/pi-speckl-kit@v0.1.0
```

This ships the `speckl-extension` skill: your pi agent can then drive the
full workflow above for new extensions and rewrites.

## What's in the kit

| Path | What it is |
|---|---|
| `skills/speckl-extension/` | The workflow skill: contract freeze → spec → tests → regression → live smoke → sign-off |
| `examples/PiExtensionContract.speckdl` | Worked example: the tool-result contract (the no-crash rule) as enforceable speckl constraints |
| `templates/BRIEF.md` | Skeleton for freezing the runtime contract + behavior inventory + DoD |
| `templates/verify.sh` | Executable DoD: topology gate, offline suite, `--live` boot smokes |

## Prerequisites

- [speckl](https://github.com/wscoble/speckl) - spec compiler (nix flake:
  `nix run github:wscoble/speckl`, or build from source)
- Pair with [`pi-tool-result-kit`](https://github.com/wscoble/pi-tool-result-kit)
  for contract-safe tool results (`agentResult` / `registerToolSpec`)

## The bug that motivated this kit

pi extensions whose `registerTool` execute returns `{ output: string }`
instead of `AgentToolResult` crash pi's renderer session-fatally on first
render - including on their *error* results. This kit's example spec
(`PiExtensionContract.speckdl`) encodes the no-crash rule as a formal
constraint; the companion kit provides the helpers that make the broken
shape structurally impossible.

## License

MIT