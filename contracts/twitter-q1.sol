// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Twitter1 {

    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;
    uint256 public nextTweetId;

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
        User memory user = users[msg.sender];
        require(user.wallet == msg.sender,"This wallet does not belong to any account.");
        _;
    }

}