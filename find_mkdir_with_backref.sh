#!/bin/bash
# Simulate a 2-tag system example [1] in GNU find + mkdir using back-references.
# [1] https://en.wikipedia.org/wiki/Tag_system#Example:_A_simple_2-tag_illustration

TMP="$(mktemp -d)"
cd "$TMP" # For safety.

# Start of the main program

A=("aa" "ab" "ac" "ad")
sigma=(/"${A[0]}" /"${A[1]}" /"${A[2]}" /"${A[3]}")
eta="${sigma[3]}"
lambda='/[a-z][a-z]'
Lambda='\('"$lambda"'\)*'

pi=(
"${sigma[2]}${sigma[2]}${sigma[1]}${sigma[0]}${sigma[3]}"
"${sigma[2]}${sigma[2]}${sigma[0]}"
"${sigma[2]}${sigma[2]}"
)
Phiw1="${sigma[1]}${sigma[0]}${sigma[0]}" # baa

alpha=(
'.*_'"$lambda$lambda"'\('"$Lambda"'\)'"${sigma[0]}$Lambda"'/_\1'
'.*_'"$lambda$lambda"'\('"$Lambda"'\)'"${sigma[1]}$Lambda"'/_\1'
'.*_'"$lambda$lambda"'\('"$Lambda"'\)'"${sigma[2]}$Lambda"'/_\1'
'.*_'"$lambda$lambda"'\('"$Lambda"'\)'"${sigma[3]}$Lambda"'/_\1'
)
beta=(
'.*_'"${sigma[0]}$Lambda"'/_'"$Lambda"
'.*_'"${sigma[1]}$Lambda"'/_'"$Lambda"
'.*_'"${sigma[2]}$Lambda"'/_'"$Lambda"
)
gamma='.*_\(\|'"$lambda"'\|'"$eta$Lambda"'\)/_'

mkdir -p '_'"$Phiw1"'/_'
find _ -empty \( \
 -regex "$gamma" -quit -o \
 -regex "${alpha[0]}" -execdir mkdir {}"${sigma[0]}" \; -o \
 -regex "${alpha[1]}" -execdir mkdir {}"${sigma[1]}" \; -o \
 -regex "${alpha[2]}" -execdir mkdir {}"${sigma[2]}" \; -o \
 -regex "${alpha[3]}" -execdir mkdir {}"${sigma[3]}" \; -o \
 -regex "${beta[0]}" -execdir mkdir -p {}"${pi[0]}"/_ \; -o \
 -regex "${beta[1]}" -execdir mkdir -p {}"${pi[1]}"/_ \; -o \
 -regex "${beta[2]}" -execdir mkdir -p {}"${pi[2]}"/_ \; -o \
 -printf unreachable \
\)
find _ -depth ! -empty -name _ -execdir find _ ! -name _ -printf /%f \; -quit

# End of the main program

rm -rf "$TMP"
