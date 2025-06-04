#!/bin/bash
set -eu

export LC_ALL=C.UTF-8

count=0
for f in `find . -type f -name '*.csv'`; do
  (head -n 1 $f && tail -n +2 $f | sort --ignore-case | uniq) > $f.tmp
  if ! cmp -s $f.tmp $f; then
    echo "$f is not sorted"
    count=$((count+1))
  fi
  mv $f.tmp $f
done
exit $count
