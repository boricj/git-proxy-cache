#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/git-proxy-cache-shell
source "$SCRIPT_DIR/../src/git-proxy-cache-shell"

assert_eq() {
	local expected="$1"
	local actual="$2"
	local label="$3"

	if [[ "$actual" != "$expected" ]]; then
		printf 'FAIL: %s\n  expected: %s\n  actual:   %s\n' "$label" "$expected" "$actual" >&2
		exit 1
	fi
}

assert_eq "https://user@example.com:8443/git/project.git" "$(censor_url 'https://user:pass@example.com:8443/git/project.git')" "censor strips password"
assert_eq "https://user@example.com/project" "$(censor_url 'https://user@example.com/project')" "censor leaves plain URL alone"
assert_eq "https://user@192.0.2.10/project.git" "$(censor_url 'https://user:pass@192.0.2.10/project.git')" "censor strips password from IPv4 URL"
assert_eq "https://user@[2001:db8::1]/project.git" "$(censor_url 'https://user:pass@[2001:db8::1]/project.git')" "censor strips password from IPv6 URL"

printf 'censor_url tests passed.\n'
