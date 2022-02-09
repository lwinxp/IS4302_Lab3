pragma solidity ^0.5.0;
import "./Dice.sol";


/*
1. First create dice using the Dice contract
2. Transfer both die to this contract using the contract's address
3. Use setBattlePair from each player's account to decide enemy
4. Use the battle function to roll, stop rolling and then compare the numbers
5. The player with the higher number gets BOTH dice
6. If there is a tie, return the dice to their previous owner
*/

/*
DiceBattle execution / test:
1. use account A to deploy Dice contract
2. use account A to deploy DiceBattle contract with arg (Dice contract address)
3. use account B to execute function add dice with arg (1,2) and value 1 ether, becomes dice 0
4. use account B to execute function transfer dice with arg (0, DiceBattle address)
5. use account B to execute function setBattlePair with arg (account C address, 0)
6. use account C to execute function add dice with arg (3,4) and value 3 ether, becomes dice 1
7. use account C to execute function transfer dice with arg (1, DiceBattle address)
8. use account C to execute function setBattlePair with arg (account B address, 1)
9. use account C to execute function battle with arg (1, 0, account C address, account B address)
10. in console check the diceId, newNumber and result event type (winResult, loseResult, tieResult)
11. use any account to check Dice contract variable dices with arg (0), and with arg (1). The prev owner of both dice 0 and dice 1 should be the DiceBattle address, and the new owner should reflect the result event type.
Result event is relative to the account that executed battle function, as account C executed the battle, hence
winResult - account C is owner of dice 0 and dice 1
loseResult - account B is owner of dice 0 and dice 1
tieResult - account B is owner of dice 0 and account C is owner of dice 1
*/

contract DiceBattle {
    Dice diceContract;
    mapping(address => address) public battle_pair;

    // event selectedBattlePair();
    event tieResult();
    event winResult();
    event loseResult();

    // enum result { win, lose, tie };

    constructor(Dice diceAddress) public {
        diceContract = diceAddress;
    }

    // there is 1 Dice contract address and 1 DiceBattle contract address
    // Before calling functions below, player 1 and player 2 should have completed transfer of their own dice from Dice contract to DiceBattle contract using Dice transfer method
    // hence player 1 and player 2 should be prev owner of their dice after their transfers

    // player 1 and player 2 can call this function to set their enemy, which is each other
    // enemy arg is the account address of other player, not the dice address
    function setBattlePair(address enemy, uint myDice) public {

        // Require that only prev owner can allow an enemy
        // account that is calling function / msg.sender must match dice previous owner
        require(msg.sender == diceContract.getPrevOwner(myDice), "only dice owners can setBattlePair");

        // Each player can only select one enemy
        battle_pair[msg.sender] = enemy;

        // emit selectedBattlePair();
    }

    // After player 1 and player 2 have both set setBattlePair as each other, either of them can call this battle function
    // but they must know both battling dices' diceId, and both battling accounts' addresses to input as arg
    function battle(uint256 myDice, uint256 enemyDice, address myAddress, address enemyAddress) public {
        // Require that battle_pairs align, ie each player has accepted a battle with the other
        require(battle_pair[myAddress] == enemyAddress && battle_pair[enemyAddress] == myAddress, "both players must setBattlePair as each other before they can battle");

        // Run battle
        diceContract.roll(myDice);
        diceContract.roll(enemyDice);
        diceContract.stopRoll(myDice);
        diceContract.stopRoll(enemyDice);

        uint myDiceNumber = diceContract.getDiceNumber(myDice);
        uint enemyDiceNumber = diceContract.getDiceNumber(enemyDice);

        if (myDiceNumber > enemyDiceNumber) {
            diceContract.transfer(enemyDice, myAddress);
            diceContract.transfer(myDice, myAddress);
            emit winResult();
        } else if (myDiceNumber < enemyDiceNumber) {
            diceContract.transfer(enemyDice, enemyAddress);
            diceContract.transfer(myDice, enemyAddress);
            emit loseResult();
        } else { // myDiceNumber == enemyDiceNumber
            diceContract.transfer(enemyDice, enemyAddress);
            diceContract.transfer(myDice, myAddress);
            emit tieResult();
        }
    }

    //Add relevant getters and setters

    // After Player 1 or 2 have setBattlePair, they can call this method to check their enemy, by providing their own account address as arg
    function getBattlePair(address playerAddress) public view returns(address) {
        return battle_pair[playerAddress];
    }
    // getBattlePair function is actually redundant, as we have made battle_pair variable public as well, just added getBattlePair function for practice purpose
}