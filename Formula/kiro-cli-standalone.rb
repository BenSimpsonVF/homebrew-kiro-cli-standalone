
# typed: false
require "download_strategy"

# Custom strategy that augments curl arguments with browser-like headers
class BrowserCurlDownloadStrategy < CurlDownloadStrategy
  def _curl_args(extra_args)
    super + %W[
      -L
      -A
      Mozilla/5.0\ (Macintosh;\ Intel\ Mac\ OS\ X\ 14_0)\ AppleWebKit/605.1.15\ (KHTML,\ like\ Gecko)\ Version/17.0\ Safari/605.1.15
      -H
      Referer: https://kiro.dev/
      -H
      Accept-Language: en-US,en;q=0.9
      -H
      Accept: */*
      --connect-timeout
      10
      --retry
      3
      --retry-delay
      1
    ]
  end
end

class KiroCliStandalone < Formula
  desc "AI-powered CLI chat and agents (non-cask install)"
  homepage "https://kiro.dev/docs/cli/"
  license "Proprietary"
  version "latest"

  # Keep a URL so Homebrew has an active spec; fetch via our strategy.
  url "https://cli.kiro.dev/install-macos", using: BrowserCurlDownloadStrategy
  # If the endpoint is dynamic, omit sha256 to avoid mismatches.

  # Optional: silence livecheck for a dynamic installer endpoint
  livecheck do
    skip "Installer endpoint is not versioned"
  end

  def install
    # Homebrew places the fetched file in buildpath with its original name
    installer = buildpath/"install-macos"
    chmod 0755, installer

    system "bash", installer, "--prefix", prefix.to_s, "--no-shell-edit"

    # Normalize binary location
    if (prefix/"bin/kiro-cli").executable?
      bin.install prefix/"bin/kiro-cli"
    elsif (buildpath/"kiro-cli").executable?
      mkdir_p prefix/"bin"
      (prefix/"bin").install buildpath/"kiro-cli" => "kiro-cli"
      bin.install prefix/"bin/kiro-cli"
    else
      odie "kiro-cli binary not found after install"
    end
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

