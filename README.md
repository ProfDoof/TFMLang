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

### Projects

There are a variety of projects/actions that a player can take. 

1. Standard Project, these are the projects available to all players and can be thought of as Actions or an infinitely renewable source of cards
2. Actions, these are actions that players gain. These can be thought of as a set of cards that players draw every turn and discard at the end of the turn if they don't use them before drawing a new one.
3. Cards, these have a cost associated with them much like any other type of project but they can also define new actions available to players and create effects.

### Effects

Effects are passive as compared to the projects/actions active nature. These impact the cost of cards, the cost of various actions, they functionally redefine actions or redefine rules. 

# Potential Language Design

## Attempt 1

Instead of viewing things like cards, requirements, etc. as types. Let's represent them as transactional functions with aspects

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

## Attempt 2

Each specified thing is either a rule, an action, or a resource. 

Resources can be thought of as things that belong to the bank, things that belong to players, and things that correspond to real world objects such as tiles. Each resource belongs to a single individual. And they must transfer completely for each case. TRANSACTIONAL

Rules are things that impact the cost of an action, the availability of an action, the impact of resources, the usage of resources outside of actions (for example, steel being worth 2 MC for the play of a card that has a building tag).

Actions are things that players can do. Actions are only viable during certain phases of play and depend on resources to be available and other requirements.



## Current potential structure of a TFM file
All TFM files have the extension `.tfm`. They can contain definitions for resources, rules, and actions.

## Comments

To add comments to a TFM file, simply add a `#` on the same line prior to where you want to put your comments so that they are not considered as part of the TFM description. 

## Resources

Resources are basically counters. They can be moved from the bank or the global context, to a player, and back again. They can be functionally infinite, or they can have a variety of attributes associated with them. 

Currently, resources support the following:

- Min: The minimum amount of this resource that is allowed
- Max: The maximum amount of this resource that is allowed
- Scope: The scope that the resource belongs to. There are currently only three options for this but we can evaluate more as needed.
  - Card: A resource that is scoped to belong only to a card. This includes animals, microbes, etc. This may be extracted to belong to cards instead of something to be defined outside.
  - Local: A resource that is locally scoped currently belongs to each player individually. That is, each player will have their own pool of this resource. 
  - Global: A resource that is globally scoped belongs to the game alone. All players can access the same instance of this resource. Functionally, this is similar to the singleton pattern in OO programming
- Step: Some resources should only be changed by specific amounts. For example, Oxygen and Temperature can only go up. So, they can specify a step detailing exactly how much a step should change. However, a step can also point to a rule that is defined for how to handle changing the amounts on this resource.
- Unit: A string that following a number converts that number from a raw integer to an that number of instances of a resource. For example, % is the unit for Oxygen.

## Rules



## Actions

# Cards
Search for Life @ Oxygen <= 8%

```

## Current potential structure of a TFM function
```

```

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