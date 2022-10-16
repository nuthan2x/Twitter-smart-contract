// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    function registerAccount(string calldata _name) external {
       require(bytes(_name).length != 0 ,"Name cannot be an empty string");
       User storage user = users[msg.sender] ;
       user.name = _name;
       user.wallet = msg.sender;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
       Tweet memory tweet = Tweet(nextTweetId,msg.sender,_content,block.timestamp);
       tweets[nextTweetId] = tweet;
       
       User storage user = users[msg.sender];
       user.userTweets.push(nextTweetId);
       nextTweetId++;
    }

    function readTweets(address _user) view external returns(Tweet[] memory ){
       User storage currentuser = users[_user];
       uint[] storage tweetids = currentuser.userTweets;
       console.log('tweetids: ', tweetids.length);
       
       Tweet[] memory tweetarray= new Tweet[](tweetids.length);
       for (uint i = 0; i < tweetids.length; i++) {
        tweetarray[i] = tweets[tweetids[i]];
       }
       return tweetarray;
    }
        
        
    modifier accountExists(address _user) {
        User storage user = users[msg.sender];
        require(user.wallet == msg.sender,"This wallet does not belong to any account.");
        _;
    }

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external {
        User storage user = users[_user];
        user.followers.push(msg.sender);

        User storage caller = users[msg.sender];
        caller.following.push(_user);
    }

    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory alltweets = new Tweet[](nextTweetId);
        for (uint i = 0; i < nextTweetId; i++) {
            alltweets[i] = tweets[i];
        }
        return alltweets;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        Message memory newmessage = Message(nextMessageId,_content,msg.sender,_recipient);
        users[msg.sender].conversations[_recipient].push(newmessage);
        users[_recipient].conversations[msg.sender].push(newmessage);
        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        return users[msg.sender].conversations[_user];
    }
    // ----- END OF QUEST 2 ----- //
}