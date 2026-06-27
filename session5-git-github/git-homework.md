# Git and GitHub Homework

## `git commit -a -m` versus `git commit -m`

`git commit -a -m "message"` stages modifications and deletions to already
tracked files, but it does not stage new untracked files. `git commit -m
"message"` commits whatever is already in the index, so new files must first be
staged with `git add`.

```bash
echo "tracked change" >> tracked.txt
git add tracked.txt
git commit -m "Add tracked file"
echo "second change" >> tracked.txt
git commit -a -m "Commit tracked modification"
```

## Cherry-pick

```bash
git switch main
git switch -c cherry-pick-demo
echo "feature one" > feature-one.txt
git add feature-one.txt && git commit -m "Add feature one"
echo "feature two" > feature-two.txt
git add feature-two.txt && git commit -m "Add feature two"
git log --oneline --decorate -2
COMMIT_TO_PICK="$(git rev-parse HEAD~1)"
git switch main
git cherry-pick "$COMMIT_TO_PICK"
git log --oneline --decorate -3
```

Only the selected commit's change is now present on `main`. Resolve conflicts,
if any, with `git add <file>` followed by `git cherry-pick --continue`.
