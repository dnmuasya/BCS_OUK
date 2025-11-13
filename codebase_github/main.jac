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

#Clones the URL github
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

node FileStructureAnalyzer {

    def analyze_file_structure(path: Any) {
        file_structure = {};
        for (<>root, dirs, files) in os.walk(path) {
            file_structure[<>root] = files;
            
        } 
        return file_structure;
    }
}
#Parses and understands source code
node CodeAnalyzer { 
    
    def analyze_code(file_path: Any) {
        with open(file_path, 'r') as file {
            <>node = ast.parse(file.read(), filename=file_path);

        }
        functions = [];
        classes = [];
        for item in <>node.body {
            if isinstance(item, ast.FunctionDef) {
                functions.append(item.name);
            } elif isinstance(item, ast.ClassDef) {
                classes.append(item.name);
            }

        }
        return (functions, classes); # returns as a tuple for both functions and classes
    }
}

#Produces the markdown documentation and diagrams
node DocGenie {

    has documentation: str = '';
    has graphs: str = ''; # integrates visual diagrams

    def generate_markdown_documentation(file_structure: Any, analysis_results: Any, output_file: Any) 
    {
        with open(output_file, 'w') as md_file {
            md_file.write('# Project Documentation\n\n');
            md_file.write('## File Structure\n');
            for (directory, files) in file_structure.items() {
                md_file.write(f' ## {directory} \n');

                for file in files {
                    md_file.write(f' - {file} \n');
                }
            }
            md_file.write('\n## Code Relationshipa\n');
            for result in analysis_results {
                md_file.write(f' - {result} \n');
            }
        }
        #where the documentation has been generated
        print(f'Documentation generated at {output_file}');
    }
}



