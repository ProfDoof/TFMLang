# Goals

- A specification language for Terraforming Mars that is easy for non-programmers to read and write
- An compiler for said language that converts the language into appropriate rust constructs for use in the game, or perhaps a higher-level scripting language.
- Stretch goal: Make the language generic enough for usage with defining other board games. 

# Terraforming Mars Mechanics

## Global Parameters

There are global parameters that are impacted by the players and correspond to the end state of the game

## Player Tableau

Each player has a tableau that contains information about the types of cards they have played, the actions they can take,
and the cards they have, as well as resources and production. 

### Resources and Production

Every player has an individual tableau that keeps track of the amount of each resource that they have and how much
of each resource they produce. These resources can be impacted by cards, other players, events in-game, etc.

### Cards

Each card has a name, tags that correspond to the type of card that it is, and the rules that it performs on the game. 

These rules fall into multiple flavors. 

- Production: These change the amount of resources produced by the player by adjusting their current tableau
- Resource change: Changes the amount of resources on a players tableau directly (including cards)
- Action: These add an extra action that players can take each turn
- Effect: These add some effect to the game that the player leverages in a variety of way to impact production, cost, and resources


# Potential Language Design

Instead of viewing things like cards, requirements, etc. as types. Let's represent them as transactional functions

Goals:
- Every transaction is a sequence of transactions
- Every transaction can fail
- If a transaction fails, the function fails and says which transaction failed
    - Unless the transaction was made in fail mode which says that if it fails it doesn't matter
- Every transaction can be asked if it will fail

This is basically a pipelining language that aggregates requirements to the highest level

Another way to think about it is that all functions must return results. 

Another potential design though is to make it a composition language where each function adds information to the final result until
you have completely defined a rule or card. Thus, anything that wants to use it uses the full information but anyone outside looks at
it as a method of defining a card. However, if this is the case, might it be better to just use something like yaml or toml?

## Current potential structure of a TFM function
```
Keywords of function: arg1 arg2, ...
More keywords: arg1 arg2, ...
requires req1, req2
is function_type
|> tfm function
|> tfm function
|> tfm function
```

```
Keywords of function: arg1 arg2, ...
More keywords: arg1 arg2, ...
@ req1, req2
| tfm function
| tfm function
| tfm function
```

```
Pay: num res
@ currentPlayer.has(num, res)
|> currentPlayer.remove(num, res) 

Produce: change res, ...
@ currentPlayer.can(change, res)
|> currentPlayer.change(change, res)

Add: thing
to: tile
@ not tile.has(1, thing)
|> tile.add(thing)

Space Elevator
@ Any                         // Equivalent to not being here 
|> Pay 27 MC
|> Produce +1 Titanium, +1 Steel
|> Add City to Chosen Tile
|> Worth (1 per city)
```

# Designing a Game AI

## Goal

Design and implement a reasonably proficient Terraforming Mars Game AI

- Reasonably proficient Game AI are useful for novice players to learn more about the game as well as providing a method to give 
  novice users some help by pointing to potentially viable plays. 


## Value of a Card

To determine the value of a card, I need to determine the predicted impact of said card. Some cards are very straightforward,
they simply give you a specific amount of a resource and so the value is the value of those resources. However, others have a 
value tied to how much longer the game will continue. So, the best way to model that value is by the probability that the game
will continue to that generation and how much value that card will add over that period of time. Then, you basically just do
integration over that probability distribution scaled by the value of the card per generation. 

Then there are cards that are even more difficult as they are not tied directly to a generation but instead are tied to some action
over a generation. For example, cards that give you value every time that a city gets placed. Their value might be very high some
turns but very low other turns. So to predict those cards value, you need to predict how many cities will get placed and if you want
to identify the best generation to play them you need to predict when those cities will get placed. 

Finally, the value depends on the goal of the game. When the goal is simply to raise the global parameters, then things are simple
as we define our value in terms of how close this gets us to our goal. However, if the goal is to win as well, then we need to tie
the value to the impact that our actions will have on our final score.

So, a tentative value function might look something like this

```rs
fn value(card) {
    let prod_value = card.production()
}
```