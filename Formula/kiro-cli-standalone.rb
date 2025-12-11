class KiroCliStandalone < Formula
  desc "AI-powered CLI chat and agents (non-cask install)"
  homepage "https://kiro.dev/docs/cli/"
  license "Proprietary"
  version "latest" # dynamic installer workflow; no stable url

  def install
    (buildpath/"install.sh").write <<~EOS
      set -euo pipefail
      TMPDIR="$(mktemp -d)"
      trap 'rm -rf "$TMPDIR"' EXIT

      # Use curl with headers that typically pass anti-bot checks
      # -L: follow redirects
      # -A: User-Agent (Safari-like)
      # Referer: site root
      # Accept-Language: common browser languages
      # Accept: */* to mimic generic browser request
      curl -fsSL -L "https://cli.kiro.dev/install-macos" \
        -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15" \
        -H "Referer: https://kiro.dev/" \
        -H "Accept-Language: en-US,en;q=0.9" \
        -H "Accept: */*" \
        --connect-timeout 10 --retry 3 --retry-delay 1 \
        -o "$TMPDIR/installer.sh"

      bash "$TMPDIR/installer.sh" --prefix "#{prefix}" --no-shell-edit

      # Normalize the final location of the binary
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
      Installed as 'kiro-cli-standalone'; binary remains 'kiro-cli'.
      Login: `kiro-cli login`
    MSG
  end

  test do
    system "#{bin}/kiro-cli", "--help"
  end
end
