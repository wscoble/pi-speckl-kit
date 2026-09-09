#!/usr/bin/env bash
# verify.sh template - executable DoD for a pi extension rewrite.
# Copy into your extension package, adjust the gate list, run before cutover.
# Exit 0 = gates passed. Gates: topology, offline suite, (--live) boot smokes.
set -u
cd "$(dirname "$0")"
PASS=0; FAIL=0
gate() { local name="$1"; shift
  echo "--- gate: $name"
  if "$@" > /tmp/verify-$$.log 2>&1; then echo "    PASS"; PASS=$((PASS+1))
  else echo "    FAIL"; tail -15 /tmp/verify-$$.log; FAIL=$((FAIL+1)); fi
}

# Gate 1: deployment topology (symlinks resolve into the source tree)
topo() {
  local bad=0
  for name in "${DEPLOY_LINKS[@]:-}"; do
    local link="${DEPLOY_TARGET:?set DEPLOY_TARGET}/${name}"
    [ -L "$link" ] || { echo "  missing/not-symlink: $link"; bad=1; continue; }
    readlink -f "$link" | grep -q "^$PWD" || { echo "  resolves outside tree: $link"; bad=1; }
  done
  return $bad
}
gate "deployment topology" topo

# Gate 2: offline suite (contract shape + differential parity + negatives)
gate "offline test suite" npm test

# Gate 3 (--live): real-loader boot smokes
if [ "${1:-}" = "--live" ]; then
  PI="${PI:-pi}"
  smoke() { local expect="$1"; local prompt="$2"
    timeout 300 "$PI" -p --no-session "$prompt" 2>&1 | grep -q "$expect"
  }
  gate "live boot: primary tool" \
    bash -c 'smoke ALIVE "Call <your-tool>, then reply with exactly: ALIVE <n>"'
fi

echo "=== $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]