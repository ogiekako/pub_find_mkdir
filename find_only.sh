#!/bin/bash
# Simulate the following 2-counter machine program (that computes addition) in GNU find only.
# 0 JZ(1, 4)
# 1 DEC(1)
# 2 INC(0)
# 3 J(0)
# Initial configuration: (c0, c1) = (3, 4)
# Output: c0 = 7

TMP="$(mktemp -d)"
cd "$TMP" # For safety.

# Start of the main program

gamma=(a b)

# Example: find $(INC a) -quit
INC() {
  echo \
'( ( -exec find '$1' -quit ; '\
'-exec find -quit -fprintf first . ; '\
'-exec find -files0-from '$1' ( -name . -o -name first -delete ) -fprintf t .\0 ; '\
'-exec find -files0-from t -prune -fprintf '$1' .\0 ; '\
'-exec find t -delete ; ) -o '\
'-exec find -fprintf '$1' .\0 -quit ; )'
}
DEC() {
    echo \
'( ( -exec find '$1' -size 2c -delete ; '\
'-exec find '$1' -quit ; '\
'-exec find -quit -fprint first ; '\
'-exec find -files0-from '$1' -name first -delete -fprintf t skip -o -name t -fprintf t . -o -name . -fprintf t \0 ; '\
'-exec find -files0-from t -name . -fprintf '$1' .\0 ; '\
'-exec find t -delete ; '\
') -o -true )'
}
# Example: $(ONES 3) = "111"
ONES() {
    printf '1%.0s' $(seq 1 $1)
}
J() {
if [[ $1 == 0 ]]; then
  echo '-exec find -quit -fprintf pc x ;'
else
  echo '-exec find -fprintf pc '$(ONES $1)' -quit ;'
fi
}
JZ() {
    echo '( ( ! -exec find '$1' -quit ; '"$(J $2)"' ) -o -true )'
}
ISPC() {
    echo '-size '$1'c'
}

find -quit -fprintf pc x
find $(INC s) $(INC a) $(INC a) $(INC a) $(INC b) $(INC b) $(INC b) $(INC b) -quit 2> /dev/null
find -files0-from s -name pc $(INC s) \( \
  $(ISPC 0) $(J 1) $(JZ ${gamma[1]} 4) -o \
  $(ISPC 1) $(J 2) $(DEC ${gamma[1]}) -o \
  $(ISPC 2) $(J 3) $(INC ${gamma[0]}) -o \
  $(ISPC 3) $(J 4) $(J 0) -o \
  -quit \
\) 2> /dev/null
find -files0-from a -fprintf count 1 -prune
find count -printf %s

# End of the main program
rm -r "$TMP"
