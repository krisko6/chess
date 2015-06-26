# Chess

## Description

Ruby-based implementation of the classic game, designed for 2 players.
First type a row, then a space, then a number. You'll do this to pick up and move pieces.
Note that you cannot move a piece if it will leave you in check.

## Code Information.

Renders board using colorize gem and unicode fonts. Clears screen after every move.
Deeply dups board and tests moves to ensure that a move does not leave a player
in check.
