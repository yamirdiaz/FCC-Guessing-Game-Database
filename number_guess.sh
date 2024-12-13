#!/bin/bash
#create PSQL query variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ASK_USER() {
  echo Enter your username:
  read USER

  FIND_USER_RESULT=$($PSQL "SELECT username FROM usernames WHERE username='$USER'")
  #if user is not found
  if [[ -z $FIND_USER_RESULT ]]
  then
    echo "Welcome, $USER! It looks like this is your first time here."
    # generating the random number
    RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))
   
    echo "Guess the secret number between 1 and 1000:"
    read GUESS_NUMBER
    COUNT=1
    # WHILE user guess
    while [[ $RANDOM_NUMBER != $GUESS_NUMBER ]]
    do
      #IF guess number is not INT
      if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
        read GUESS_NUMBER
      else
        #IF is an INT
        #if guess number is less than random number
        if [[ $GUESS_NUMBER < $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
        else
          #IF guess number is greater than random number
          echo "It's lower than that, guess again:"
        
        fi
        COUNT=$(( COUNT + 1 ))
        
        read GUESS_NUMBER
      fi
    done
    echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    #add the new user
    ADDING_USER_RESULT=$($PSQL "INSERT INTO usernames(username) VALUES('$USER')")
    #if user is added correctly
    if [[ $ADDING_USER_RESULT == "INSERT 0 1" ]]
    then
      #getting user ID
      USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username='$USER'")
      
      #insert games in database
      ADDING_GAME_RESULT=$($PSQL "INSERT INTO games(guess_count, user_id) VALUES($COUNT, $USER_ID)")
    else
      echo "Error: User not added successfully"
    fi
    
  else 
    # if user is found
    RECORD_USER_ANSWER=$($PSQL "SELECT COUNT(game_id), MIN(guess_count) FROM games LEFT JOIN usernames USING(user_id) WHERE username='$USER'")
    echo "$RECORD_USER_ANSWER" | while IFS="|" read GAMES_PLAYED BEST_GAME
    do
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
    RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))
    
    echo "Guess the secret number between 1 and 1000:"
    read GUESS_NUMBER
    COUNT=1
    # WHILE user guess
    while [[ $RANDOM_NUMBER != $GUESS_NUMBER ]]
    do
      #IF guess number is not INT
      if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
        read GUESS_NUMBER
      else
        #IF is an INT
        #if guess number is less than random number
        if [[ $GUESS_NUMBER < $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
        else
          #IF guess number is greater than random number
          echo "It's lower than that, guess again:"
        
        fi
        COUNT=$(( COUNT + 1 ))
        
        read GUESS_NUMBER
      fi
      
    done
    echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    #getting user ID
    USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username='$USER'")
    
    #insert games in database
    ADDING_GAME_RESULT=$($PSQL "INSERT INTO games(guess_count, user_id) VALUES($COUNT, $USER_ID)")
         
    
  fi
}

ASK_USER
