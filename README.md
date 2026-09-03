# VallentaAgent

Remote debug agent for Delphi `Linux64` targets, driven by the
[Vallenta Studio](https://github.com/Vallenta/Studio) VS Code extension. One static binary runs
on the Linux machine, is paired once with the token it prints, and then serves debug sessions
started from Windows.

This repository holds the installer and the documentation. The agent itself is attached to each
[release](https://github.com/Vallenta/VallentaAgent/releases); the source is not public.

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

To install by hand instead, download the release tarball, unpack it anywhere and make the binary
executable with `chmod +x vallenta-agent`.

Start it with the two ports written out, because both have to be reachable from the development
machine and it is easier to open a firewall for numbers that are on the command line:

```
vallenta-agent --port 64300 --session-port-base 14301
```

Those are the defaults, so plain `vallenta-agent` does the same thing. See [Ports](#ports) for
what has to be reachable, and what changes when the agent runs in a container.

It prints what it bound, what it found, and the token to pair with:

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

## Updating

Re-running the installer replaces the files in `~/.local/lib/vallenta-agent` with the current
release. **Stop the agent first** — a running process keeps the binary it started with, so an
update underneath it changes nothing until the next start.

```
systemctl --user stop vallenta-agent
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | sh
systemctl --user start vallenta-agent
```

Started by hand rather than as a service, stop it with Ctrl-C or `pkill vallenta-agent`, install,
and start it again.

Paired clients survive an update. They are stored in
`~/.config/vallenta-agent/authorized_clients.json`, which the installer never touches, so no
machine has to be paired again. The pairing token still changes at every start, as it always
does; it is only needed to add a client that is not paired yet.

Vallenta Studio offers this command when it meets an agent too old for it to talk to, so an
update is usually prompted rather than looked for.

To install a specific release instead of the current one, name it — the variable is read by the
shell that runs the script, so it goes after the pipe:

```
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | VALLENTA_AGENT_VERSION=0.2.0 sh
```

## Scratch root outside the home directory

The agent creates its scratch root itself, which works for any path under `$HOME`. A root
elsewhere — `/srv/vallenta`, `/opt/myapps` — must exist and be owned by the agent's user before
the first start, or the agent stops with a permission error:

```
sudo mkdir -p /srv/vallenta && sudo chown vallenta:vallenta /srv/vallenta
```

## Ports

**Every port the startup banner names must be reachable from the development machine over the
LAN** — the control port and the whole session range, not just the control port. The agent hands
the client one block of session ports per debug session, and Vallenta Studio then connects to
those directly; a session whose block is unreachable fails after pairing has already succeeded.

With the defaults that is **64300** for control and **14301-14336** for sessions: nine ports per
concurrent session, four sessions. `--max-sessions` and `--session-port-base` move the range,
which must stay within 1024-49151 — lldb-server refuses anything higher.

### In a container

Publish both, and publish them **unchanged**: the host port must have the same number as the
container port. The agent reports the ports it bound inside the container, so a block published
under different numbers sends the debugger to ports nothing is listening on, while the control
port alone appears to work.

```
docker run -d --name debug-target -p 64300:64300 -p 14301-14336:14301-14336 <image> sleep infinity
```

No extra privileges are needed — no `--cap-add`, no `--security-opt`. A second agent on the same
host needs a second range: start it with `--port 64400 --session-port-base 14401` and publish
those instead.

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

Proprietary; see [LICENSE](https://github.com/Vallenta/VallentaAgent/blob/main/LICENSE). The
open-source components the agent is built with are listed with their notices in
[THIRD-PARTY.md](https://github.com/Vallenta/VallentaAgent/blob/main/THIRD-PARTY.md).
