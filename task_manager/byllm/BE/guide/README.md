Building a Task Manager with byllm.

1. Main components:
    -TaskHandling: manages tasks(add, summarize, extract info)
    -EmailHandling: Composes and sends emails
    -GeneralChat: Handles general chats
    -Memory/Session: Tracks user history and centext
    -task_manager walker: Routes user input to the correct node

2. Project flow:
 1. Create a new folder for the project
 2. Install dependencies - pip install jaseci 
 3. Create the jac files (main.jac, mainimpl.jac, agent_core.jac)
 4. Set up the environment variables - 
        - Create a .env file for the email credentials, API_KEY
        - Create a .gitignore and put the .env file

3. Running and Testing
(open 2 terminals and: )
 1. run the jac file - jac serve main.jac - (starts the jac project server - Backend)
 2. run the app.py - stramlit run app.py - (starts the frontend) 