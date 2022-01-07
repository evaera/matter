---
sidebar_position: 2
---

# Installation

## Wally package manager

1. Install [Wally](https://wally.run) with [Foreman](https://github.com/Roblox/foreman).

```toml title="foreman.toml"
wally = { source = "UpliftGames/wally", version = "0.3.1" }
```

2. If you don't have a `wally.toml` file, run `wally init`.
3. Add matter under `[dependencies]`. Copy the latest version from [this page](https://wally.run/package/evaera/matter).

```toml title="wally.toml"
[package]
name = "biff/package"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
matter = "evaera/matter@X.X.X" # Don't copy this. This won't work.
                               # Copy real string from page linked above.
```

4. Run `wally install`.
5. Sync in the `Packages` folder with [Rojo](https://rojo.space).

## Manual

1. Download `matter.rbxm` from the [latest release](https://github.com/UpliftGames/moonwave/releases/latest).
2. Sync in with [Rojo](https://rojo.space) or import into Roblox Studio manually.

