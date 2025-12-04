#iadd user profile

impl UserProfile.add_userprofile{
    new_user = UserProfile(
        firstname=self.firstname, 
        surname=self.surname, 
        email=self.email, 
        username=self.username, 
        password=self.password);
    #self ++> new_user;
    #return 'User added successfully!';
    
    here ++> new_user;
    return 'User: {new_user} created successfully';
    disengage;
}

#check and validate the email 
impl UserProfile.validate_email {
    
    return std.regex_match(
        pattern = '^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]{2,}$',
        text = email
    );
    disengage;
}
impl UserProfile.email_exists {
    users = std.find_nodes(node_type = 'UserProfile');
    for u in users {
        if (u.email == email) {
            return true;
        }
        return false;
    }
    disengage;
}
impl UserProfile.email_format {
    if (!validate_email(email=email)) {
        std.err('Invalid email format!');
        return;
    }
    if (email_exists(email=email)) {
        std.err('Email already exists!');
        return;
        disengage;
    }
}


impl UserProfile.upload_resume {
    if (file_path == '' or file_path == null) {
        std.err('Invalid file path!');
        return;
    }
    self.resume_path = file_path;
    return 'Resume uploaded successfully';
    disengage;
}

impl UserProfile.view_all_users{
    user_handling_node = [root-->( ` ? UserProfile ) ];
    if not user_handling_node {
        return 'No registered users found.' ;
        disengage;
    }
    return f'{self.firstname} + {self.surname} >> {self.email}';
    return [user_handling_node[0]-->( ` ? UserProfile ) ] ;
}
