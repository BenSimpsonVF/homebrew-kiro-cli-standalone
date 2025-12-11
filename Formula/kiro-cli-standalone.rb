class KiroCliStandalone < Formula
  desc "AI-powered CLI chat and agents (non-cask install)"
  homepage "https://kiro.dev/docs/cli/"
  license "Proprietary"

  url "7487a65cf310b7fb59b357c4b5e6e3f3259d383f4394ecedb39acf70f307cffb", using: :curl
  version "latest"
  sha256 :no_check

  def install
    (buildpath/"install.sh").write <<~EOS
      set -euo pipefail
      TMPDIR="$(mktemp -d)"
      trap "rm -rf \\"$TMPDIR\\"" EXIT
      curl -fsSL https://cli.kiro.dev/install-macos -o "$TMPDIR/installer.sh"
      bash "$TMPDIR/installer.sh" --prefix "#{prefix}" --no-shell-edit
      if [ -x "#{prefix}/bin/kiro-cli" ]; then
        :
      elif [ -x "$TMPDIR/kiro-cli" ]; then
        mkdir -p "#{prefix}/bin"
        mv "$TMPDIR/kiro-cli" "#{prefix}/bin/kiro-cli"
      else
        echo "kiro-cli binary not found after install" >&2
        exit 1
      end
    EOS

    system "bash", "install.sh"
    bin.install "#{prefix}/bin/kiro-cli"  # binary remains 'kiro-cli'
  end

  def caveats
    <<~MSG
      Installed as a formula named 'kiro-cli-standalone'; binary remains 'kiro-cli'.
      To log in: `kiro-cli login`
    MSG
  end

  test do
    system "#{bin}/kiro-cli", "--help"
  end
end
