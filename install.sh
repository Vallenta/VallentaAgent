#!/bin/sh
# VallentaAgent installer.
#
#   curl -fsSL https://github.com/Vallenta/VallentaAgent/releases/latest/download/install.sh | sh
#
# Installs into $HOME, never needs sudo, and touches nothing outside the two
# directories printed at the end. POSIX sh on purpose: the target machine is
# only promised a shell, not bash.
set -eu

# Release location. VALLENTA_AGENT_BASE_URL points the script at a local or
# staging copy instead.
REPO_URL="https://github.com/Vallenta/VallentaAgent"
VERSION="${VALLENTA_AGENT_VERSION:-latest}"
if [ -n "${VALLENTA_AGENT_BASE_URL:-}" ]; then
    BASE_URL="$VALLENTA_AGENT_BASE_URL"
elif [ "$VERSION" = "latest" ]; then
    BASE_URL="$REPO_URL/releases/latest/download"
else
    BASE_URL="$REPO_URL/releases/download/v$VERSION"
fi

LIB_DIR="${VALLENTA_AGENT_LIB_DIR:-$HOME/.local/lib/vallenta-agent}"
BIN_DIR="${VALLENTA_AGENT_BIN_DIR:-$HOME/.local/bin}"

die() {
    echo "vallenta-agent install: $1" >&2
    exit 1
}

arch=$(uname -m)
[ "$arch" = "x86_64" ] || die "this release is x86_64 only; this machine reports $arch"
[ "$(uname -s)" = "Linux" ] || die "the agent runs on Linux only; this machine reports $(uname -s)"

if command -v curl >/dev/null 2>&1; then
    fetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -qO "$2" "$1"; }
else
    die "neither curl nor wget is installed"
fi

if command -v sha256sum >/dev/null 2>&1; then
    checksum() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
    checksum() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
    die "neither sha256sum nor shasum is installed - cannot verify the download"
fi

TARBALL="vallenta-agent-x86_64-musl.tar.gz"

tmp=$(mktemp -d "${TMPDIR:-/tmp}/vallenta-agent.XXXXXX")
trap 'rm -rf "$tmp"' EXIT INT TERM

echo "Downloading $TARBALL"
fetch "$BASE_URL/$TARBALL" "$tmp/$TARBALL" || die "download failed: $BASE_URL/$TARBALL"
fetch "$BASE_URL/$TARBALL.sha256" "$tmp/$TARBALL.sha256" ||
    die "checksum file missing: $BASE_URL/$TARBALL.sha256"

expected=$(cut -d' ' -f1 <"$tmp/$TARBALL.sha256")
actual=$(checksum "$tmp/$TARBALL")
[ "$expected" = "$actual" ] || die "checksum mismatch: expected $expected, got $actual"

# Unpacked into its own directory so the payload never mixes with the download:
# a tarball without a top-level directory would otherwise make $tmp the payload,
# and the archive and its checksum would be installed along with the binaries.
mkdir "$tmp/unpacked"
tar -xzf "$tmp/$TARBALL" -C "$tmp/unpacked" || die "cannot unpack $TARBALL"
# The tarball may or may not carry a top-level directory; locate the binary
# rather than assume either shape.
agent_path=$(find "$tmp/unpacked" -name vallenta-agent -type f -print | head -n 1)
[ -n "$agent_path" ] || die "the archive contains no vallenta-agent"
payload=$(dirname "$agent_path")

mkdir -p "$LIB_DIR" "$BIN_DIR"
# No lldb-server is shipped: the distribution's own package supplies it, and the
# agent says so at startup when it is absent. $BIN_DIR gets a symlink rather than
# a copy so the agent's own resolved path stays $LIB_DIR.
cp -f "$payload"/* "$LIB_DIR/"
chmod 755 "$LIB_DIR/vallenta-agent"
ln -sf "$LIB_DIR/vallenta-agent" "$BIN_DIR/vallenta-agent"

# Running the binary is the only check that it is the right architecture and
# actually executable here; swallowing its failure would report a broken install
# as a good one.
installed_version=$("$LIB_DIR/vallenta-agent" --version) ||
    die "the installed binary does not run on this machine ($LIB_DIR/vallenta-agent)"

echo
echo "Installed $installed_version"
echo "  program : $LIB_DIR"
echo "  command : $BIN_DIR/vallenta-agent"
echo

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        echo "$BIN_DIR is not on your PATH. Add this to your shell profile:"
        echo
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo
        ;;
esac

cat <<'NEXT'
Next steps

  1. Install lldb, which supplies lldb-server. The agent needs it to debug and
     tells you the exact command for this distribution if it is missing:

       sudo apt install lldb        (Debian/Ubuntu)
       sudo dnf install lldb        (Fedora/RHEL)

  2. Run it:            vallenta-agent
  3. Copy the pairing token it prints into Vallenta Studio, once, when you add
     this machine as a Linux target.
  4. Open the control port (64300) and the session range it prints to your
     development machine.

To keep it running in the background, install it as a systemd user service:

  vallenta-agent --install-service

That writes a unit and prints the three commands that enable it. Remove it
again with --uninstall-service.
NEXT
