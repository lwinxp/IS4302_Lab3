pragma solidity ^0.5.0;
import "./Dice.sol";
import "./DiceToken.sol";

// Flow:
// 
// user A -> Dice -> DiceTokenMarket -> (DiceToken - ERC20)
// user B -> 
// user B -> DiceTokenMarket -> (DiceToken - ERC20)


/*
DiceTokenMarket execution / test:
1. use account A to deploy Dice contract
2. use account A to deploy ERC20 contract
3. use account A to deploy DiceToken contract
4. use account A to deploy DiceTokenMarket contract with arg (Dice contract address, DiceToken contract address, 200)
5. use account A to execute Dice function add dice with arg (1,2) and value 5 ether, becomes dice 0
6. use account A to execute Dice function transfer dice with arg (0, DiceTokenMarket address)
7. use account A to execute DiceTokenMarket function list dice with arg (0, 300)
8. use account B to execute DiceTokenMarket function buy with arg (0), (with value 1 ether? or 5 ether?)
(8a. assume account B no need any DT? if error may need to DiceToken getCredit() with value 1 ether? or 5 ether?)
9. use any account to check Dice variable dices with arg (0). Prev owner of dice should be DiceTokenMarket contract address and owner of dice should be account B address
(9a. account A balance should have increase by (1 ether? or 5 ether?) and account B balance should have reduce by (1 ether? or 5 ether?))
*/

// 1. commissionFee needs to be paid in DT
// 2. price of Dice change from ETH to DT
// 2a. is buying of Dice in DT? YES!
// 2b. is seller receiving in DT? think so...
// 3. create Dice using DT, value stored in Dice change from ETH to DT (Luminus announcement said this not needed, might affect Dice and DiceBattle, don't want to affect them)

// Idea:
// Everywhere in DiceTokenMarket where have transactions that take in ETH amount, need to convert amount to DT, then
// require and check that caller has enough DT in account by calling DiceToken checkCredit method
// if not enough, trigger call to DiceToken getCredit method to add DT to the caller account (and transfer ETH to DiceToken contract address???)
// if enough, deduct DT from account instead of ETH

// Find where are the places that use and require ETH amount transaction?


contract DiceTokenMarket {
    // DiceMarket contract define variable that is Dice object named diceContract
    Dice diceContract;

    DiceToken diceTokenContract;

    uint256 public commissionFee;
    // address that deploy DiceMarket / the seller is set as "actual" _owner of the dice in this contract
    address _owner = msg.sender;
    // map dice id to price
    mapping(uint256 => uint256) listPrice;
    // DiceMarket initialise with Dice object as 1st arg
    // constructor function called during deploy
      constructor(Dice diceAddress, DiceToken diceTokenAddress, uint256 fee) public {
        // DiceMarket contract variable Dice object (diceContract) is the 1st arg Dice object (diceAddress) passed into constructor function
        diceContract = diceAddress;

        diceTokenContract = diceTokenAddress;

        commissionFee = fee;
    }
    
    // list a dice for sale, price needs to be >= value + fee
    function list(uint256 id, uint256 price) public {
       require(msg.sender == diceContract.getPrevOwner(id), "only dice owner can set list dice and set price");
       listPrice[id] = price;
    }
    
    function unlist(uint256 id) public {
        require(msg.sender == diceContract.getPrevOwner(id), "only dice owner can unlist dice");
        listPrice[id] = 0;
    }

    // get price of dice
    function checkPrice(uint256 id) public view returns (uint256) {
        return listPrice[id];
    }

    function diceTokenApprove() public {
        diceTokenContract.diceTokenApprove(msg.sender, address(this), 10000);
    }


    function approve() public {
        diceTokenContract.approve(address(this), 10000);
    }

    // buyer call this function, buyer is msg.sender
    // buy the dice at the requested price
    function buy(uint256 id) public payable {
        require(listPrice[id] != 0, "only listed dice can be bought"); // is listed
        // buyer input value needs to be higher than price + fee
        // require(msg.value >= (listPrice[id] + commissionFee), "buyer input value must equal or exceed price + commissionFee"); // offered price meets minimum ask

        // normal address is not payable
        // must define payable address
        // the dice owner / seller is the recipient, used as payable address

        address payable recipient = address(uint160(diceContract.getPrevOwner(id)));

        // ************************* //
        // Assuming that buyer already has DT and will pay DT to buy the listed Dice
        // so all info for the listed dice should already be in DT and checked in DT
        // and payout to seller is also in DT
        // ************************* //
        // solidity standard method <address>.transfer to transfer amount from the caller to the <address> of the recipient

        // diceTokenContract.diceTokenMarketGetCredit(msg.value - commissionFee);
        // diceTokenContract.transfer(recipient, diceTokenContract.checkCredit());

        // contractOfTheBuyTokensFunction.buyTokens{ value: _amount }(msg.sender);

        // can this method be used to transfer DT instead of ETH???
        
        // use ERC20 transfer methods to transfer DT instead of standard .transfer for ETH

        diceTokenContract.diceTokenApprove(msg.sender, address(this), 500);
        diceTokenContract.approve(address(this), 500);


        require(diceTokenContract.diceTokenMarketCheckCredit(msg.sender) >= (listPrice[id] + commissionFee), "buyer input value must equal or exceed price + commissionFee"); // offered price meets minimum ask
        
        // diceTokenContract.diceTokenApprove(msg.sender, address(this),listPrice[id]);

        diceTokenContract.transferFrom(msg.sender, recipient, listPrice[id]);

        // diceTokenContract.diceTokenApprove(msg.sender, address(this), commissionFee);

        diceTokenContract.transferFrom(msg.sender, address(this), commissionFee);


        // recipient.transfer(msg.value - commissionFee); // transfer (price-commissionFee) to real owner



        // Dice object custom function to transfer dice to buyer
        diceContract.transfer(id, msg.sender);
    }

    function getContractOwner() public view returns(address) {
        return _owner;
    }

    // seller of the dice call this function
    function withdraw() public {
        // if caller is seller of the dice
        if (msg.sender == _owner)
            // solidity standard method, caller to receive balalnce amount from this DiceMarket address
            // msg.sender.transfer(address(this).balance);
            
            diceTokenContract.transfer(msg.sender, diceTokenContract.checkCredit()); // assuming checkCredit() checks the DiceTokenMarket balance here ...      
    }
}







        // this is where ETH value actually enters the contract
        // this is the where ETH will convert to DT
        // and send back to the seller
        // this contract address, address(this) becomes intermediate_recipient 