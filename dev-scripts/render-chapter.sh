#!/bin/bash

SECTION=$1
CHAPTER=$2

SECTION_PATH="content/${SECTION}"
CHAPTER_PATH="${SECTION_PATH}/${CHAPTER}"

quarto preview -port 5000 --host 0.0.0.0

#quarto render ${SECTION_PATH}/index.qmd --to hugo
#mv ${SECTION_PATH}/index.md ${SECTION_PATH}/_index.md
#quarto render ${CHAPTER_PATH}/index.qmd --to hugo
#mv ${CHAPTER_PATH}/index.md ${CHAPTER_PATH}/_index.md
#
#hugo server -p 5000 --bind 0.0.0.0
