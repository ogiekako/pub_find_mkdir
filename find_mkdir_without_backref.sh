#!/bin/bash
# Simulate a 2-tag system example [1] in find + mkdir without back-references.
# [1] https://en.wikipedia.org/wiki/Tag_system#Example:_A_simple_2-tag_illustration

TMP="$(mktemp -d)"
cd "$TMP" # For safety.

# Start of the main program

A=("aa" "ab" "ac" "ad")
sigma=(/"${A[0]}" /"${A[1]}" /"${A[2]}" /"${A[3]}")
eta="${sigma[3]}"
lambda='/[a-z][a-z]'
Lambda='('"$lambda"')*'

pi=(
 "${sigma[2]}${sigma[2]}${sigma[1]}${sigma[0]}${sigma[3]}"
 "${sigma[2]}${sigma[2]}${sigma[0]}"
 "${sigma[2]}${sigma[2]}"
)
Phiw1="${sigma[1]}${sigma[0]}${sigma[0]}" # baa

sep='$_)?('
SEP='\$_\)\?\('

t=(1 2 3 4)

alpha=(
 '.*'"$SEP$lambda$lambda"'({})'"${sigma[0]}$Lambda/$SEP$Lambda/${t[0]}"
 '.*'"$SEP$lambda$lambda"'({})'"${sigma[1]}$Lambda/$SEP$Lambda/${t[1]}"
 '.*'"$SEP$lambda$lambda"'({})'"${sigma[2]}$Lambda/$SEP$Lambda/${t[2]}"
 '.*'"$SEP$lambda$lambda"'({})'"${sigma[3]}$Lambda/$SEP$Lambda/${t[3]}"
)
beta=(
 '.*'"$SEP${sigma[0]}$Lambda"'/'"$SEP$Lambda"
 '.*'"$SEP${sigma[1]}$Lambda"'/'"$SEP$Lambda"
 '.*'"$SEP${sigma[2]}$Lambda"'/'"$SEP$Lambda"
)
gamma='.*'"$SEP"'(|'"$lambda"'|'"$eta$Lambda"')/'"$SEP"

mkdir -p "$sep$Phiw1/$sep"
find "$sep" -regextype awk -empty \( \
 -regex "$gamma" -quit -o \
 -execdir find -fprint {}/"${t[0]}" -quit \; \
 -execdir find -fprint {}/"${t[1]}" -quit \; \
 -execdir find -fprint {}/"${t[2]}" -quit \; \
 -execdir find -fprint {}/"${t[3]}" -quit \; \
 -exec find "$sep" -regextype awk -type f -regex "${alpha[0]}" -delete -quit \; \
 -exec find "$sep" -regextype awk -type f -regex "${alpha[1]}" -delete -quit \; \
 -exec find "$sep" -regextype awk -type f -regex "${alpha[2]}" -delete -quit \; \
 -exec find "$sep" -regextype awk -type f -regex "${alpha[3]}" -delete -quit \; \
 \( \
   ! -execdir find {}/"${t[0]}" -quit \; -execdir mkdir {}"${sigma[0]}" \; -o \
   ! -execdir find {}/"${t[1]}" -quit \; -execdir mkdir {}"${sigma[1]}" \; -o \
   ! -execdir find {}/"${t[2]}" -quit \; -execdir mkdir {}"${sigma[2]}" \; -o \
   ! -execdir find {}/"${t[3]}" -quit \; -execdir mkdir {}"${sigma[3]}" \; -o \
   -false \
 \) -o \( \
  -regex "${beta[0]}" -execdir mkdir -p {}"${pi[0]}"/"$sep" \; -o \
  -regex "${beta[1]}" -execdir mkdir -p {}"${pi[1]}"/"$sep" \; -o \
  -regex "${beta[2]}" -execdir mkdir -p {}"${pi[2]}"/"$sep" \; -o \
  -printf unreachable \
 \) , \
 -exec find "$sep" -type f -delete \; \
\) 2> /dev/null
find "$sep" -depth ! -empty -name "$sep" -execdir find "$sep" ! -name "$sep" -printf /%f \; -quit

# End of the main program
rm -r "$TMP"
