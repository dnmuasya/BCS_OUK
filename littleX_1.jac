#from littleX import *
import:py os;
import:py logging;
import:py datetime;
import:py from jac_cloud.core.architype { NodeAnchor }
import:py from mtllm.llms { OpenAI }

with entry {
    os.environ["GEMINI_API_KEY"] = "AIzaSyA4nuorbyoPK22bV0NVyxZY9nqMNKZBc78";
}

glob logger = logging.getLogger("littelX");

#when someone signs up create their profile if 
# it does not exist, or visit the existing profile
walker visit_profile {
    can visit_profile with `root entry;
}

impl visit_profile.visit_profile {
    visit [--> (?Profile)]
    else {
        new_profile = here ++> Profile();
        grant(new_profile[0], level-ConnectPerm);
        visit new_profile
    }
}
#Post messages - Creates a new tweet with user's
# message and connects it to their profile
walker create_tweet(visit_profile) {
    has content: str;
    can tweet with Profile entry;
}
impl create_tweet.tweet {
    embedding = vectorizer.fit_transform([self.content]).toarray().tolist();
    tweet_node = here +>:Post():+> Tweet(content=self.content, embedding=embedding);
    grant(tweet_node[0], level=ConnectPerm);
    report tweet_node;
}

#Build your network - follow other users
walker follow_request {}

impl Profile.follow {
    current_profile = [root --> (`?Profile)];
    current_profile[0] +>:Follow():+> self;
    report self;
}

#View your feed - see your posts and posts from
# people you follow
walker load_feed(visit_profile) {
    has search_query: str = '';
    has results: list = [];
    can load with Profile entry;
}

impl load_feed.load {
    visit [-->(`?Tweet)];
    for user_node in [->:Follow:->(`?Profile)] {
        visit [user_node -->(`?Tweet)];
    }
    report self.results;
}