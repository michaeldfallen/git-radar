scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/git-base.sh"

test_prefix_and_suffix() {
  status="""
 M unstaged-modified
 D unstaged-deleted
M  staged-modified
A  staged-added
D  staged-deleted
C  staged-copied
R  staged-renamed
MM staged-and-unstaged-modified
UD deleted-them-conflicted
AU added-us-conflicted
UU modified-both-conflicted
?? untacked
"""

  prefix="_"
  suffix="-"

  assertEquals "line:${LINENO}" "1_D-2_M-"\
    "$(unstaged_status "$status" "$prefix" "$suffix")"

  assertEquals "line:${LINENO}" "1_A-1_D-2_M-1_R-1_C-"\
    "$(staged_status "$status" "$prefix" "$suffix")"

  assertEquals "line:${LINENO}" "1_U-1_T-1_B-"\
    "$(conflicted_status "$status" "$prefix" "$suffix")"

  assertEquals "line:${LINENO}" "1_A-"\
    "$(untracked_status "$status" "$prefix" "$suffix")"
}

test_basic_unstaged_options() {
  status="""
 M modified-and-unstaged
 D deleted-and-unstaged
 A impossible-added-and-unstaged-(as-added-and-unstaged-is-untracked)
 C impossible-copied-and-unstaged-(as-copied-and-unstaged-is-untracked)
 R impossible-renamed-and-unstaged-(as-renamed-and-unstaged-is-untracked)
 U impossible-updated-but-unmerged
 ! impossible-ignored-without-!-in-position-1
 ? impossible-untracked-without-?-in-position-1
   empty-spaces-mean-nothing
  """
  assertEquals "line:${LINENO} staged status failed match" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match"\
    "1D1M" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"
}

test_basic_staged_options() {
  status="""
A  added-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1A" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
M  modified-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1M" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
D  deleted-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1D" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
C  copied-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1C" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
R  renamed-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1R" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
U  impossible-unmerged-without-a-character-in-position-2
?  impossible-untracked-without-?-in-position-2
!  impossible-ignored-without-!-in-position-2
   empty-spaces-do-nothing
  """
  assertEquals "line:${LINENO} staged status failed match" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"
}

test_conflicts() {
  status="""
UD unmerged-deleted-by-them
UA unmerged-added-by-them
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "2T" "$(conflicted_status "$status")"

  status="""
AU unmerged-added-by-us
DU unmerged-deleted-by-us
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "2U" "$(conflicted_status "$status")"

  status="""
AA unmerged-both-added
DD unmerged-both-deleted
UU unmerged-both-modified
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "3B" "$(conflicted_status "$status")"
}

. ./shunit/shunit2
