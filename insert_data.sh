#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear existing data
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY CASCADE")

# First insert all unique teams
TEAMS=$(tail -n +2 games.csv | cut -d ',' -f 3,4 | tr ',' '\n' | sort | uniq)

while IFS= read -r TEAM
do
  if [[ -n $TEAM ]]
  then
    # Insert team if it doesn't exist
    echo $($PSQL "INSERT INTO teams(name) VALUES('$TEAM') ON CONFLICT (name) DO NOTHING")
  fi
done <<< "$TEAMS"

# Then insert all games
tail -n +2 games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Get team IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # Insert game
  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
done