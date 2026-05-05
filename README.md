# fish-functions

Handy dandy fish shell functions for git workflow, PR management, emoji commits, and more.

## Install

Creates symlinks for all functions and completions into the default `~/.config/fish/` directory.

```
fish install.fish
```

To update to the latest version:

```
update-fish-functions
```

## Dependencies

- [`git`](https://git-scm.com/)
- [`gh`](https://cli.github.com/) — GitHub CLI (required for PR-related functions)
- [`jq`](https://stedolan.github.io/jq/) — JSON processor (required for `pr-cluster`, `pr-train update-prs`)

---

## Functions

### Git — Branches

#### `nb [branch-name]`
Create a new branch off the remote default branch (auto-detected, falls back to `origin/master`). Prefixes the branch name with your username and slugifies it. Prompts for a name if none is given.

```
nb fix signup validation
# → caleb-fix-signup-validation
```

#### `cb <branch>`
Checkout a branch, fetching it from origin first. No-ops if you're already on that branch.

```
cb main
```

#### `db <branch>`
Delete a local branch (force delete).

```
db caleb-old-feature
```

#### `rb <old-branch> <new-branch>`
Rename a branch locally and on the remote — deletes the old remote branch and pushes the new one with tracking set up.

```
rb caleb-typo caleb-fix-typo
```

#### `clean-branches`
Find all local branches whose GitHub PRs are closed/merged and prompt to delete them in bulk.

```
clean-branches
```

#### `freshen`
Merge the latest `origin/master` into the current branch and push. If a PR train is active, runs `pr-train merge` instead.

```
freshen
```

---

### Git — Utilities

#### `git-repo`
Print the current repo as `username/repo` (parsed from the remote URL). Used internally by `pr-train`.

```
git-repo
# → caleb/my-repo
```

#### `has-repo`
Returns 0 if inside a git repo, 1 otherwise (with a message). Used as a guard in other functions.

#### `has-changes`
Returns 0 if there are uncommitted changes, 1 if the working tree is clean.

#### `has-pr <branch> <statuses>`
Returns 0 if a PR exists for `<branch>` with any of the given comma-separated statuses (`open`, `merged`, `closed`).

```
has-pr caleb-my-feature open,merged
```

---

### Worktrees

#### `wkt [n]`
List all git worktrees, or `cd` into the nth one.

```
wkt       # list all worktrees
wkt 2     # cd into worktree #2
```

#### `wkt-port`
Print the dev server port for the current worktree, based on a trailing number in the worktree directory name (e.g. worktree ending in `-2` → port `9091`, default → `9090`).

---

### PR Train 🚂

A PR train is a chain of stacked branches/PRs where each branch is based on the previous one. `pr-train` manages creating, merging, and keeping the PRs up to date.

#### `pr-train <subcommand>`

| Subcommand | Description |
| --- | --- |
| `init` | Initialise a new PR train from the current branch |
| `new-branch` | Add a new branch to the tail of the train |
| `checkout <n\|head\|tail\|next\|prev>` | Checkout the nth branch or by position |
| `merge [--from n\|here] [--to n\|tail]` | Merge each branch into the next, head → tail |
| `update-prs [--simple]` | Create/update GitHub PRs for all branches with a linked table |
| `update` | Remove merged branches from the train config |
| `delete` | Delete the current PR train config |
| `open-config` | Open the PR train config file in your editor |
| `--status` | Show all branches in the current train |
| `--help` | Show help |

`prt` is an alias for `pr-train`.

---

### PR Cluster

#### `pr-cluster`
Prompts for a Jira ticket ID, finds all your open and merged PRs matching that ticket, and updates each PR's body with a linked list of the related PRs in the cluster. Uses a `<pr-cluster>…</pr-cluster>` block that it replaces on subsequent runs.

`prc` is an alias for `pr-cluster`.

---

### Emoji Commits

#### `remoji`
Print a single random emoji. Used by the emoji commit functions.

#### `emojicommit <message>`
Stage all changes and commit with a random emoji prefix.

```
emojicommit fix the thing
# → 🎉 fix the thing
```

#### `emojipush <message>`
Stage, commit with a random emoji, and push to `origin HEAD`.

#### `emojiforce <message>`
Stage, commit with a random emoji, and force-push to `origin HEAD`.

#### `emoji-grid <name> [size]`
Generate a Slack emoji grid string for a multi-part emoji (e.g. `parrot` split into a `3x3` grid). Copies the result to the clipboard. Size defaults to `3x3`.

```
emoji-grid parrot 2x2
# → :parrot1::parrot2:
#    :parrot3::parrot4:
```

---

### Token Management

#### `save-token <name> <token>`
Save a token to `~/.tokens/<name>` with root ownership and `600` permissions so it can only be read with `sudo`.

```
save-token github ghp_xxxxxxxxxxxx
```

#### `token <name>`
Read a saved token from `~/.tokens/<name>` (uses `sudo cat`).

```
token github
```

---

### Utilities

#### `slugify <string>`
Convert a string to a lowercase, hyphen-separated slug.

```
slugify "Hello World!"
# → hello-world
```

#### `timestamp`
Print a timestamp in `YYYYMMDD-HHMMSS` format. Used internally by `pr-train update-prs` to name temp files.

```
timestamp
# → 20260505-143012
```

#### `cccc`
Generate a random 40-character string starting with `ccccc`. Useful for generating test tokens or IDs.
