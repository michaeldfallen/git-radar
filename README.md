# Git Radar

A heads up display for git.

![An example of git-radar]

Git-radar is a tool you can add to your prompt to provide at-a-glance
information on your git repo. It's a labour of love I've been dogfooding for the
last few years. Maybe it can help you too.

**Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
  - [Files status](#files-status)
  - [Local commits status](#local-commits-status)
  - [Remote commits status](#remote-commits-status)
  - [(Optional) Auto-fetch repos](#optional-auto-fetch-repos)
- [Customise your prompt](#customise-your-prompt)
- [Support](#support)
  - [Ensuring prompt execution](#ensuring-prompt-execution)
  - [Configuring colours](#configuring-colours)
    - [Exporting Environment Variables](#exporting-environment-variables)
    - [Setting an RC file](#setting-an-rc-file)
    - [Bash Colour Codes](#bash-colour-codes)
    - [Zsh Colour Codes](#zsh-colour-codes)
    - [Configuration values](#configuration-values)
      - [Colouring the Branch part](#colouring-the-branch-part)
      - [Colouring the local commits status](#colouring-the-local-commits-status)
      - [Colouring the remote commits status](#colouring-the-remote-commits-status)
      - [Colouring the file changes status](#colouring-the-file-changes-status)
- [License](#license)

## Installation

### Install from brew:

```
> brew install michaeldfallen/formula/git-radar
```

### Manually:

```
> cd ~ && git clone https://github.com/michaeldfallen/git-radar .git-radar
> echo 'export PATH=$PATH:$HOME/.git-radar' >> ~/.bashrc
```

Then run `git-radar` to see the docs and prove it's installed.

## Usage

To use git-radar you need to add it to your prompt. This is done in different
ways depending on your shell.

**Bash**

Add to your `.bashrc`
```bash
export PS1="$PS1\$(git-radar --bash --fetch)"
```
[(note: the `\` escaping the `$` is important)](#ensuring-prompt-execution)

**Zsh**

Add to your `.zshrc`
```zsh
export PROMPT="$PROMPT\$(git-radar --zsh --fetch) "
```
[(note: the `\` escaping the `$` is important)](#ensuring-prompt-execution)

**Fish**

Add to your `config.fish`
```bash
function fish_prompt
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    git-radar --fish --fetch
    set_color normal
    echo -n ' > '
end
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

The use of feature is controlled by the `GIT_RADAR_FORMAT` environment variable.
See [Customise your prompt](#customise-your-prompt) for how to personalise this.

### Local commits status

The prompt will show you the difference in commits between your branch and the
remote your branch is tracking. The examples below assume you are checked out on
`master` and are tracking `origin/master`.

Prompt              | Meaning
--------------------|--------
![git:(master 2↑)]  | We have 2 commits to push up
![git:(master 3↓)]  | We have 3 commits to pull down
![git:(master 3⇵5)] | Our version and origins version of `master` have diverged

The use of feature is controlled by the `GIT_RADAR_FORMAT` environment variable.
See [Customise your prompt](#customise-your-prompt) for how to personalise this.

### Remote commits status

The prompt will also show the difference between your branch on origin and what
is on `origin/master`. This a is hard coded branch name which I intend to make
configurable in the future.

This is the difference between the commits you've pushed up and `origin/master`.

Prompt                     | Meaning
---------------------------|---------------
![git:(m ← 2 my-branch)]   | We have 2 commits on `origin/my-branch` that aren't on `origin/master`
![git:(m 4 → my-branch)]   | There are 4 commits on `origin/master` that aren't on `origin/my-branch`
![git:(m 1 ⇄ 2 my-branch)] | `origin/master` and `origin/my-branch` have diverged, we'll need to rebase or merge

The use of feature is controlled by the `GIT_RADAR_FORMAT` environment variable.
See [Customise your prompt](#customise-your-prompt) for how to personalise this.

If you don't rely on this status, you can always hide this part of the prompt by
[customising your prompt](#customise-your-prompt)

### (Optional) Auto-fetch repos

Ensuring your refs are up to date I found can be a pain. To streamline this
git-radar can be configured to auto-fetch your repo. When the `--fetch` flag is
used git-radar will run `git fetch` asynchronously every 5 minutes.

This will only occur when the prompt is rendered and it will only occur on the
repo you are currently in.

To use this feature, when setting your prompt, call git-radar with `--fetch`:

**Bash**
```bash
export PS1="$PS1\$(git-radar --bash --fetch)"
```
[(note: the `\` escaping the `$` is important)](#ensuring-prompt-execution)

**Zsh**
```zsh
export PROMPT="$PROMPT\$(git-radar --zsh --fetch) "
```
[(note: the `\` escaping the `$` is important)](#ensuring-prompt-execution)

## Customise your prompt

Git Radar is highly customisable using a prompt format string. The 4 features
above: remote commits, local commits, branch and file changes; are controlled
by the prompt format string.

Feature        | Control string
---------------|---------------
Remote commits | `%{remote}`
Local commits  | `%{local}`
Branch         | `%{branch}`
File changes   | `%{changes}`

You can create any prompt shape you prefer by exporting `GIT_RADAR_FORMAT` with
your preferred shape. The control strings above will be replaced with the output
of the corresponding feature.

**Examples**

GIT_RADAR_FORMAT                      | Result
--------------------------------------|---------------------
`%{branch}%{local}%{changes}`         | `master1↑1M`
`[%{branch}] - %{local} - %{changes}` | `[master] - 1↑ - 1M`

### Prefixing and Suffixing the features

Often you will want certain parts of the prompt to only appear when there is
content to render. For example, when in a repo you want `[branch]` but when out
of a repo you don't want the `[]` appearing.

To do this the control strings support prefixes and suffixes. Prefixes and
Suffixes are separated from the feature name by `:` and will only render if the
feature would render:

Format: `prompt > %{prefix - :changes: - suffix}`

In a repo: `prompt > prefix - 1M - suffix`

Outside a repo: `prompt > `

The default prompt format uses this to add spaces only if the feature would
render. In that way the prompt always looks well spaced out no matter how many
features are rendering.

## Support

### Ensuring prompt execution

When setting your prompt variable, `PROMPT` in Zsh and `PS1` in Bash, it's
important that the function executes each time the prompt renders. That way the
prompt will respond to changes in your git repo. To ensure this you will need
to escape the execution of the function. There are two ways to do this:

**1. Use `$'` to render raw characters**
```bash
export PROMPT=$'$(git-radar --zsh)'
export PS1=$'$(git-radar --bash)'
```

**2. Use `\` to escape execution of the subshell**
```bash
export PROMPT="\$(git-radar --zsh)"
export PS1="\$(git-radar --bash)"
```

### Configuring colours

You can configure the colour scheme in two ways: export
[Environment Variables](#exporting-environment-variables)
or use an [rc file](#setting-an-rc-file).

#### Exporting Environment Variables

To configure the prompt this way just add to your `~/.bashrc` or `~/.zshrc` an
export directive with the value you want to change.

**Example: Change the branch colour in Zsh**

In `~/.zshrc`:
```zsh
export GIT_RADAR_COLOR_BRANCH='$fg[yellow]'
```

**Example: Change the branch colour in Bash**

In `~/.bashrc`:
```zsh
export GIT_RADAR_COLOR_BRANCH='\\033[0;33m'
```

#### Setting an RC file

Git radar supports multiple rc files. One of these will be sourced when the
prompt renders.

**Example: Change the branch colour in Zsh**

In `~/.gitradarrc`:
```zsh
GIT_RADAR_COLOR_BRANCH='$fg[yellow]'
```

**Basic RC file**

Create a file at `~/.gitradarrc` which sets the Environment variables listed in
[Configuration values](#configuration-values) using colour codes listed in
either [Zsh Colour Codes](#zsh-colour-codes) or
[Bash Colour Codes](#Bash-Colour-Codes) depending on your shell.

**Shell specific RC file**

If you use both Bash and Zsh you can set RC files that are specific for those
shells.

For Bash: Create a file at `~/.gitradarrc.bash`

For Zsh: Create a file at `~/.gitradarrc.zsh`


#### Bash Colour Codes

Bash colour codes make use of the colours your terminal app claims to be `red`
or `green`. Using one of these codes will only produce the colour your terminal
claims, so you should customise your colour scheme on your terminal as well as
customising git-radar.

Note the "Bright" colours can be shown as bold instead, it depends on your
terminal. By default, for example, the Mac OSX Terminal.app uses the "Bright"
colours to provide 8 new lighter colours but some terminals only support 8 and
will show the text as bold instead.

Colour        | Code for Text  | Code for Background
--------------|----------------|--------------------
Black         | `\\033[0;30m`  | `\\033[0;40m`
Red           | `\\033[0;31m`  | `\\033[0;41m`
Green         | `\\033[0;32m`  | `\\033[0;42m`
Yellow        | `\\033[0;33m`  | `\\033[0;43m`
Blue          | `\\033[0;34m`  | `\\033[0;44m`
Magenta       | `\\033[0;35m`  | `\\033[0;45m`
Cyan          | `\\033[0;36m`  | `\\033[0;46m`
White         | `\\033[0;37m`  | `\\033[0;47m`
Bright Black  | `\\033[1;30m`  | `\\033[1;40m`
Bright Red    | `\\033[1;31m`  | `\\033[1;41m`
Bright Green  | `\\033[1;32m`  | `\\033[1;42m`
Bright Yellow | `\\033[1;33m`  | `\\033[1;43m`
Bright Blue   | `\\033[1;34m`  | `\\033[1;44m`
Bright Magenta| `\\033[1;35m`  | `\\033[1;45m`
Bright Cyan   | `\\033[1;36m`  | `\\033[1;46m`
Bright White  | `\\033[1;37m`  | `\\033[1;47m`
Reset         | `\\033[0m`     | `\\033[0m`

Note the Reset will set back to what your terminal claims as standard text and
background.

#### Zsh Colour Codes

Zsh also provides a way to access the colours that your terminal claims as `red`
or `green`, etc.

Note the "Bright" colours can be shown as bold instead, it depends on your
terminal. By default, for example, the Mac OSX Terminal.app uses the "Bright"
colours to provide 8 new lighter colours but some terminals only support 8 and
will show the text as bold instead.

Colour        | Code for Text      | Code for Background
--------------|--------------------|--------------------
Black         | `$fg[black]`       | `$bg[black]`
Red           | `$fg[red]`         | `$bg[red]`
Green         | `$fg[green]`       | `$bg[green]`
Yellow        | `$fg[yellow]`      | `$bg[yellow]`
Blue          | `$fg[blue]`        | `$bg[blue]`
Magenta       | `$fg[magenta]`     | `$bg[magenta]`
Cyan          | `$fg[cyan]`        | `$bg[cyan]`
White         | `$fg[white]`       | `$bg[white]`
Bright Black  | `$fg_bold[black]`  | `$bg_bold[black]`
Bright Red    | `$fg_bold[red]`    | `$bg_bold[red]`
Bright Green  | `$fg_bold[green]`  | `$bg_bold[green]`
Bright Yellow | `$fg_bold[yellow]` | `$bg_bold[yellow]`
Bright Blue   | `$fg_bold[blue]`   | `$bg_bold[blue]`
Bright Magenta| `$fg_bold[magenta]`| `$bg_bold[magenta]`
Bright Cyan   | `$fg_bold[cyan]`   | `$bg_bold[cyan]`
Bright White  | `$fg_bold[white]`  | `$bg_bold[white]`
Reset         | `$reset_color`     | `$reset_color`

#### Configuration values

All these values should be set using a the correct colour code for your
terminal. You should also choose the colour code based on what shell you are
using. There is a way to support [colouring multiple shells using rc files](#setting-an-rc-file).

##### Colouring the Branch part

**GIT_RADAR_COLOR_BRANCH='[colour code]'**
```
git:(my-branch)
     ^^^^^^^^^
```
The colour to use for the Branch or git reference.

It is unset by
`GIT_RADAR_COLOR_BRANCH_RESET` which you can set if you want a different
background colour to return to.

##### Colouring the local commits status

**GIT_RADAR_COLOR_LOCAL_AHEAD='[colour code]'**
```
git:(my-branch 1↑)
                ^
```
The colour to use for the arrow that indicates how many commits you have to push
up.

It is unset by `GIT_RADAR_COLOR_LOCAL_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_LOCAL_BEHIND='[colour code]'**
```
git:(my-branch 1↓)
                ^
```
The colour to use for the arrow that indicates how many commits you have to pull
down.

It is unset by `GIT_RADAR_COLOR_LOCAL_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_LOCAL_DIVERGED='[colour code]'**
```
git:(my-branch 1⇵1)
                ^
```
The colour to use for the arrow that indicates how many commits your branch has diverged by.

It is unset by `GIT_RADAR_COLOR_LOCAL_RESET` which you can set if you want
a different background colour to return to.

##### Colouring the remote commits status

**GIT_RADAR_COLOR_REMOTE_AHEAD='[colour code]'**
```
git:(m ← 1 my-branch)
       ^
```
The colour to use for the arrow that indicates how many commits your branch has to merge on to master.

It is unset by `GIT_RADAR_COLOR_REMOTE_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_REMOTE_BEHIND='[colour code]'**
```
git:(m 1 → my-branch)
         ^
```
The colour to use for the arrow that indicates how many commits your branch is
behind master.

It is unset by `GIT_RADAR_COLOR_REMOTE_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_REMOTE_DIVERGED='[colour code]'**
```
git:(m 1 ⇄ 1 my-branch)
         ^
```
The colour to use for the arrow that indicates how many commits your branch has
diverged from master.

It is unset by `GIT_RADAR_COLOR_REMOTE_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_REMOTE_NOT_UPSTREAM='[colour code]'**
```
git:(upstream ⚡ my-branch)
              ^
```
The colour to use for the lightning bolt which indicates that your branch is not
tracking an upstream branch.

It is unset by `GIT_RADAR_COLOR_REMOTE_RESET` which you can set if you want
a different background colour to return to.

##### Colouring the file changes status

**GIT_RADAR_COLOR_CHANGES_STAGED='[colour code]'**
```
git:(my-branch) 1M
                 ^
```
The colour to use for the letters that indicate changes that have been staged to
commit.

It is unset by `GIT_RADAR_COLOR_CHANGES_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_CHANGES_UNSTAGED='[colour code]'**
```
git:(my-branch) 1M
                 ^
```
The colour to use for the letters that indicate changes that have not yet been
staged to commit.

It is unset by `GIT_RADAR_COLOR_CHANGES_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_CHANGES_CONFLICTED='[colour code]'**
```
git:(my-branch) 1B
                 ^
```
The colour to use for the letters that indicate changes that have conflicts that
need resolved.

It is unset by `GIT_RADAR_COLOR_CHANGES_RESET` which you can set if you want
a different background colour to return to.

**GIT_RADAR_COLOR_CHANGES_UNTRACKED='[colour code]'**
```
git:(my-branch) 1A
                 ^
```
The colour to use for the letters that indicate files that are currently not
tracked by git.

It is unset by `GIT_RADAR_COLOR_CHANGES_RESET` which you can set if you want
a different background colour to return to.

## License

Git Radar is licensed under the MIT license.

See [LICENSE] for the full license text.

[LICENSE]: https://github.com/michaeldfallen/git-radar/blob/master/LICENSE
[git:(master) 3A]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/untracked.png
[git:(master) 2D2M]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/unstaged.png
[git:(master) 1M1R]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/added.png
[git:(master) 1U]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/conflicts.png
[git:(master) 1M 1D2M 2A]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/combination.png
[git:(master 2↑)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/local%20is%20ahead.png
[git:(master 3↓)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/remote%20is%20behind.png
[git:(master 3⇵5)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/remote%20local%20diverged.png
[git:(m ← 2 my-branch)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/branch%20is%20ahead.png
[git:(m 4 → my-branch)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/master%20is%20ahead.png
[git:(m 1 ⇄ 2 my-branch)]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/master%20branch%20diverged.png
[An example of git-radar]: https://raw.githubusercontent.com/michaeldfallen/git-radar/master/images/detailed.png
