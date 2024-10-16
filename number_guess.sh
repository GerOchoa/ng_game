#!/bin/bash

# Origen de la base de datos
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Pedir nombre de usuario
echo -e "\nEnter your username:"
read USERNAME

# Obtener datos de usuario
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

# Si el jugador no existe
if [[ -z $USERNAME_RESULT ]]
then
    # Saludar al jugador
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    # Agregar jugador a la base de datos
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    GAMES_PLAYED=0
    BEST_GAME="N/A"
else
    # Obtener estadísticas de juego
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generar número secreto
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Conteo de intentos
GUESS_COUNT=0

# Primer intento
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# Lógica del juego
until [[ $USER_GUESS -eq $SECRET_NUMBER ]]
do
    # Verificar si es un número
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
        # Pedir número válido
        echo -e "\nThat is not an integer, guess again:"
    else
        # Comparar y dar pista
        if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
        else
            echo "It's lower than that, guess again:"
        fi
    fi
    read USER_GUESS
    ((GUESS_COUNT++))
done

# Actualizar conteo cuando termina el juego
((GUESS_COUNT++))

# Actualizar el número de juegos y el mejor juego
if [[ $BEST_GAME == "N/A" || $GUESS_COUNT -lt $BEST_GAME ]]
then
    BEST_GAME=$GUESS_COUNT
fi

GAMES_PLAYED=$((GAMES_PLAYED + 1))

# Actualizar los resultados en la base de datos
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username='$USERNAME'")

# Mensaje en caso de ganar
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
