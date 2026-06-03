#!/bin/bash
# we need this because pipe bash is really shitty so we gotta execute it locally in order for it to even run right
# why?
# fuck if i know bro.
# that's what chatgpt told me.

curl -fsSL https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/script.sh -o /tmp/aio.sh && bash /tmp/aio.sh
