#import from byllm.lib {Model}
import from dotenv{load_dotenv}
import from utils{get_current_datetime}
import os;
import sys;

node Memory {}

node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();

    def add_history(entry: str) {
        self.history = self.history + [entry];
    }

    def get_history -> str {
        return '\n'.join(self.history[-10:]);
    }
   

}
enum Routing_nodes {USER_PROFILE='UserProfile', USER_SKILLS='UserSkills'}


