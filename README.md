<p align="center">
  <img src="docs/images/cover.png" alt="lovcc Cover" width="100%">
</p>

<h1 align="center">
  <img src="assets/logo.svg" width="32" height="32" alt="Logo" align="top">
  lovcc
</h1>

<p align="center">
  <strong>Personal Claude Code plugin toolkit</strong><br>
  <sub>Skills • Hooks • Commands</sub>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#skills">Skills</a> •
  <a href="#hooks">Hooks</a> •
  <a href="#license">License</a>
</p>

---

## Features

- **Unified Management** — All prompts, skills, hooks in one place
- **Cross-Device Sync** — Install via GitHub on any machine
- **Version Controlled** — Track changes with Git
- **Easy Distribution** — Share as a marketplace plugin

## Installation

```bash
# Add marketplace
/plugin marketplace add MarkShawn2020/lovstudio-plugins-official

# Install plugin
/plugin install lovstudio@lovstudio-plugins-official
```

## Skills

### image-gen

Generate images using Gemini via ZenMux API.

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/image-gen/gen_image.py "PROMPT" \
  [-o output.png] [-q low|medium|high] [--ascii]
```

### project-port

Generate stable, hash-based port numbers for projects (range 3000-8999).

```bash
${CLAUDE_PLUGIN_ROOT}/skills/project-port/scripts/hashport.sh [project-name]
# Output: 4827  ← lovcc
```

Same project name always returns the same port.

## Hooks

| Event | Description |
|-------|-------------|
| `PreToolUse` | Notification on `AskUserQuestion` |
| `Stop` | Notification when Claude stops |

Hooks integrate with Lovnotifier for desktop notifications with tmux context.

## Structure

```
lovcc/
├── .claude-plugin/
│   ├── plugin.json        # Plugin manifest
│   └── marketplace.json   # Self-hosted marketplace
├── skills/
│   ├── image-gen/         # Gemini image generation
│   └── project-port/      # Hash-based port generator
├── hooks/
│   ├── hooks.json         # Hook configuration
│   ├── question_notify.sh
│   └── stop_notify.sh
└── commands/              # Slash commands (extensible)
```

## License

[MIT](LICENSE) © Lovstudio
