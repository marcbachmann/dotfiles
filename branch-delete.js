#!/usr/bin/env bash
set -e
[ -z "$1" ] && printf "\
A branch name is required
-------------------------
$(git -c pager.branch=false branch --format '%(refname:short)')
" && exit 1

BRANCHES=$(git -c pager.branch=false branch --list "$1" --format "%(refname:short)")
[ -z "$BRANCHES" ] && echo "No branches found" && exit 1

printf "\
Deleting Branches:
------------------
$BRANCHES

Continue (y/n)? \
"

read CONT
if [[ "$CONT" =~ ^(yes|y)$ ]]; then
  for i in $BRANCHES; do
    git branch -D $i
  done
else
  echo "Aborted"
  exit 1
fi
