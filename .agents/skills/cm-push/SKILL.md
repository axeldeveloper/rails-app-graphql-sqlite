---
name: cm-push
description: "Finalize the current task by reviewing its changes, writing a factual commit message, committing only task-related files, and pushing the current branch. Use when the user invokes /cm-push, asks to commit and push finished work, or requests a commit summary."
argument-hint: "Optional commit message preference"
user-invocable: true
---

# Commit and Push Current Work

When invoked, finish only the changes belonging to the current task. The invocation authorizes creating a commit and pushing that work; it does not authorize including unrelated changes.

## Procedure

1. Inspect the current branch and upstream with `git status --short --branch`, `git branch --show-current`, and `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'`. Review staged, unstaged, and untracked changes and their diffs. Identify the paths changed for the current task from the conversation and inspect their contents. Check `git log --oneline '@{upstream}..HEAD'`; if pushing would also publish commits unrelated to the current task, stop and ask the user.
2. Confirm the task is complete. Run the smallest relevant test or validation command if one has not already passed for these changes. Stop if validation fails; report the failure without committing or pushing.
3. Keep unrelated unstaged and untracked files untouched. Do not use `git add -A`, `git add .`, or include secrets, local state, or generated artifacts.
4. If the index contains staged changes outside this task, stop before committing and explain which staged paths need the user's attention. Do not unstage, discard, or rewrite the user's changes.
5. If there are no uncommitted changes for this task, do not create an empty commit. Report that there is nothing from this task to commit.
6. Stage only the exact task-related paths with explicit path arguments, then review the staged diff and confirm it contains no unrelated changes.
7. Write a commit message based on the staged diff:
   - Use a concise subject in the repository's existing style (prefer `type: summary`, such as `fix: handle empty book lists`).
   - Add a short body that explains what changed and why; mention tests only if they were actually run. Treat this body as the requested comment/summary. Do not claim behavior or validation that the diff does not support.
   - If the user provided a message preference, follow it while keeping the message accurate.
8. Create the commit with the reviewed paths only. Verify the commit and working tree afterward.
9. Push only the current branch to its configured upstream using a normal, non-force push. If there is no upstream, the branch is detached, the push would include unrelated local commits, or Git rejects the push, stop and report the exact blocker. Never use `--force` or `--force-with-lease`, and do not silently change remotes or branches.
10. Report the commit hash, subject, push result, and any task-related validation. Mention unrelated work only if it blocks safe completion; otherwise leave it untouched.
