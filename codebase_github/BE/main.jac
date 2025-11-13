""" Codebase Genius - main jac file
This file contains the core data structures for the codebase genius multi-agent Jac application.
Codebase Genius tales a public GitHub repo URL, produces high quality markdown documentation of that 
codebase with clear prose and explanatory diagrams.
"""
import from byllm.llm{Model}
import requests;
import streamlit as st;
import openai;
import shutil;
import graphviz;  #for graph visualization
import os;  #for file and directory handling
import git;  #for cloning Git repos
import ast;  #for parsing Abstract Syntax Tree;
from pathlib import Path;
import from dotenv {load_dotenv}
include main.impl

#Load environment variables from .env file;
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
    has git_url: str = os.getenv('GITHUB_URL');
    has dest_path: path;
    has last_repo_path: str='';

    def clone_repo(git_url: str, dest: Path) -> Path {
        if dest.exists() {
            shutil.rmtree(dest); #if destiation exists remove it
        }
        dest.mkdir(parents=True, exist_ok=True); #else create destination directory
        try {
            print(f'Cloning {git_url} into {dest}');
            git.Repo.clone_from(git_url, str(dest));
            return str(dest);
        } except Exception as e {
            raise RuntimeError(f'Failed to clone repo: {e}');
        }
    self.last_repo_path = clone_repo(visitor.git_url, visitor.dest_path); 
    }
    
}

#Returns dict of folder -> files
node FileStructureAnalyzer {
    has repo_path: str;
    has structure: dict = {};

    def analyze_file_structure(path: Any) {
        file_structure = {};
        for (root, dirs, files) in os.walk(path) {
            file_structure[root] = files;
            
        } 
        return file_structure;

    self.structure = scan_structure(visitor.repo_path);   
    }

}
#Parses and understands source code(Python and Jac) and extracts classes/functions
node CodeAnalyzer { 
    has file_path:str;
    has functions: list = [];
    has classes: list[];
    
    def analyze_code(file_path: Path) {
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

    self.functions, self.classes = analyze_code(self.file_path);
    }
}

#Produces the markdown documentation and diagrams
node DocGenie {

    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_path: str = '';
    has output_file: str = 'documentation.md';

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
            md_file.write('\n## Code Relationships\n');
            for result in analysis_results {
                md_file.write(f' - {result} \n');
            }
        }
        #where the documentation has been generated
        print(f'Documentation generated at {output_file}');
        return output_file;

    self.output_file = write_markdown(
        visitor.file_structure,
        visitor.analysis_results,
        visitor.diagram_path,
        self.output_file
    );
    }
}

node DiagramGenerator {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_file: str = 'structure_diagram.svg';

    def generate_code_diagram(file_structure: Any, analysis_results: Any) {
        ''' Build a visual code structure diagram with Graphviz.''';
        st.info('💭Generating visual code diagram...');
        dot = graphviz.Digraph(comment='Code Structure', format='svg');
        for (folder, files) in file_structure.items() {
            dot.node(folder, label=f'📁 {folder}');
            for f in files {
                node_name = f'{folder}/{f}',
                dot.node(node_name, label=f),
                dot.edge(folder, node_name)
            }
        }
        for entry in analysis_results {
            file = entry.get('file');
            for func in entry.get('functions', []) {
                dot.node(f'{file}/{func}', label=f'📦 {func}', shape='box');
                dot.edge(file, f'{file}/{func}');
            }
            for cls in entry.get('classes', []) {
                dot.node(f'{file}.{cls}', label=f'🏷{cls}', shape='ellipse');
                dot.edge(file, f'{file}/{cls}')
            }
        }
        dot.render(DIAGRAM_PATH, cleanup=True);
        return DIAGRAM_PATH + ('.svg')
    }

    def summarize_with_llm(code_summary: str) -> str by llm{
        ''' Generate a human-readable summary using OpenAI or Gemini.'''
        if not openai.api_key{
            return '⚠️ LLM sumarization skipped (no API key)!'
        }
        try {
            response = openai.ChatCopletion.create(
                model = 'gemini/gemini-2.5-flash',
                messages = [
                    {'role':'system', 'content':'You are a documentation assistant'},
                    {'role':'user', 'content':f'Summarize this codebase:\n{code_summary}'}
                ],
                temparature=0.5,
            )
            return response.choices[0].messages.content.strip();
        }
        except Exception as e{
            return f' ⚠️ LLM Summarization failed: {e}';
        }
    }
}



