import from byllm.lib { Model }
import from dotenv { load_dotenv }
import from utils { get_current_datetime }
import os;
import sys;

include user_core;
include walkers_file;

glob llm = Model(model_name='gemini/gemini-2.5-flash', verbose=True);

enum Routing_nodes { USER_PROFILE = 'UserProfile', USER_SKILLS = 'UserSkills' }

node UserProfile {
    #has these attributes
    has firstname: str = '';
    has surname: str = '';
    has username: str = '';
    has email: str = '';
    has password: str = '';
    has resume_path: str = '';

    def add_userprofile(
        firstname: str,
        surname: str,
        username: str,
        email: str,
        password: str,
        resume_path: str
    ) -> str by llm(method='ReAct', verbose=True);

    def validate_email(email: str) -> str by llm(method='ReAct', verbose=True);
    def email_exists(email: str) -> str by llm(method='ReAct', verbose=True);
    def email_format(email: str) -> str by llm(method='ReAct', verbose=True);
    def upload_resume(file_path: str or file_path == null) -> str by llm(
        method='ReAct', verbose=True
    );
}

#edge for user acquired skills
#*edge UserSkills {
    has skills: list[str]=[];
    has acquired_date: str;
    has certifications: list[str] = [];
}

#edge for used suggested skills
edge suggestedSkills{
    has courses: list[str] = [];
}*#
node UserSkills {
    has username: str;
    has gainedSkills: list[dict] = [];
    has certifications: list[dict] = [];

    def fetch_userskills(resume_skills: str) -> str by llm(
        method='ReAct', verbose=True
    );
}

with entry {
    load_dotenv();

    new_user_nodes = root ++> UserProfile();
    new_user = new_user_nodes[0];
    print(f'User {new_user} created successfully');


    #agent = register_user_profile_walker('User {new_user} created succesfuly');
    #new_user[0] spawn agent;
    #print('\n',agent);

    #*new_user = UserProfile(
        firstname='doris',
        surname='muasya',
        username='doris123',
        email='doris@example.com'
    );
    print(new_user);*#
}
