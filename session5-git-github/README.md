# Session 5 - Git Homework

Done in a throwaway repo so the history is small and readable. All output is real.

---

## Task 1: `git commit -a -m` vs `git commit -m`

`git commit -m` only commits what is **already staged** with `git add`. `git commit -a -m` auto-stages every **tracked** file that was modified, then commits - so it merges the `git add` step in. The catch is that word *tracked*: new files git has never seen are untouched by `-a`.

### Setup

```
$ git init -b main
$ echo "line 1" > notes.txt
$ git add notes.txt
$ git commit -m "initial commit"
```

### Modify a tracked file, then try plain `git commit -m`

```
$ echo "line 2" >> notes.txt

$ git status --short
 M notes.txt

$ git commit -m "try commit without staging"
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   notes.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

Nothing was committed. `git status --short` shows ` M` - the M is in the **second** column, meaning modified in the working tree but not in the index.

### Same change, now with `-a`

```
$ git commit -a -m "added line 2 to notes"
[main b0bafad] added line 2 to notes
 1 file changed, 1 insertion(+)
```

Committed straight away, no `git add` needed.

### Proof `-a` skips new files

```
$ echo "extra" > extra.txt

$ git status --short
?? extra.txt

$ git commit -a -m "try committing new file with -a"
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	extra.txt

nothing added to commit but untracked files present (use "git add" to track)
```

`??` means untracked. Even `-a` refused it:

```
$ git add extra.txt
$ git commit -m "add extra.txt (needed git add first)"
```

### Summary

| | `git commit -m` | `git commit -a -m` |
|---|---|---|
| already staged changes | committed | committed |
| modified tracked file, not staged | **skipped** | staged and committed |
| brand new untracked file | skipped | **still skipped** |
| deleted tracked file | skipped unless staged | staged and committed |

So `-a` is a convenience for "commit everything I changed", not "commit everything in the folder". It's handy for quick fixes but I'd rather stage on purpose when a change touches several files, because `-a` sweeps in edits you forgot about.

---

## Task 2: Git Cherry-Pick

### Step 1 - a few commits on main

```
$ git log --oneline
1183b2c add feature C
18b9b30 add feature B
229cf2a add feature A
d3b4632 add extra.txt (needed git add first)
b0bafad added line 2 to notes
19c1f7c initial commit
```

### Step 2 - a new branch with 3 commits

```
$ git checkout -b feature-branch
Switched to a new branch 'feature-branch'

$ git log --oneline
075eb83 add logout button
a48700f add signup page
796a7f0 add login page
1183b2c add feature C
18b9b30 add feature B
229cf2a add feature A
d3b4632 add extra.txt (needed git add first)
b0bafad added line 2 to notes
19c1f7c initial commit
```

### Step 3 - identify the one commit I want

```
$ git log --oneline --grep="signup"
a48700f add signup page
```

`a48700f` is the commit that adds `signup.txt`. That hash is what cherry-pick needs.

### Step 4 - cherry-pick it onto main

```
$ git checkout main
Switched to branch 'main'

$ ls
extra.txt  featureA.txt  featureB.txt  featureC.txt  notes.txt

$ git cherry-pick a48700f
[main 1207ccc] add signup page
 Date: Wed Sep 2 10:38:52 2026 +0530
 1 file changed, 1 insertion(+)
 create mode 100644 signup.txt
```

### Step 5 - verify the change landed on main

```
$ git log --oneline
1207ccc add signup page          <- the picked commit
1183b2c add feature C
18b9b30 add feature B
229cf2a add feature A
d3b4632 add extra.txt (needed git add first)
b0bafad added line 2 to notes
19c1f7c initial commit

$ ls
extra.txt  featureA.txt  featureB.txt  featureC.txt  notes.txt  signup.txt

$ cat signup.txt
signup page added
```

And the other two commits from the branch did **not** come along:

```
$ ls login.txt logout.txt
ls: cannot access 'login.txt': No such file or directory
ls: cannot access 'logout.txt': No such file or directory
```

### What the history looks like now

```
$ git log --oneline --all --graph
* 075eb83 add logout button
* a48700f add signup page          <- original, still only on feature-branch
* 796a7f0 add login page
| * 1207ccc add signup page        <- the copy on main
|/
* 1183b2c add feature C
* 18b9b30 add feature B
* 229cf2a add feature A
* d3b4632 add extra.txt (needed git add first)
* b0bafad added line 2 to notes
* 19c1f7c initial commit
```

This graph is the part that made it click for me. **`a48700f` and `1207ccc` are two different hashes for the same change.** Cherry-pick doesn't move a commit, it re-applies the diff on top of the current branch and that produces a brand new commit object with a new parent and a new hash. The original is still sitting on `feature-branch` untouched.

### What I understood

- Cherry-pick copies **one commit's diff**, not the branch and not the commits before it. That's the difference from `merge` (brings the whole branch and its history) and `rebase` (moves a whole series onto a new base).
- The real use case is a hotfix: a bug fix is sitting on a big unfinished feature branch and you need just that fix on main today, without dragging in the half-done feature.
- Because it creates a duplicate commit, if you later merge `feature-branch` into main you can get a conflict on that same change. Git usually handles it, but this is why you don't cherry-pick casually between branches that will be merged anyway.
- Useful flags: `git cherry-pick -n <hash>` applies the change but doesn't commit, so you can edit it first. `git cherry-pick <a>..<b>` picks a range. If it conflicts you fix the files, `git add` them, then `git cherry-pick --continue` (or `--abort` to back out).
