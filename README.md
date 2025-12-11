
# kiro-cli-standalone-brew

**A Homebrew tap that installs the Kiro CLI as a *formula* (not a cask), with a minimal, terminal-first setup.**  
- No shell profile modifications  
- No background services  
- No functional hooks enabled by default  
- Optional guardrail to restrict file access to the current working directory

> Kiro is an AWS agentic AI toolset. This tap focuses on the **CLI** and a conservative, opt-in security posture.  
> For official CLI docs and features, see the Kiro documentation.

---

## Why this tap?

The official Homebrew entry for Kiro CLI is provided as a **cask** (`brew install --cask kiro-cli`). If you prefer a **formula-based** install for better CLI binary linkage and easy Homebrew lifecycle management—while avoiding GUI/cask semantics—this tap provides that. It wraps the official installer and links `kiro-cli` under Homebrew’s prefix without editing your shell rc files.

---

## Quick start

```bash
# 1) Add the tap
brew tap BenSimpsonVF/kiro-cli-standalone-brew

# 2) Install the CLI (formula, not a cask)
brew install BenSimpsonVF/kiro-cli-standalone-brew/kiro-cli

# 3) Launch in supervised mode (no autopilot)
cd /path/to/project
kiro-cli --supervised
```

- **Supervised mode** requires your approval before any changes, limiting autonomous actions.  
- Kiro chat supports per-directory conversation persistence; start in a fresh folder for a clean slate, or use `/tangent` for isolated chats.

---

## Installation details

This formula:

- Fetches the official installer entry point and installs the CLI into Homebrew’s prefix (e.g., `/opt/homebrew`).  
- **Does not** modify your shell profile (`--no-shell-edit`).  
- Links the `kiro-cli` binary so it’s available on your PATH via Homebrew.  
- Remains fully managed by Homebrew (`brew upgrade`, `brew uninstall`, etc.).

---

## Secure, minimal configuration (optional but recommended)

Create a `.kiro` folder in your project to define a **minimal agent** with **no functional hooks** and an optional **cwd guard** that blocks tool operations outside the current working directory.

```
your-project/
└── .kiro/
    ├── agents/
    │   └── minimal.json
    └── hooks/
        └── cwd-guard.sh
```

**`.kiro/agents/minimal.json`** (example):

```json
{
  "name": "MinimalNoHooks",
  "description": "Kiro CLI chat with zero functional hooks; cwd-only file access.",
  "autopilot": false,
  "tools": {
    "enabled": ["read", "write", "shell"],
    "permissions": {
      "read": { "paths": ["$CWD/**"] },
      "write": { "paths": ["$CWD/**"] },
      "shell": { "cwdOnly": true }
    }
  },
  "hooks": [
    {
      "name": "cwd-guard-pretool",
      "type": "preToolUse",
      "matcher": "*",
      "script": "./.kiro/hooks/cwd-guard.sh"
    }
  ]
}
```

**`.kiro/hooks/cwd-guard.sh`** (example):

```bash
#!/usr/bin/env bash
# Blocks tool operations if any referenced path is outside $PWD.
# Receives a JSON event via STDIN per Kiro CLI hooks documentation.

set -euo pipefail
event="$(cat)"
cwd="$(echo "$event" | sed -n 's/.*"cwd":"\([^"]*\)".*/\1/p')"
paths="$(echo "$event" | grep -oE '"path":"[^"]+"' | sed 's/"path":"//;s/"$//')"

violations=0
for p in $paths; do
  case "$p" in
    "$cwd"/*) : ;;
    *) violations=1 ;;
  esac
done

if [ "$violations" -eq 1 ]; then
  echo "Blocked: tool attempted to access paths outside $cwd" >&2
  # Exit 2 = block tool execution (preToolUse semantics).
  exit 2
fi

exit 0
```

Then run:

```bash
chmod +x .kiro/hooks/cwd-guard.sh
kiro-cli --agent MinimalNoHooks --supervised
```

---

## Usage tips

- **Isolated chats:** Use `/tangent` from within the chat to start a side conversation that doesn’t affect your main history.  
- **Multi-line prompts:** Use `/editor` or `Ctrl+J` to compose multi-line messages.  
- **Resume history:** If you want to resume a prior conversation in the same directory, `kiro-cli chat --resume`. Otherwise, start fresh by launching from a new folder.

---

## Maintenance

Upgrade/uninstall via Brew:

```bash
brew upgrade kiro-cli
brew uninstall kiro-cli
```

To modify the formula, open `Formula/kiro-cli.rb` in this tap and push changes. Refer to the Homebrew **Formula Cookbook** for best practices (versioning, tests, audit).

---

## Troubleshooting

- **`kiro-cli` not found after install**  
  Ensure your Homebrew prefix (`/opt/homebrew/bin`) is on `PATH`. Run `brew doctor` or `echo $PATH`. 

- **Shell profile edits**  
  This formula **avoids** editing shell rc files; if you installed Kiro previously via the official one-liner, you may have `~/.local/bin` entries—safe to leave or remove.  
- **Autopilot vs supervised**  
  If you want maximum control, always start with `--supervised`. Toggle autopilot off in session.

---

## License

This repository (formula and helper scripts) is licensed under the **MIT License**. See LICENSE.

> **Important:** The software installed by this formula—**Kiro CLI**—is licensed by Amazon as proprietary AWS Content under the AWS Customer Agreement, Service Terms, and AWS Intellectual Property License.  
> Please consult Amazon/AWS for authoritative licensing terms and Kiro’s licensing page.

- Kiro CLI & docs: <https://kiro.dev/docs/cli/>  
- Kiro License page: <https://kiro.dev/license/>  
- AWS Legal: <https://aws.amazon.com/legal/>

---

## References

- **Kiro CLI documentation (getting started, chat)**: <https://kiro.dev/docs/cli/>, <https://kiro.dev/docs/cli/chat/>  
- **CLI Hooks (events, blocking with exit code 2)**: <https://kiro.dev/docs/cli/hooks/>  
- **Kiro CLI landing & installer link**: <https://kiro.dev/cli/> and installation page  
- **Homebrew Formula Cookbook**: <https://docs.brew.sh/Formula-Cookbook>  
- **Homebrew cask for Kiro CLI (for context)**: <https://formulae.brew.sh/cask/kiro-cli>

