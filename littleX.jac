from littleX import *

#1. Define what exists - the nodes that store info

node Profile {
    has username: str;
    can update with update_profile entry;
}
node User {
    has username: str;
}
node Tweet {
    has tweet: str;
}
node Comment {
    has comment: str;
}

#2. Walkers - make things happen
walker create_tweet(visit_profile) {
    has content: str;
    can tweet with Profile entry;
}
#3. Edges - connect your data
edge Follow {}

edge Post {}

edge Like {}

#4. Define how things work
impl Profile.update {
    self.username = here.new_username;
    report self;
}

#5. test functionality
test create_tweet {
    root spawn create_tweet(content = 'Hello X World!');
    tweet = [root --> (?Profile) --> (?Tweet)][0];
    check tweet.content == 'Hello X World';
}