class KiroCli < Formula
  desc "AI-powered CLI chat and agents (non-cask install)"
  homepage "https://kiro.dev/docs/cli/"
  license "Proprietary"

  # Use the official installer entry point referenced in docs.
  # We avoid casks and run installer in a contained prefix.
  # NOTE: The URL below is documented by Kiro; we’ll call it from Ruby.
  # You can pin versions later if they publish versioned macOS tarballs.
  url "https://cli.kiro.dev/install", using: :curl
  version "latest"
  sha256 :no_check

  def install
    # Write installer script to the buildpath
    (buildpath/"install.sh").write <<~EOS
      set -euo pipefail
      # Fetch the platform-specific payload the same way the official installer does.
      # The official curl|bash would normally install under ~/.local/bin;
      # we redirect installation into #{bin} so Homebrew manages the binary.
      TMPDIR="$(mktemp -d)"
      trap "rm -rf \\"$TMPDIR\\"" EXIT

      # Use the documented macOS path via the installer endpoint (it redirects).
      # Keep TLS flags as in docs for security.
      curl -fsSL https://cli.kiro.dev/install-macos -o "$TMPDIR/installer.sh"
      bash "$TMPDIR/installer.sh" --prefix "#{prefix}" --no-shell-edit

      # Expect installer to drop a kiro-cli binary in prefix/bin; if not, link it.
      if [ -x "#{prefix}/bin/kiro-cli" ]; then
        :
      elif [ -x "$TMPDIR/kiro-cli" ]; then
        mkdir -p "#{prefix}/bin"
        mv "$TMPDIR/kiro-cli" "#{prefix}/bin/kiro-cli"
      else
        echo "kiro-cli binary not found after install" >&2
        exit 1
      fi
    EOS

    system "bash", "install.sh"
    bin.install "#{prefix}/bin/kiro-cli"
  end

  def caveats
    <<~MSG
      This formula installs kiro-cli without cask or shell RC modifications.
      No hooks or MCP integrations are enabled by default.

      To log in: `kiro-cli login`
    MSG
  end

  test do
    system "#{bin}/kiro-cli", "--help"
  end
end

