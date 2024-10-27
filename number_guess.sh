#!/bin/bash

# Connect to the database
PSQL="psql -U freecodecamp -d number_guess --no-align -X -tc"

# Generate a random number: 1-1000
RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)

GAME_PLAY(){
  # Guess number input
  read NUMBER
 
  if [[ $NUMBER =~ ^[0-9]+$ ]]
  then 
    # looping around gueesed number
    while [[ $NUMBER -ne $RANDOM_NUMBER ]]
    do
      let ++COUNTER
      # validating guess numner.
      if [[ $NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        GAME_PLAY
      elif [[ $NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        GAME_PLAY
      fi
    done
  else
    echo -e "\nThat is not an integer, guess again:"
    GAME_PLAY
  fi
}

MAIN_MENU(){

  echo "Enter your username:"
  read USERNAME

  local COUNTER=1

  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='${USERNAME,,}'")

  if [[ -z $PLAYER_ID ]]
  then
    # For a new player, great and add to database (in small letter)
    echo "Welcome, ${USERNAME,,}! It looks like this is your first time here."

    # Add a player
    RECORD_PLAYER="$($PSQL "INSERT INTO players (username) VALUES ('${USERNAME,,}')")"

  else
    # Get the min number of games played as best score.
    BEST_SCORE=$($PSQL "SELECT MIN(best_game) FROM games WHERE player_id=$PLAYER_ID")
    # Count games by player using player_id.
    GAMES_PLAYED=$($PSQL "SELECT COUNT(player_id) FROM games WHERE player_id=$PLAYER_ID")

    echo "Welcome back, ${USERNAME,,}! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
  fi

  # play the game
  echo "Guess the secret number between 1 and 1000:"
  GAME_PLAY 

  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='${USERNAME,,}';")
  INSERT_PLAYS=$($PSQL "INSERT INTO games(player_id, best_game) VALUES ($PLAYER_ID, $COUNTER);")
  echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"

}

MAIN_MENU
