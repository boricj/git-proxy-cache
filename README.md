# git-proxy-cache

A read-only Git SSH proxy that caches remote repositories locally and serves them to clients.

## Setup

1. Install `git` and `bash`.
2. Install the shell with either `sudo make install` or by copying `src/git-proxy-cache-shell` to `/usr/local/bin/`.
3. Point the dedicated Git account's login shell at `/usr/local/bin/git-proxy-cache-shell`.
4. Create the cache directory used by the script: `/var/lib/git`.
5. Add a client-side rewrite so Git sends matching URLs through the proxy while preserving the original URL in the SSH command, for example:

```bash
git config --global url."ssh://git@your-host.example/https://".insteadOf "https://"
```
6. If the proxy host itself needs credentials to reach upstream remotes (for example a PAT), add matching `insteadOf` rules in the dedicated git user's Git configuration on the proxy host.

## Test Suite

Run the unit tests:

```bash
make test
```
