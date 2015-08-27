scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/radar-base.sh"

test_show_git_label() {
  show_git_label
  assertTrue $?

  show_git_label --bash
  assertTrue $?

  show_git_label --bash --fetch
  assertTrue $?

  show_git_label --bash --minimal --fetch
  assertFalse $?

  show_git_label --bash --fetch --minimal
  assertFalse $?

  show_git_label --minimal --bash --fetch
  assertFalse $?

  show_git_label --bash --fetch  --minimal --no-remote-status
  assertFalse $?
}

test_show_remote_status() {
  show_remote_status
  assertTrue $?

  show_remote_status --bash
  assertTrue $?

  show_remote_status --bash --fetch
  assertTrue $?

  show_remote_status --bash --no-remote-status --fetch
  assertFalse $?

  show_remote_status --bash --fetch --no-remote-status
  assertFalse $?

  show_remote_status --no-remote-status --bash --fetch
  assertFalse $?

  show_remote_status --bash --fetch  --minimal --no-remote-status
  assertFalse $?
}

. ./shunit/shunit2