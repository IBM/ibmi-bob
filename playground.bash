# Playground script

# Test deleting substrings
string1="This is a big test of some big things."
match=" big"
string2=${string1/$match/}
echo
echo "Original string: ${string1}"
echo "match: $match"
echo "New string: ${string2}"
echo

echo "Original string1: ${string1}"
echo "match: $match"
string1=${string1//$match}
echo "New string1: ${string1}"