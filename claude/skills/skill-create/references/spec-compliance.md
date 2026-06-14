# Agent Skills Spec Compliance

Checklist extracted from the [Agent Skills specification](https://agentskills.io/specification). Use `skill-lint` to validate automatically.

## Frontmatter

### name (required)

- [ ] 1-64 characters
- [ ] Lowercase letters (`a-z`), numbers (`0-9`), and hyphens (`-`) only
- [ ] Does not start or end with a hyphen
- [ ] Does not contain consecutive hyphens (`--`)
- [ ] Matches the parent directory name

### description (required)

- [ ] 1-1024 characters
- [ ] Non-empty
- [ ] Written in third person
- [ ] Describes when to use the skill (triggering conditions)
- [ ] Includes specific keywords the agent would search for
- [ ] Does NOT summarize the skill's internal workflow or process

### license (optional)

- [ ] Short license name or reference to a bundled license file

### compatibility (optional)

- [ ] 1-500 characters if provided
- [ ] Only include if the skill has specific environment requirements
- [ ] Examples: required system packages, network access, intended product

### metadata (optional)

- [ ] String keys to string values
- [ ] Key names are reasonably unique to avoid conflicts
- [ ] Common fields: `author`, `version`

### allowed-tools (optional, experimental)

- [ ] Space-separated string of pre-approved tools
- [ ] Support varies by agent implementation

## Directory Structure

- [ ] `SKILL.md` exists and is at the root of the skill directory
- [ ] `scripts/` directory (if present) contains executable, self-contained code
- [ ] `references/` directory (if present) contains documentation loaded on demand
- [ ] `assets/` directory (if present) contains templates, images, or data files
- [ ] No other required files or directories

## Body Content

- [ ] SKILL.md body is under 500 lines
- [ ] File references use relative paths from the skill root
- [ ] File references are one level deep (no chains)
- [ ] Forward slashes in all paths (no backslashes)
- [ ] Progressive disclosure: detailed material lives in reference files, not inline
- [ ] Reference files larger than 100 lines include a table of contents
