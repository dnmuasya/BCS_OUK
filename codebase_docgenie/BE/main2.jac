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

import from dotenv {load_dotenv}
include main.impl;

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
    has git_url: str = '';
    has dest_path: path;
    has last_repo_path: str='';

    can clone using root {
        py:
            import os
            import git
            import shutil
            from pathlib import Path

            def clone_repo(git_url, dest):
                dest = Path(dest)
                if dest.exists():
                    shutil.rmtree(dest) #if destination exists remove it  
                dest.mkdir(parents=True, exist_ok=True) #else create destination directory
                try:
                    print(f'Cloning {git_url} into {dest}')
                    git.Repo.clone_from(git_url, str(dest))
                    return str(dest);
                except Exception as e:
                    raise RuntimeError(f'Failed to clone repo: {e}')

            #call the helper using visitor-provided inputs
            self.last_repo_path =py::clone_repo(visitor.git_url, visitor.dest_path)     
        -> 
            #after the python block completes we are back in Jac scope
            print('RepoMapper: cloned -> ', self.last_repo_path);

        
    }
    
}

#File Structure Analyzer
node FileStructureAnalyzer{
    has repo_path: str;
    has structure: dict = {};

    can scan using root {
        py: 
            import os
            from pathlib import Path


            def scan_structure(base_path):

                fs = {}
                base = Path(base_path)
                #walk and collect files(skip hidden files)
                for root, dirs, files in os.walk(base_path):
                    rel = os.path.relpath(root, base_path)
                    if rel == '.':
                        rel = ''
                    fs[rel] = [f for f in files if not f.startswith('.')]
                return fs
            self.structure = scan_structure(visitor.repo_path)
        ->
            print('FileStructureAnalyzer: scanned', len(self.structure), 'folders')
            
    }
}

#Parses and understands source code(Python and Jac) and extracts classes/functions
node CodeAnalyzer {
    has file_path: str = '';
    has functions: list = [];
    has classes: list = [];
    
    can analyze using root {
        py:
            import ast
            from pathlib import Path

            def analyze_code(file_path):
            functions = [];
            classes = [];
            p = Path(file_path)
            if not p.exists():
                return functions, classes
            try:
                #Python files: use ast
                if file_path.endswith('.py'):
                    with open(file_path, 'r') as f:
                        tree = ast.parse(f.read())
                        for node in tree.body:
                            if isinstance(node, ast.FunctionDef)
                                functions.append(node.name)
                            elif isinstance(node, ast.ClassDef):
                                classes.append(node.name)
                # Jac files: heuristic parsing
                elif file_path.endswith('.jac'):
                    with open(file_path, 'r') as f:
                        lines = f.readlines()
                        for line in lines:
                            if line.strip().startswith('def '):
                                functions.append(line.split()[1])
                            elif line.strip().startswith('node '):
                                classes.append(line.split()[1])
            
            except Exception as e:

                return functions, classes
            return functions, classes
    
        self.functions, self.classes = analyze_code(silf.file_path)
    ->
        print('CodeAnalyzer:', visitor.file_path, '-> functions', len(self.functions), 'classes:', len(self.classes));
    }
}
    
#Produces the markdown documentation and diagrams;
node DocGenie{

    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_path: str = '';
    has output_file: str = 'documentation.md';

    can write using root {
        py:
            def generate_markdown_documentation(file_structure, analysis_results, output_file): 
                with open(output_file, 'w') as md_file:
                    md_file.write('Project Documentation \n')
                    md_file.write('File Structure \n')
                    for directory, files in file_structure.items():
                        md_file.write(f' {directory} '\n);

                        for file in files: 
                            md_file.write(f' - {file} \n')
                
            
                    md_file.write('\n## Code Relationships\n')
                    for result in analysis_results {
                        md_file.write(f' - {result} \n')
                        if result[''classes]:
                            md.write(f' - Classes: {', '.join(entry['classes'])}\n')
                        if result['functions']:
                            md.write(f' - Functions: {', '.join(entry['functions'])}\n')
                    md.write(f'\n ##Structure Diagram\n![Diagram]({diagram_path})\n')
            
        
                #where the documentation has been generated
                print(f'Documentation generated at {output_file}')
                return output_file
        -> 

            self.output_file = write_markdown(
                visitor.file_structure,
                visitor.analysis_results,
                visitor.diagram_path,
                self.output_file
            );
        }
    }
}    

node DiagramGenerator {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_file: str = 'structure_diagram.svg';

    can build using root {
        py: 

            import graphviz
            def generate_code_diagram(file_structure, analysis_results):
                ''' Build a visual code structure diagram with Graphviz.''';
                st.info('💭Generating visual code diagram...');
                dot = graphviz.Digraph(comment='Code Structure', format='svg');
                for folder, files in file_structure.items():
                    dot.node(folder, label=f'📁 {folder}');
                    for f in files :
                        node_name = f'{folder}/{f}'
                        dot.node(node_name, label=f)
                        dot.edge(folder, node_name)
                    
                
                for entry in analysis_results {
                    file = entry.get('file');
                    for func in entry.get('functions', []):
                        dot.node(f'{file}/{func}', label=f'📦 {func}', shape='box');
                        dot.edge(file, f'{file}/{func}')
                    }
                    for cls in entry.get('classes', []):
                        dot.node(f'{file}.{cls}', label=f'🏷{cls}', shape='ellipse')
                        dot.edge(file, f'{file}/{cls}')
                
            
                dot.render(DIAGRAM_PATH, cleanup=True);
                return DIAGRAM_PATH + ('.svg')
        ->
            self.diagram_file = generate_diagram(
                visitor.file_structure, visitor.analysis_results, 'structure_diagram'
            );
    
    }


}
 
node LLMDocGenerator {
    has model_name: str = 'gemini/gemini-2.5-flash';

    def summarize_with_llm(code_summary: str) -> str by llm{
        ''' Generate a human-readable summary using OpenAI or Gemini.'''
        py:
            import openai
            import os

            def summarize_with_llm(code_summary, model_name):

                if not openai.api_key:
                    return '⚠️ LLM summarization skipped (no API key)!'
                
                try: 
                    response = openai.ChatCompletion.create(
                        model = 'gemini/gemini-2.5-flash',
                        messages = [
                            {'role':'system', 'content':'You are a documentation assistant'},
                            {'role':'user', 'content':f'Summarize this codebase in concise Markdown:\n\n{code_summary}'}
                        ],
                        temperature=0.5,
                    )
                    return response.choices[0].messages.content.strip();
                
                except Exception as e:
                    return f' ⚠️ LLM Summarization failed: {e}'
                
        ->
            result = summarize_with_llm(visitor.code_summary, self.model_name);
            print('Summary Generated:\n', result);
            return result;  
    }

}
    
    



