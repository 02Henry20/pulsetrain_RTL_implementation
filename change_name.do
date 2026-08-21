#!/bin/tcsh

find . -type f | xargs sed -i 's/TOP_PREV/TOP_NEXT/g'

#usage : s/before_change/after_change/g


