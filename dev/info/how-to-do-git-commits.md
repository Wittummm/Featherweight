Since I currently(2025/5/25) suck at git I'm writing this :). Current there are 100 horribly commited commits..

## Commit Types
- Normal Commit - apend a normal new commit
- Amend - amend the last commit
- Rebase and Squash - reorganize commits

## Commit Messages Syntax
Example: `v0.0.0.0; prefix: xxx`
- `fix:` for when a commit fixes something
- `change:` for (misc) changes
- `docs:` for when the commit only changes documentation and not actual code
- `refactor:` same external behavior, but reworked internals
- `config:` for changes to config files
- `wip:` for ongoing commits; meaning likely to be amended
- `something: nothing` if after the `:` colon there is nothing then that means there is a description

## Notes
- Only use "create" when you literally create a file with minimal content, otherwise use "made" for clarity.
