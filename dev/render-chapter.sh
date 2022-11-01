#!/bin/bash

SECTION=$1
CHAPTER=$2

SECTION_PATH="content/course/${SECTION}"
CHAPTER_PATH="${SECTION_PATH}/${CHAPTER}"

quarto render ${SECTION_PATH}/index.qmd --to hugo
mv ${SECTION_PATH}/index.md ${SECTION_PATH}/_index.md
quarto render ${CHAPTER_PATH}/index.qmd --to hugo
mv ${CHAPTER_PATH}/index.md ${CHAPTER_PATH}/_index.md

hugo server -p 5000 --bind 0.0.0.0
