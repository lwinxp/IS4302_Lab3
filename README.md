# Testing Instructions

## DiceTokenMarket steps:
1. use account A to deploy Dice contract
2. use account A to deploy DiceToken contract
3. use account A to deploy DiceTokenMarket contract with arg (Dice contract address, DiceToken contract address, 2)
4. use account A to execute Dice function add dice with arg (1,2) and value 1 ETH, becomes dice 0
5. use account A to execute Dice function transfer dice with arg (0, DiceTokenMarket address)
6. use account A to execute DiceTokenMarket function list dice with arg (0, 3)
7. use account B to execute DiceToken function getCredit with value 1 ETH
8. use account B to execute DiceTokenMarket function buy with arg (0)
9. use any account to check Dice variable dices with arg (0). Prev owner of dice should be DiceTokenMarket contract address and owner of dice should be account B address
10. use account A to execute DiceToken checkCredit function to see that balance has increased by 3 DT
11. use account B to execute DiceToken checkCredit function to see that balance has reduced by 5 DT to 95 DT
* 2 DT was commission fee for DiceMarketToken)

## DiceBattle steps:
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
* Result event is relative to the account that executed battle function, as account C executed the battle, hence
* winResult - account C is owner of dice 0 and dice 1
* loseResult - account B is owner of dice 0 and dice 1
* tieResult - account B is owner of dice 0 and account C is owner of dice 1
