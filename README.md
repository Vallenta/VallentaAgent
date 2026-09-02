# VallentaAgent

Remote debug agent for Delphi `Linux64` targets, driven by the
[Vallenta Studio](https://github.com/Vallenta/Studio) VS Code extension. One static binary runs
on the Linux machine, is paired once with the token it prints, and then serves debug sessions
started from Windows.

This repository holds the installer and the documentation. The agent itself is attached to each
[release](../../releases); the source is not public.

## Install and run

One command. It needs no root, installs nothing outside the home directory, and pulls in no
dependencies — no sshd, no Python, no package manager, no per-project setup.

```
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | sh
```

The installer verifies the download against the published SHA256, puts the agent in
`~/.local/lib/vallenta-agent` and links the command into `~/.local/bin`. In Vallenta Studio, the
command *Copy Linux Agent Install Command* puts that line on the clipboard.

**`lldb-server` is not included** — the distribution supplies it, and the agent names the package
to install for the distribution it detects. See the next section.

To install by hand instead, download the release tarball, unpack it anywhere and run the binary.

```
chmod +x vallenta-agent
./vallenta-agent
```

```
VallentaAgent 0.2.0
Control port : 64300
Session ports: 14301-14336
Scratch root : /home/dev/vallenta-scratch
lldb-server  : /usr/bin/lldb-server (18.1.3)
Machine      : ubuntu 24.04 (glibc 2.39)
Paired clients: 0 (/home/dev/.config/vallenta-agent/authorized_clients.json)
Pairing token: walrus-desert-mesa-metal
```

## lldb-server

The agent needs `lldb-server`, which the distribution packages. Install it once:

```
sudo apt install lldb        # Debian/Ubuntu
sudo dnf install lldb        # Fedora/RHEL
sudo pacman -S lldb          # Arch
sudo zypper install lldb     # openSUSE
```

Without it the agent still starts, can be paired, and reports the problem to Vallenta Studio —
only debug sessions are refused. The startup banner then reads
`lldb-server  : MISSING - debug sessions will be refused` and prints the command for the detected
distribution.

Installing it afterwards needs no restart. The agent checks once at startup, and Vallenta Studio
asks it to look again when it next starts a session or tests the connection.

The agent looks for `lldb-server` next to its own binary and then on `PATH`;
`--lldb-server <path>` points it somewhere specific. It must be the real path rather than a
versioned symlink — `/usr/lib/llvm-18/bin/lldb-server` rather than `/usr/bin/lldb-server-18` —
because `lldb-server` re-executes itself to service a connection and a symlink can leave it
unable to find itself.

## Pairing

The printed token is pasted into Vallenta Studio once, when the Linux target is added. The
extension then holds a client id and a secret, and every later connection authenticates silently
by proving it knows the secret — the secret itself never travels.

- The token changes every time the agent restarts. Already-paired clients keep working; the token
  is only needed to add a new one. `--token <fixed>` pins it for CI.
- Five wrong tokens lock pairing for a minute.
- Local clients (WSL2, a container, an SSH tunnel) are trusted without pairing. A shared machine
  needs `--no-loopback-trust`, since any local user would otherwise have the same access as a
  paired client.

## Running it as a service

`--install-service` writes a systemd **user** unit — no root, no system-wide state. The unit
reproduces the options given alongside the flag, so the agent is installed the way it is meant to
run:

```
vallenta-agent --install-service --port 64300 --scratch-root /srv/vallenta
```

It prints the three commands that activate the unit. The third one,
`loginctl enable-linger "$USER"`, is what keeps the agent running when nobody is logged in;
without it a user service stops at logout.

`--uninstall-service` removes the unit and the enable symlink. It does not stop a running
instance — it prints the command that does.

The unit file is written owner-readable only, because `--token` would otherwise leave a pairing
secret in a world-readable file.

## Scratch root outside the home directory

The agent creates its scratch root itself, which works for any path under `$HOME`. A root
elsewhere — `/srv/vallenta`, `/opt/myapps` — must exist and be owned by the agent's user before
the first start, or the agent stops with a permission error:

```
sudo mkdir -p /srv/vallenta && sudo chown vallenta:vallenta /srv/vallenta
```

## Firewall

Two things are opened to the development machine: the control port (64300) and the session range
shown at startup (14301-14336 by default — one block of nine ports per concurrent debug session).
The session range must stay within 1024-49151; lldb-server refuses anything higher.

## Security

The connection is authenticated but **not encrypted** in this version — a trusted LAN is assumed,
or a tunnel. More importantly, the debug protocol includes running commands on the target, so a
paired client can do anything the agent's user can. Working directories are kept under the
scratch root, but that is tidiness rather than a sandbox.

**Run the agent as a dedicated, low-privilege user. Never as root.**

## Options

`vallenta-agent --help` lists them all. The ones that matter most:

| Option | Meaning |
|---|---|
| `--port` | control port (default 64300) |
| `--scratch-root` | where deployed programs are kept |
| `--lldb-server` | path to lldb-server, if not next to the binary |
| `--session-port-base` | first port of the session pool (default 14301) |
| `--max-sessions` | concurrent debug sessions (default 4) |
| `--no-loopback-trust` | require pairing from local clients too |
| `--log-level` | error, warn, info, debug or trace |
| `--install-service` | write a systemd user unit carrying the other options given, then exit |
| `--uninstall-service` | remove that unit, then exit |

Logs go to stderr. SIGTERM and SIGINT shut the agent down and stop every session server it
started.

## Reporting problems

Bug reports, feature requests and questions belong in the
[Vallenta Studio issue tracker](https://github.com/Vallenta/Studio/issues), which covers the agent
as well as the extension. Linux debugging spans both, and which side a failure comes from is
rarely apparent from the outside.

For a problem on the agent side, the startup banner answers most of the first questions — agent
version, distribution and glibc, `lldb-server` version and path. A run with `--log-level debug`
adds the rest; remove the pairing token before pasting it.

## License

Proprietary; see [LICENSE](LICENSE). The open-source components the agent is built with are
listed with their notices in [THIRD-PARTY.md](THIRD-PARTY.md).
