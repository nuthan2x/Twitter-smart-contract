// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter_ADVANCED {

    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
        address[] likes;
        address[] retweets;
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

    function registerAccount(string calldata _name) external {
       require(bytes(_name).length != 0 ,"Name cannot be an empty string");
       User storage user = users[msg.sender] ;
       user.name = _name;
       user.wallet = msg.sender;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
       Tweet memory tweet = Tweet(nextTweetId,msg.sender,_content,block.timestamp,new address[](0),new address[](0));
       tweets[nextTweetId] = tweet;
       
       User storage user = users[msg.sender];
       user.userTweets.push(nextTweetId);
       nextTweetId++;
    }

    function like_orUnliketweet(uint _tweetId) external{
        address[] storage addr_array = tweets[_tweetId].likes;
        bool alreadyliked;
        uint liked_index;
        for (uint i = 0; i < addr_array.length; i++) {
            if(addr_array[i] == msg.sender) {
               alreadyliked = true; 
               liked_index = i;
               break;
            }
        }
        if (alreadyliked) { //time to dislike tweet
            delete addr_array[liked_index];
        }else {
            addr_array.push(msg.sender);
        }
    }

    function retweet_orUnretweet(uint _tweetId) external{
        address[] storage addr_array = tweets[_tweetId].retweets;
        bool already_retweeted;
        uint retweeted_index;
        for (uint i = 0; i < addr_array.length; i++) {
            if(addr_array[i] == msg.sender) {
                already_retweeted = true; 
                retweeted_index = i;
                break;
            }
        }
        if (already_retweeted) { //time to unretweet the tweet
            delete addr_array[retweeted_index];
        }else {
            addr_array.push(msg.sender);
        }
    }

    function read_userTweets(address _user) view public returns(Tweet[] memory ){
       User storage currentuser = users[_user];
       uint[] storage tweetids = currentuser.userTweets;
       
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

    function follow_OR_unfollowUser(address _user) external {
        // require(_user !== msg.sender,"you cant follow yourself");
        address[] storage following = users[msg.sender].following;
        bool alreadyfollowing; 
        uint following_index;
        for (uint i = 0; i < following.length; i++) {
            if (following[i] == _user ) {
                alreadyfollowing = true;
                following_index = i;
                break;
            }
        }
        if (alreadyfollowing) {
            delete following[following_index];
        }else {
            following[following_index] = _user;
        }

        address[] storage followers = users[_user].followers;
        bool alreadyfollows; 
        uint follower_index;
        for (uint i = 0; i < followers.length; i++) {
            if (followers[i] == msg.sender ) {
                alreadyfollows = true;
                follower_index = i;
                break;
            }
        }
        if (alreadyfollows) {
            delete followers[follower_index];
        }else {
            followers[follower_index] = msg.sender;
        }
        // User storage user = users[_user];
        // user.followers.push(msg.sender);

        // User storage caller = users[msg.sender];
        // caller.following.push(_user);


    }

    // function unfollowuser(address _user)  external {
    //     require(_user !== msg.sender,"you cant unfollow yourself");
    //     User storage caller = users[msg.sender];
    //     for (uint i = 0; i < caller.following.length; i++) {
    //         if (caller.following[i] == _user) {
    //             delete caller.following[i];
    //             break;
    //         }
    //     }

    //     User storage user = users[_user];
    //     for (uint i = 0; i < user.followers.length; i++) {
    //         if (user.followers[i] == msg.sender) {
    //             delete user.followers[i];
    //             break;
    //         }
    //     }
    // }

    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed(address _user) view external returns(Tweet[] memory) {
        address[] memory following = users[_user].following;
        uint feedlength;

        for (uint i = 0; i < following.length; i++) {
            uint[] memory tweetids = users[following[i]].userTweets;
            feedlength += tweetids.length;
        }

        Tweet[] memory latestfeed = new Tweet[](feedlength); 

        for (uint i = 0; i < following.length; i++) {
            uint[] memory tweetids = users[following[i]].userTweets;

            for (uint j = 0; j < tweetids.length; j++) {
                latestfeed[feedlength] = tweets[tweetids[j]];
            }
        }
        return latestfeed;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        require(_recipient != msg.sender,"cant sent message to yourself, change recepient");
        Message memory newmessage = Message(nextMessageId,_content,msg.sender,_recipient);
        users[msg.sender].conversations[_recipient].push(newmessage);
        users[_recipient].conversations[msg.sender].push(newmessage);
        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        return users[msg.sender].conversations[_user];
    }


}