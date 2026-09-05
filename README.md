# VallentaAgent

Remote debug agent for Delphi `Linux64` targets, driven by the
[Vallenta Studio](https://github.com/Vallenta/Studio) VS Code extension. One static binary runs
on the Linux machine, is paired once with a client, and then serves the debug sessions the
extension starts. The release is x86_64 Linux only.

This repository holds the installer and the documentation. The agent itself is attached to each
[release](https://github.com/Vallenta/VallentaAgent/releases); the source is not public.

[Install and run](#install-and-run) · [lldb-server](#lldb-server) · [Pairing](#pairing) ·
[Ports](#ports) · [Running it as a service](#running-it-as-a-service) ·
[Environment of the debugged program](#environment-of-the-debugged-program) ·
[Scratch root outside the home directory](#scratch-root-outside-the-home-directory) ·
[Updating](#updating) · [Removing the agent](#removing-the-agent) · [Security](#security) ·
[Options](#options) · [Reporting problems](#reporting-problems) · [License](#license)

## Install and run

One command. It needs no root and installs nothing outside the home directory. The agent binary
is statically linked, so no shared library, no sshd and no per-project setup are required;
`lldb-server` is the one separate requirement and is covered in the next section. The installer
needs `curl` or `wget` and `sha256sum` or `shasum`.

```sh
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | sh
```

The installer verifies the download against the published SHA256, puts the agent in
`~/.local/lib/vallenta-agent` and links the command into `~/.local/bin`. The command
*Vallenta Studio: Copy Linux Agent Install Command* puts that same line on the clipboard.

To install by hand instead, download the release tarball, unpack it anywhere and make the binary
executable with `chmod +x vallenta-agent`.

Start it with both ports named explicitly. Both have to be reachable from the development
machine, and naming them states the numbers a firewall rule has to allow:

```sh
vallenta-agent --port 64300 --session-port-base 14301
```

Those are the defaults, so plain `vallenta-agent` binds the same ports. See [Ports](#ports) for
what has to be reachable, and what changes when the agent runs in a container.

The startup banner lists the bound ports, the detected environment and the pairing token:

```text
VallentaAgent 0.2.2
Control port : 64300
Session ports: 14301-14336
Scratch root : /home/dev/vallenta-scratch
lldb-server  : /usr/lib/llvm-18/bin/lldb-server (18.1.3)
Machine      : ubuntu 24.04 (glibc 2.39)
Paired clients: 0 (/home/dev/.config/vallenta-agent/authorized_clients.json)
Pairing token: walrus-desert-mesa-metal
```

Logs go to stderr. SIGTERM and SIGINT shut the agent down and stop every session server it
started.

## lldb-server

`lldb-server` is not part of the release; the distribution's own package supplies it. Install it
once:

```sh
sudo apt install lldb        # Debian/Ubuntu
sudo dnf install lldb        # Fedora/RHEL
sudo pacman -S lldb          # Arch
sudo zypper install lldb     # openSUSE
```

Without it the agent still starts, can be paired, and reports the problem to Vallenta Studio —
only debug sessions are refused. The banner line then reads
`lldb-server  : MISSING - debug sessions will be refused`, followed by the install command for
the detected distribution.

Installing it afterwards needs no restart. The agent checks once at startup, and Vallenta Studio
asks it to check again when it next starts a session or tests the connection.

`--lldb-server <PATH>` names a specific binary and takes precedence; otherwise the agent looks
beside its own binary and then on `PATH`. A symlink is resolved to its target in every case,
because `lldb-server` re-executes itself to service a connection and fails when it is reached
through one — which is what `/usr/bin/lldb-server` is on most distributions. The banner therefore
shows the resolved path rather than the one that matched.

## Pairing

The printed token is pasted into Vallenta Studio once, when the Linux target is added. The
extension then holds a client id and a secret, and every later connection authenticates without
further user action by proving it knows the secret; the secret is never transmitted.

- The token changes every time the agent restarts. Already-paired clients keep working; the token
  is only needed to add a new one. `--token <TOKEN>` pins it for CI.
- Five wrong tokens lock pairing for one minute, for every peer rather than only the one that
  failed.
- Local clients (WSL2, a container, an SSH tunnel) are trusted without pairing. A shared machine
  needs `--no-loopback-trust`, since any local user would otherwise have the same access as a
  paired client.

## Ports

**Every port the startup banner names must be reachable from the development machine over the
LAN** — the control port and the whole session range, not just the control port. The agent
assigns one block of session ports per debug session, and Vallenta Studio then connects to those
directly; a session whose block is unreachable fails after pairing has already succeeded.

With the defaults that is **64300** for control and **14301-14336** for sessions: nine ports per
concurrent session, four sessions. `--session-port-base` moves the range and `--max-sessions`
sizes it. The result must stay inside 1024-49151, the user port range lldb-server accepts; the
agent refuses a setting that leaves it.

### In a container

Publish both, and publish them **unchanged**: the host port must have the same number as the
container port. The agent reports the ports it bound inside the container, so a block published
under different numbers sends the debugger to ports nothing is listening on, while the control
port keeps working and the failure looks like a session problem.

```sh
docker run -d --name debug-target -p 64300:64300 -p 14301-14336:14301-14336 <image> sleep infinity
```

The agent is then installed inside the container the same way as on a host, and started there.

No extra privileges are needed — no `--cap-add`, no `--security-opt`. A second agent on the same
host needs a second range: start it with `--port 64400 --session-port-base 14401` and publish
those instead.

## Running it as a service

`--install-service` writes a systemd **user** unit — no root, no system-wide state. Options given
alongside the flag are written into the unit's `ExecStart` when they differ from their defaults,
so the service starts with the same configuration. A default value is left out, which leaves the
next agent version free to change it:

```sh
vallenta-agent --install-service --scratch-root /srv/vallenta --max-sessions 8
```

It prints the three commands that activate the unit. The third, `loginctl enable-linger "$USER"`,
keeps the agent running when no user is logged in; without it a user service stops at logout.

`--uninstall-service` removes the unit and the enable symlink. It does not stop a running
instance — it prints the two commands that finish the removal.

The unit file is written owner-readable only, because `--token` would otherwise leave a pairing
secret in a world-readable file.

## Environment of the debugged program

The debugged program starts with the environment of the agent process, plus the `env` entries of
the launch configuration, which override variables of the same name.

An agent started from a shell passes on what that shell exported. An agent started by systemd
passes on the unit's environment, which does not include what `.bashrc` or `.profile` export.
`Environment=` lines in the unit, or `systemctl --user set-environment NAME=value` before the
agent starts, add a variable there.

## Scratch root outside the home directory

The agent creates its scratch root on demand, which works for any path under `$HOME`. A root
elsewhere — `/srv/vallenta`, `/opt/myapps` — must exist and be owned by the agent's user:

```sh
sudo mkdir -p /srv/vallenta && sudo chown vallenta:vallenta /srv/vallenta
```

Without that the agent still starts and still names the root in its banner; the first debug
session is what fails, with a permission error.

## Updating

Re-running the installer replaces the files in `~/.local/lib/vallenta-agent` with the current
release. **Stop the agent first** — a running process keeps the binary it was started from, so an
update underneath it takes effect only at the next start.

```sh
systemctl --user stop vallenta-agent
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | sh
systemctl --user start vallenta-agent
```

An agent started by hand rather than as a service is stopped with Ctrl-C or
`pkill vallenta-agent`; install, then start it again.

Pairings are preserved across an update. They are stored in
`~/.config/vallenta-agent/authorized_clients.json`, which the installer never touches, so no
machine has to be paired again. The pairing token still changes at every start; it is only needed
to add a client that is not paired yet.

Vallenta Studio copies the install command to the clipboard when it connects to an agent below
the version range it supports, so an update is normally prompted rather than searched for.

To install a specific release instead of the current one, name it in `VALLENTA_AGENT_VERSION`.
The variable is read by the shell that runs the script, so it goes after the pipe:

```sh
curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | VALLENTA_AGENT_VERSION=0.2.2 sh
```

`VALLENTA_AGENT_LIB_DIR` and `VALLENTA_AGENT_BIN_DIR` override the two install directories the
same way.

## Removing the agent

Stop it, remove the systemd unit if one was installed, then delete the program, the command and
the pairing store:

```sh
systemctl --user stop vallenta-agent
vallenta-agent --uninstall-service
rm -rf ~/.local/lib/vallenta-agent ~/.local/bin/vallenta-agent ~/.config/vallenta-agent
```

The last path holds the paired clients, so keeping it leaves a later reinstall already paired.
Deployed programs stay in the scratch root, `~/vallenta-scratch` unless `--scratch-root` moved
it, and are removed separately.

## Security

The connection is authenticated but **not encrypted**: a trusted LAN is assumed, or a tunnel. A
debug session also exposes lldb-server's platform protocol, which can start processes on the
target, so a paired client can do anything the agent's user can. Working directories are confined
to the scratch root, which constrains paths rather than privileges.

**Run the agent as a dedicated, low-privilege user. Never as root.**

## Options

`vallenta-agent --help` lists them all. The most used:

| Option | Meaning |
|---|---|
| `--port` | control port (default 64300) |
| `--session-port-base` | first port of the session pool (default 14301) |
| `--max-sessions` | concurrent debug sessions (default 4) |
| `--scratch-root` | where deployed programs are kept (default `~/vallenta-scratch`) |
| `--lldb-server` | path to lldb-server, if not on `PATH` |
| `--token` | fixed pairing token instead of one generated per start, for CI |
| `--no-loopback-trust` | require pairing from local clients too |
| `--log-level` | error, warn, info, debug or trace (default info) |
| `--install-service` | write a systemd user unit carrying the other options given, then exit |
| `--uninstall-service` | remove that unit, then exit |

## Reporting problems

Bug reports, feature requests and questions belong in the
[Vallenta Studio issue tracker](https://github.com/Vallenta/Studio/issues), which covers the agent
as well as the extension. Linux debugging spans both, and which side a failure comes from is
rarely apparent from a symptom alone.

For a problem on the agent side, the startup banner carries most of what a first answer needs —
agent version, distribution and glibc, `lldb-server` version and path. A run with
`--log-level debug` records what the agent did; remove the pairing token from the output before
posting it.

## License

Proprietary; see [LICENSE](LICENSE). The open-source components the agent is built with are
listed with their notices in [THIRD-PARTY.md](THIRD-PARTY.md).
