# Jujutsu VCS Extension for Pi

A Pi extension that adds jujutsu (jj) VCS integration to the AI agent. Provides 12 tools for working with jujutsu repositories, plus lifecycle hooks for conflict detection and status monitoring.

## Features

- **12 Built-in Tools**: Full coverage of common jujutsu operations
- **Conflict Detection**: Automatic warnings for unresolved conflicts
- **Status Monitoring**: Tracks repository state across conversation turns
- **Type-Safe**: Built with TypeScript and typebox for reliability

## Installation

1. Place this extension in your Pi configuration directory:

```bash
cp -r jujutsu-vcs-extension ~/.pi/
```

2. Add to `~/.pi/config.json`:

```json
{
  "extensions": ["./jujutsu-vcs-extension"]
}
```

3. Restart Pi or reload your session

## Available Tools

| Tool            | Description            | Example Usage                   |
| --------------- | ---------------------- | ------------------------------- |
| `jj_status`     | Show repository status | "What's the status of my repo?" |
| `jj_changes`    | List all changes       | "Show me my changes"            |
| `jj_diff`       | Show diff for a change | "Show diff for change 1"        |
| `jj_commit`     | Create a commit        | "Commit these changes"          |
| `jj_fold`       | Fold a change          | "Fold change 1"                 |
| `jj_forget`     | Unstage a change       | "Forget change 2"               |
| `jj_edit`       | Edit a change message  | "Edit change 1 message"         |
| `jj_resolve`    | Resolve conflicts      | "Resolve conflicts"             |
| `jj_operations` | List operations        | "Show operations"               |
| `jj_parents`    | Show parent commits    | "Show parents"                  |
| `jj_summary`    | Show repo summary      | "Summarize the repo"            |
| `jj_branch`     | Show current branch    | "What branch am I on?"          |

## Usage Examples

### Basic Operations

```bash
# Check status
"Show me the status of my jujutsu repo"

# List changes
"What changes do I have staged?"

# View diff
"Show me the diff for change 1"

# Create commit
"Commit these changes with message 'fix: bug in login'"
```

### Advanced Operations

```bash
# Fold changes
"Fold all my changes into the working tree"

# Unstage changes
"Unstage change 2"

# Edit change message
"Edit the message for change 1"

# Resolve conflicts
"Resolve the conflicts in change 1"

# Show operations
"What operations have been performed?"

# Show parents
"Show the parent commits for change 1"

# Get summary
"Give me a summary of the repository"

# Check branch
"What branch am I currently on?"
```

### Conflict Detection

The extension automatically monitors for conflicts:

> ⚠️ **Jujutsu Conflicts**: There are unresolved conflicts in your jujutsu repository. Please resolve them before continuing.

This warning appears automatically when you have unresolved conflicts.

## Configuration

### Lifecycle Hooks

The extension includes two lifecycle hooks:

1. **`turn_start`**: Checks for unresolved conflicts and warns you
2. **`message_update`**: Can be extended to show status line updates

### Customization

To customize behavior, modify the extension file:

```typescript
// In index.ts
pi.on("turn_start", async () => {
  // Add custom conflict detection logic
});

pi.on("message_update", async (event) => {
  // Add status line updates
});
```

## Requirements

- **Jujutsu**: Must have `jj` installed and available in PATH
- **Node.js**: For TypeScript compilation
- **Typebox**: Required dependency (installed automatically)

## Development

```bash
# Install dependencies
npm install

# Type check
npm run type-check

# Build
npm run build
```

## License

MIT

## Contributing

Contributions welcome! Feel free to submit issues or pull requests.
