""" Codebase Genius - main jac file
This file contains the core data structures for the codebase genius multi-agent Jac application.
Codebase Genius tales a public GitHub repo URL, produces high quality markdown documentation of that 
codebase with clear prose and explanatory diagrams.
"""
import from byllm.llm{Model}
import requests;
import os;  #for file and directory handling
import git;  #for cloning Git repos
import ast;  #for parsing Abstract Syntax Tree
import from dotenv {load_dotenv}

#Load environment variables from .env file
glob env_loaded = load_dotenv();
glob llm = Model(model_name = 'gemini/gemini-2.5-flash', verbose=True);

#Enums
enum RoutingNodes {
    REPO_MAPPER='RepoMapper',
    FILE_STRUCTURE_ANALYZER='FileStrutureAnalyzer',
    CODE_ANALYZER='CodeAnalyzer',
    GENERATE_DOCUMETATION='DocGenie'
}

#nodes
node user {
    has username: str = '';
    has email: str = '';
    has password: str = '';
    }

#Analyzes structure and README
node RepoMapper {
    has github: str = os.getenv('GITHUB_URL');

    def clone_repo(git_url: str, dest: Path) -> Path {
        if dest.exists() {
            shutil.rmtree(dest); #if destiation exists remove it
        }
        dest.mkdir(parents=True, exist_ok=True); #else create destination directory
        try {
            print(f'Cloning {git_url} into {dest}');
            git.Repo.clone_from(git_url, str(dest));
            return dest;
        } except Exception as e {
            raise RuntimeError(f'Failed to clone repo: {e}');
        }
    }

}

#Parses and understands source code
node CodeAnalyzer {
    
}

#Produces the documentation and diagrams
node DocGenie {
    has created_at: str;
    has documentation: str = '';
    has graphs: str = ''; # integrates visual diagrams
}



