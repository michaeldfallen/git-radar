# Git Radar

A heads up display for git.

## Installation

Install from brew:

```
> brew install michaeldfallen/formula/git-radar
```

Then add to your prompt:

**Bash**

Add to your `.bashrc`
```bash
export PS1="$PS1$(git-radar --bash)"
```

**Zsh**

Add to your `.zshrc`
```zsh
export PROMPT="$PROMPT$(git-radar --zsh) "
```

## Features

### Files status

The prompt lists the file changes and whether they are staged, unstaged or
untracked.

Prompt                     | Meaning
---------------------------|--------
![git:(master) 3A]         | We have 3 untracked files
![git:(master) 2D2M]       | We have 2 modifications and 2 deletions not yet staged to commit
![git:(master) 1M1R]       | We have 1 modification and a file renamed staged and ready to commit
![git:(master) 1U]         | We have a conflict caused by US that we need to address
![git:(master) 1M 1D2M 2A] | A combination of the above types

Each symbol represents a different change to a file. These are based on what git
considers has happened to the file.

Symbol  | Meaning
--------|--------
A       | A new Added file
D       | A file has been Deleted
M       | A file has been Modified
R       | A file has been renamed
C       | A file has been copied
U       | A conflict caused by Us
T       | A conflict caused by Them
B       | A conflict caused by Both us and them

The color tells you what stage the change is at.

Color   | Meaning
--------|--------
Green   | Staged and ready to be committed (i.e. you have done a `git add`)
Red     | Unstaged, you'll need to `git add` them before you can commit
Grey    | Untracked, these are new files git is unaware of
Yellow  | Conflicted, these need resolved before they can be committed

### Local commits status

The prompt will show you the difference in commits between your branch and the
remote your branch is tracking. The examples below assume you are checked out on
`master` and are tracking `origin/master`.

Prompt              | Meaning
--------------------|--------
![git:(master 2↑)]  | We have 2 commits to push up
![git:(master 3↓)]  | We have 3 commits to pull down
![git:(master 3⇵5)] | Our version and origins version of `master` have diverged

### Our branch against Master commits status

The prompt will also show the difference between your branch on origin and what
is on `origin/master`. This a is hard coded branch name which I intend to make
configurable in the future.

This is the difference between the commits you've pushed up and `origin/master`.

Prompt                     | Meaning
---------------------------|---------------
![git:(m ← 2 my-branch)]   | We have 2 commits on `origin/my-branch` that aren't on `origin/master`
![git:(m 4 → my-branch)]   | There are 4 commits on `origin/master` that aren't on `origin/my-branch`
![git:(m 1 ⇄ 2 my-branch)] | `origin/master` and `origin/my-branch` have diverged, we'll need to rebase or merge

### (Optional) Auto-fetch repos

Ensuring your refs are up to date I found can be a pain. To streamline this
git-radar can be configured to auto-fetch your repo. When the `--fetch` flag is
used git-radar will run `git fetch` asynchronously every 5 minutes.

This will only occur when the prompt is rendered and it will only occur on the
repo you are currently in.

To use this feature, when setting your prompt, call git-radar with `--fetch`:

**Bash**
```bash
export PS1="$PS1$(git-radar --bash --fetch)"
```

**Zsh**
```zsh
export PROMPT="$PROMPT$(git-radar --zsh --fetch) "
```

## License

Git Radar is licensed under the MIT license.

See [LICENSE] for the full license text.

[LICENSE]: https://github.com/michaeldfallen/git-radar/blob/master/LICENSE
