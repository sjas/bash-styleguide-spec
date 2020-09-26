#!/usr/bin/env bash
cp -va ~/n/bash-styleguide-spec.md .
git add .
git commit -m "bash-styleguide-spec.md update"
git pull
git push origin master

