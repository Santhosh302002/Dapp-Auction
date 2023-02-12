// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
/* Auction based smart contact where different items will be published and people can bid for the product
   1.owner will update the product url
   2.Buyer can bid for the product from the base fee within alloted time
   3.The buyer can see the recent bid (Highest bid)
   4.The winner get to pay and collect the product 
 */
contract Auction is VRFConsumerBaseV2,AutomationCompatibleInterface {
    /* state variables*/
    address private immutable i_ownerAddress;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint16 private constant requestConfirmations=3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant numWords = 2;
    uint256 private randomNumber;
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    status private s_status;
    struct BidingDetails{
        address payable BidingAddress;
        uint256 BidingValue;
    }
    BidingDetails[] public Biding_Details;

    enum status{CLOSE,OPEN}
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
 
    /*Events */
    event RequestId(uint256 indexed RequestId);

    struct ProductItems {
        string URL_PRODUCT;
        uint256 Base_Value;
    }
    ProductItems[] private productItem;

    constructor(
        address VRFCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint16 callbackGasLimit,
        uint256 interval
        ) 
        VRFConsumerBaseV2(VRFCoordinator) {
        i_ownerAddress = msg.sender;
        i_keyHash=keyHash;
        i_subscriptionId=subscriptionId;
        i_callbackGasLimit=callbackGasLimit;
        i_vrfCoordinator=VRFCoordinatorV2Interface(VRFCoordinator);
        i_interval=interval;
        s_lastTimeStamp=block.timestamp;
        s_status=status.CLOSE;
    }

    modifier OnlyOwner() {
        require(i_ownerAddress == msg.sender, "Only Contract Owner Allowed");
        _;
    }

    function updateItem(string memory ITEM_URL, uint256 value) public OnlyOwner {
        require(s_status==status.CLOSE,"Your cant add products during the auction");
        productItem.push(ProductItems(ITEM_URL, value));
    }

    function startSuction() external {
        s_status=status.OPEN;
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
       ) internal override {
        uint256 RandomIndex = randomWords[0] % productItem.length;
        string memory URL_AuctionProduct = productItem[RandomIndex].URL_PRODUCT;
        s_lastTimeStamp = block.timestamp;
    }
    // function RequestRandomProduct() external{
    //     uint256 requestId =i_vrfCoordinator.requestRandomWords(
    //         i_keyHash,
    //         i_subscriptionId,
    //         requestConfirmations,
    //         i_callbackGasLimit,
    //         numWords
    //     );
    //     randomNumber=requestId;
    //     emit RequestId(requestId);
    // }
    function RandomNumber() public view returns(uint256){
        return randomNumber;
    }

    function checkUpkeep(bytes memory /*checkData*/) public 
     view
    override returns 
    (bool upkeepNeeded, bytes memory /* performData */){
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        upkeepNeeded = timePassed && s_status == status.OPEN;
        return (upkeepNeeded, "0x0");
        
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
         uint256 requestId =i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            requestConfirmations,
            i_callbackGasLimit,
            numWords
        );
        randomNumber=requestId;
        emit RequestId(requestId);
    }
    /*Biding for the product*/
    function Biding() public payable{
        Biding_Details.push(BidingDetails(payable(msg.sender),msg.value));
    }
    
}