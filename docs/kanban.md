# Kanban Board

The project board for [nixos-dots](..) is a GitHub Project (kanban) used to track
everything this repo touches: hosts, NixOS/Home Manager modules, dotfiles, themes,
secrets, documentation, and releases.

## Board columns

| Column | Meaning |
|---|---|
| Backlog | Ideas not yet ready to work on. Nothing here is promised. |
| To Do | Accepted, well-scoped work. Grab cards from the top. |
| In Progress | Someone is actively working on it. One owner per card. |
| In Review | Code is done; needs a second look or CI to pass. Link the PR. |
| Done | Shipped: committed and merged. Celebrate briefly, move on. |

## Workflow

- New work starts in **Backlog**, then moves to **To Do** once it's
  concrete and scoped.
- Move a card to **In Progress** when you start; don't leave cards
  parked there across sessions.
- Attach the PR (or commit) to the card before moving it to **In Review**.
- A card only reaches **Done** after it's committed and CI is green.

## Card conventions

- **Title:** `area: verb` — e.g. `hosts/aspire7: fix NVMe partition size`,
  `secrets: rotate GitHub token`, `docs: write maintenance guide`.
- **Body:** one or two sentences of goal + any acceptance criteria.
- **Labels:** use area labels to mirror the repo layout (see below).
- **Issues vs. cards:** prefer linking real GitHub issues/PRs so the
  board stays in sync automatically where possible.

## Labels

Area labels map directly to repo directories:

- `hosts`, `modules`, `home`, `pkgs`, `themes`, `secrets`, `install`,
  `docs`, `release`
- Work-type labels: `bug`, `enhancement`, `chore`

## Automation

The board is automated at two levels.

### GitHub Action (`project-automation.yml`)

[`.github/workflows/project-automation.yml`](../.github/workflows/project-automation.yml)
moves cards on events the built-ins don't cover, including sub-issues and
issues linked to a PR. It reads the board's Status field dynamically and
silently skips any move whose status name doesn't exist, so it is safe to
commit before the board or token are ready.

| Event | Status |
|---|---|
| Issue opened / reopened | To Do |
| Issue closed | Done |
| PR opened / reopened | In Progress |
| PR marked ready for review | In Review |
| PR merged | Done |
| PR closed without merging | To Do |
| Issue linked to PR ("Closes #N") | Follows the PR to In Progress / In Review (never Done) |

The Action needs a personal access token stored as the `PROJECTS_TOKEN`
repository secret. The default `GITHUB_TOKEN` cannot write to a user-owned
project, and fine-grained PATs cannot access user-owned projects at all, so a
**classic PAT** is required:

- Scopes: **`project`** (this repo is public; add `repo` if it ever goes private)
- Store it as the `PROJECTS_TOKEN` repository secret under
  Settings → Secrets and variables → Actions

Without the secret the workflow logs a warning and does nothing.

### Built-in workflows (project settings)

Enable these in the project: **⋯ → Workflows**. They live in the GitHub UI
only — there is no API or `gh` command for them. Keep the set minimal so the
Action stays the single owner of status moves.

| Workflow | Setting |
|---|---|
| Auto-add to project | ON, filter `repo:nixos-dots` — every new issue/PR lands on the board |
| Auto-archive items | ON, `is:closed updated:<@today-2w` |

The status-setting built-ins (**Item added to project**, **Item closed**,
**Pull request merged**, **Item reopened**) are redundant with the Action and
should stay off.

## Relationship with `TODO.md`

`TODO.md` is the historical log of completed setup work. The board is the
living tracker for new and future work. Keep new items on the board; treat
`TODO.md` as an archive (or migrate its remaining items into the board).
