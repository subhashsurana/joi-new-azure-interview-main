#!/usr/bin/env bash
function check_randomized {
  if [ ! -f interview_id.txt ]; then
    echo "Codebase is not randomized yet."
    exit 5
  fi
}

function randomize {
  if [ -f interview_id.txt ]; then
    >&2 echo "Codebase was already randomized. Skipping"
  else    
    >&2 echo "Randomizing the code base..."
    if [ -z "$CODE_PREFIX" ]; then
      echo "Enter CODE_PREFIX (candidate's lastname): " CODE_PREFIX
    fi
    if [ -z "$CODE_PREFIX" ]; then
      >&2 echo "ERROR: CODE_PREFIX is required. Exiting."
      exit 1
    fi
    echo "${CODE_PREFIX}" | awk '{print tolower($0)}' > interview_id.txt
    INTERVIEW_CODE=$(cat interview_id.txt)
    >&2 find ./infra -type f -exec sed -i '' -e "s/news4321/news$INTERVIEW_CODE/g" {} \;
  fi
}