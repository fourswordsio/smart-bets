<h1 align="center">
  <br>
  Smart Bets
  <br>
</h1>

<h4 align="center">The first fully decentralized betting platform.</h4>
<p align="center">
  <a href="#About">About</a> •
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How it works</a>
</p>

## About

Smart Bets is the first fully decentralized betting platorm. Smart bets enables you to bet anyone anywhere in the world without requiring a third party to hold funds and without ceding personal information. There Smart Bets has a modular design that enables anyone to create a specific bet type contract.

## Key Features

* Generalized betting contracts allow for betting on a multitude of different events
  - Sports
  - Fantasy sports
  - Esports
  - Dice
* Different bet types
  - Match winner
  - Over or under
  - Closest guess
* Allows anyone to create their own relayer to create and host bets

## How it works
A website, known as a relayer, assists users in creating a bet. Creating a bet entails specifying a set of bet parameters such as:
* Bet amount
* Expiration time
* Execution time
* Data URL

Once the parameters of the bet are chosen, the bet maker signs the bet the relayer displays the open bet or relays the bet to a specified user.

The bet receiver can verify the parameters of the bet and accept the bet. Accepting the bet creates a call to our betting smart contract that escrows both participants funds. 

At the specified execution time, the Chainlink decentralized oracle network retrieves the off-chain data and returns the bet results to the betting contract.

The returned data is used to determine the winner of the bet. Funds are transferred from the escrow to the winning participant.