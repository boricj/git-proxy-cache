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

assert_fails() {
	local label="$1"
	shift

	if "$@" >/dev/null 2>&1; then
		printf 'FAIL: %s\n  command unexpectedly succeeded\n' "$label" >&2
		exit 1
	fi
}

assert_eq "example.com:8443/git/project.git" "$(url_to_path 'https://user@example.com:8443/git/project.git')" "https URL with port and no password"
assert_eq "example.com/project.git" "$(url_to_path 'https://user@example.com/project')" "https URL without port"
assert_eq "192.0.2.10/project.git" "$(url_to_path 'https://192.0.2.10/project')" "IPv4 URL without port"
assert_eq "[2001:db8::1]/project.git" "$(url_to_path 'https://user@[2001:db8::1]/project.git')" "IPv6 URL without port"
assert_eq "example.com/project.git" "$(url_to_path 'git://git@example.com/project')" "git scheme"
assert_eq "example.com/project.git" "$(url_to_path 'ssh://user@example.com/project/')" "ssh scheme with trailing slash"
assert_eq "example.com/Project.git" "$(url_to_path 'https://user@example.com/Project')" "https URL preserves path case"
assert_eq "example.com/project.git" "$(url_to_path '/ssh://user@example.com/project/')" "slash-prefixed ssh URL"
assert_eq "example.com/project.git" "$(url_to_path 'ssh://user@example.com:22/project.git')" "ssh default port normalized away"
assert_eq "[2001:db8::1]:8443/project.git" "$(url_to_path 'https://user@[2001:db8::1]:8443/project.git')" "IPv6 URL with non-default port"
assert_eq "example.com/project.git" "$(url_to_path 'https://user@example.com:443/project.git')" "https default port normalized away"
assert_eq "example.com/project.git" "$(url_to_path 'http://user@example.com:80/project.git')" "http default port normalized away"
assert_eq "example.com/project.git" "$(url_to_path 'git://user@example.com:9418/project.git')" "git default port normalized away"
assert_eq "example.com:443/project.git" "$(url_to_path 'http://user@example.com:443/project.git')" "http on non-default port remains distinct"
assert_eq "example.com:80/project.git" "$(url_to_path 'https://user@example.com:80/project.git')" "https on non-default port remains distinct"
assert_eq "example.com/project.git" "$(url_to_path '/https://user@example.com/project.git')" "slash-prefixed https URL"
assert_eq "example.com/project.git" "$(url_to_path 'git@example.com:/project.git')" "absolute SCP path"
assert_eq "example.com/project.git" "$(url_to_path 'git@example.com:project.git')" "relative SCP path accepted as root-relative"
assert_eq "$(url_to_path 'git@example.com:/project.git')" "$(url_to_path 'git@example.com:project.git')" "relative and absolute SCP paths normalize identically"
assert_eq "github.com/boricj/ghidra-delinker-extension.git" "$(url_to_path 'git@github.com:boricj/ghidra-delinker-extension.git')" "GitHub-style relative SCP path accepted"
assert_eq "" "$(url_to_path '../project.git')" "path traversal rejected"
assert_eq "" "$(url_to_path 'https://user@example.com/../project.git')" "embedded traversal rejected"
assert_eq "" "$(url_to_path 'ftp://user@example.com/project.git')" "unsupported protocol rejected"

printf 'url_to_path tests passed.\n'
