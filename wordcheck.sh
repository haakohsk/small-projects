#!/bin/bash
# small program that utilizes ispell to suggest words 
# ---------------------------------------------------
# if your input is not in the disctionary, you are prompted with suggestions
# ---------------------------------------------------

read -p "Word to lookup: "

echo $REPLY > word.txt

# Path to ispell
SPELL="/usr/local/bin/ispell"

word="word.txt"

$SPELL $word
