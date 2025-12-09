#1. WALKERS FOR USERPROFILE NODE
#walker validate entries
walker validate_user_entries_walker {
    has firstname: str = '';
    has surname: str = '';
    has username: str = '';
    has email: str = '';
    has password: str = '';
    has resume_path: str = '';

    obj __specs__ {
        static has auth: bool = False;
    }

    can validate_new_user with `root entry {
        if len(self.firstname) < 2 {
            try {
                raise ValueError('Enter a valid name') ;
            } except ValueError as e {
                report {'error': 'Name must be at least 2 characters'} ;
                return;
            }
        }
        if len(self.surname) < 2 {
            try {
                raise ValueError('Enter a valid name') ;
            } except ValueError as e {
                report {'error': 'Surname must at least be 2 characters'} ;
                return;
            }
        }
        if self.username == visitor.username {
            report {'error: Username already in use by another user'} ;
            return;
        }

        if len(self.password) < 6 or len(self.password) > 12 {
            report {'error': 'Password must be between 6 to 12 characters!'} ;
            return;
        }
        visit [-->];
    }
}

#walker register user profile
walker register_user_profile_walker {
    has firstname: str = '';
    has surname: str = '';
    has username: str = '';
    has email: str = '';
    has password: str = '';
    has resume_path: str = '';

    obj __specs__ {
        static has auth: bool = False;
    }

    def register_user_profile(utterance: str) -> str by llm(
        method='ReAct',
        tools=[
            add_userprofile,
            validate_email,
            email_exists,
            email_format,
            upload_resume
        ]
    );

    can add_userprofile with `root entry {
        #Register User
        new_user = (
            root ++> UserProfile(
                firstname=self.firstname,
                surname=self.surname,
                username=self.username,
                email=self.email,
                resume_path=self.resume_path
            )
        )[0];
        here ++> new_user;
        report {
            'message': 'User profile created',
            ' - Name: ': new_user.firstname + " " + new_user.surname,
            ' - Username ': self.username,
            ' - Email ': self.email
        } ;
    }
    #exit node
    can log_visit with entry {
        node_type = type(here).__name__;
        print(f'Visited {node_type}');
    }
}

#modify user profile
walker update_user_profile_walker {
    has firstname: str = '';
    has surname: str = '';
    has username: str = '';
    has email: str = '';

    obj __specs__ {
        static has auth: bool = False;
    }

    can modify_user_profile with `root entry {
        target_user = [-->(`?UserProfile)](?email==self.email);

        if target_user {
            profile = target_user[0];
            if self.firstname {
                profile.firstname = self.firstname;
            }
            if self.surname {
                profile.surname = self.surname;
            }
            if self.username {
                profile.username = self.username;
            }
            report {'User Profile updated','email' >> email} ;
        } else {
            report {'Error': 'User Profile not found'} ;
        }
        visit [-->];
    }
    #exit node
    can log_visit with entry {
        node_type = type(here).__name__;
        print(f'Visited {node_type}');
    }
}

#delete user profile
walker delete_user_profile_walker {
    has email: str = '';

    obj __specs__ {
        static has auth: bool = False;
    }

    can remove_user with `root entry {
        target_user = [-->(`?UserProfile)](?email==self.email);

        if target_user {
            profile = target_user[0];
            #Delete userprofile and its connections
            del profile ;
            report {'User Profile deleted','email' >> self.email} ;
        } else {
            report {'User Profile not found'} ;
            visit [-->];
        }
    }
    #exit node
    can log_visit with entry {
        node_type = type(here).__name__;
        print(f'Visited {node_type}');
    }
}

walker get_users {
    has userprofile: str = '';

    obj __specs__ {
        static has auth: bool = False;
    }

    def view_all_users()  -> str {
        return f"Registered {self.user_count} user profiles";
    }

    can fetch_all_users with `root entry {
        all_users = [-->(`?UserProfile)];
        users_data = [{'username': n.username, 'email': n.email} for n in all_users];
        report {'users': users_data, 'total': len(users_data)} ;
    }
}

#2. WALKER FOR USERSKILLS NODE
walker user_skills_extract_walker {
    has gainedSkills: list[dict] = [];
    has certifications: list[dict] = [];

    obj __specs__ {
        static has auth: bool = False;
    }

    def extract_user_skills_by_llm(resume: str) -> UserProfile by llm(
        method='ReAct', verbose=True
    );

    can extract_userskills with `root entry {
        target_user = [-->(`?UserSkills)](?email==self.email);
        result = self.extract_userskills(
            self.gainedSkills['skills'], self.certifications['certifications']
        );
        print('Skills gained and Certifications done: ' + result);
    }
}
