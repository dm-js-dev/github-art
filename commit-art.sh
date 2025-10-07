#!/bin/bash

rm -rf .git
git init
rm -f commit.txt
touch commit.txt
git add commit.txt
git commit -m "init"

pattern=(
  "   *   "
  "  ***  "
  " ***** "
  "  ***  "
  " ***** "
  "*******"
  "   *   "
)

trees=8
tree_width=7
space_between=3
bright_commits=5
background_commits=1

# Текущее время (timestamp)
now_ts=$(date +%s)

# Считаем, сколько всего дней займёт рисунок (ёлки + промежутки)
total_weeks=$((trees * (tree_width + space_between)))
total_days=$((total_weeks * 7))

# Дата старта — от текущей даты "назад" на total_days
start_ts=$((now_ts - total_days * 86400))

for ((t=0; t<trees; t++)); do
  week_offset=$((t * (tree_width + space_between)))

  for ((week=0; week<tree_width; week++)); do
    for ((day=0; day<7; day++)); do
      char=${pattern[$day]:$week:1}
      # теперь идём вперёд от стартовой даты (которая в прошлом)
      days_offset=$(( (week_offset + week) * 7 + day ))
      day_ts=$((start_ts + days_offset * 86400))
      commit_date=$(date -r "$day_ts" +"%Y-%m-%dT12:00:00" 2>/dev/null || date -d @"$day_ts" +"%Y-%m-%dT12:00:00")

      # фон
      for ((i=0; i<background_commits; i++)); do
        echo "$commit_date bg" >> commit.txt
        git add commit.txt
        GIT_AUTHOR_DATE=$commit_date GIT_COMMITTER_DATE=$commit_date git commit -m "bg $t-$week-$day"
      done

      # звёздочки
      if [[ "$char" == "*" ]]; then
        for ((i=0; i<bright_commits; i++)); do
          echo "$commit_date pixel" >> commit.txt
          git add commit.txt
          GIT_AUTHOR_DATE=$commit_date GIT_COMMITTER_DATE=$commit_date git commit -m "tree $t-$week-$day"
        done
      fi
    done
  done
done