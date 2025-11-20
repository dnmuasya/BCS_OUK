## """Codebase Genius - main jac file
# This file contains the core data structures for the codebase genius multi-agent Jac application.
 # Codebase Genius tales a public GitHub repo URL, produces high quality markdown documentation of that
 # codebase with clear prose and explanatory diagrams.
 # """
 import from byllm.llm { Model }
import from dotenv { load_dotenv }
import graphviz;
import git;
import shutil;
import os;


#Load environment variables from .env file;
glob env_loaded = load_dotenv();
glob llm = Model(model_name='gemini/gemini-2.5-flash', verbose=True);


#Enums
 enum RoutingNodes { REPO_MAPPER = 'RepoMapper' , FILE_STRUCTURE_ANALYZER = 'FileStructureAnalyzer' , CODE_ANALYZER = 'CodeAnalyzer' , GENERATE_DOCUMENTATION = 'DocGenie' , GENERATE_SUMMARY = 'LLMDocGenerator' }


#nodes
#Clones the URL github;
 node RepoMapper {
    has git_url: str = '';
    has dest_path: str = '';
    has last_repo_path: str = '';

    can clone with `root entry {
        ::py::
            import git
            import shutil
            from pathlib import Path

            def _clone_repo(git_url, dest):
                git_url = print("Enter Git URL to clone:")
                self.git_url = input("Git URL: ")

                dest_path = Path(dest_path)

                if dest_path.exists():
                    shutil.rmtree(dest_path) #if destination exists remove it  
                
                dest_path.mkdir(parents=True, exist_ok=True) #else create destination directory
                
                try:
                    print(f'Cloning {git_url} into {dest_path}')
                    git.Repo.clone_from(git_url, str(dest_path))
                    return str(dest_path)
                except Exception as e:
                    raise RuntimeError(f'Failed to clone repo: {e}')

            #call the helper using visitor-provided inputs
            self.last_repo_path = _clone_repo(self.git_url, self.dest_path)    
        ::py::

        #after the python block completes we are back in Jac scope
        print(
            'RepoMapper cloned -> ', self.last_repo_path
        );
    }
}


#File Structure Analyzer;
node FileStructureAnalyzer {
    has repo_path: str = '';
    has structure: dict = {};

    can scan with `root entry {
        ::py:: 
            import os
            from pathlib import Path


            def _scan_structure(base_path):

                fs = {}
                base = Path(base_path)
                if not base.exists():
                    return fs
                #walk and collect files(skip hidden files)
                for root, dirs, files in os.walk(str(base)):
                    rel = os.path.relpath(root, str(base))
                    if rel == '.':
                        rel = ''
                    fs[rel] = [f for f in files if not f.startswith('.')]
                return fs

            self.structure = _scan_structure(self.repo_path)
        ::py::

        print('FileStructureAnalyzer: scanned', len(self.structure), 'folders');
    }
}


#Parses and understands source code(Python and Jac) and extracts classes/functions
node CodeAnalyzer {
    has file_path: str = '';
    has functions: list = [];
    has classes: list = [];

    can analyze with `root entry {
        ::py::
            import ast
            from pathlib import Path

            def _analyze_code(file_path):
                functions = []
                classes = []
                p = Path(file_path)
                if not p.exists():
                    return functions, classes

                try:
                    #Python files: use ast
                    if p.suffix == '.py':
                        with p.open( 'r', encoding='utf-8') as f:
                            src = f.read()
                        tree = ast.parse(src, filename=str(p))
                        for node in tree.body:
                            if isinstance(node, ast.FunctionDef):
                                functions.append(node.name)
                            elif isinstance(node, ast.ClassDef):
                                classes.append(node.name)
                    # Jac files: heuristic parsing
                    elif p.suffix in ('.jac', '.j'):
                        with p.open('r', encoding='utf-8') as f:
                            for line in f:
                                s = line.strip()
                                if s.startswith('def '):
                                    name = s.split()[1].split("(")[0]
                                    functions.append(name)
                                elif s.startswith('node '):
                                    name = s.split()[1].split("(")[0]
                                    classes.append(name)
                
                except Exception as e:
                    #keep what we found; log the error for debugging
                    print('CodeAnalyzer parse error: ', e)
                    return functions, classes
                    
                return functions, classes
             #analyze and store results on node
            self.functions, self.classes = _analyze_code(self.file_path)
        ::py::

    #print('CodeAnalyzer:', visitor.file_path,  'functions', len(self.functions), 'classes:', len(self.classes));
     }
}


#Produces the markdown documentation and diagrams;
node DocGenie {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_path: str = '';
    has output_file: str = 'documentation.md';

    can write with `root entry {
        ::py::
            from pathlib import Path

            def _generate_markdown_documentation(file_structure, analysis_results, diagram_path, output_file): 
                with open(output_file, 'w', encoding='utf-8') as md_file: 
                    md_file.write('Project Documentation \n\n')
                    md_file.write('File Structure \n\n')

                    for directory, files in file_structure.items():
                        md_file.write(f" {directory or '/'} \n");

                        for fn in files: 
                            md_file.write(f' - {fn} \n')
                        md_file.write('\n')
            
                    md_file.write('\n## Code Relationships\n\n')
                    for entry in analysis_results:
                        fname = entry.get('file', 'UNKNOWN')
                        md_file.write(f' - {fname} \n')
                        if entry.get('classes'):
                            md_file.write(f" - Classes: {', '.join(entry['classes'])}\n")
                        if entry.get('functions'):
                            md_file.write(f" - Functions: {', '.join(entry['functions'])}\n")
                        md_file.write('\n')

                    if diagram_path:
                        md_file.write(f'\n ##Structure Diagram\n')
                        md_file.write(f'![Diagram]({diagram_path})\n')
            
        
                #where the documentation has been generated
                print(f'Documentation generated at {output_file}')
                return output_file

                #call and store result (inside same python block)
                self.output_file = _generate_markdown_documentation(
                    self.file_structure,
                    self.analysis_results,
                    self.diagram_path,
                    self.output_file
                  );
        ::py::

        print('DocGenie: Wrote -> ', self.output_file);
    }
}


node DiagramGenerator {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_file: str = 'structure_diagram.svg';

    can build with `root entry {
        ::py:: 

            import graphviz
            from pathlib import Path

            def _generate_code_diagram(file_structure, analysis_results, diagram_path):
                ''' Build a visual code structure diagram with Graphviz.''';
                
                dot = graphviz.Digraph(comment='Code Structure', format='svg');

                #folders and files
                for folder, files in file_structure.items():
                    folder_id = folder or 'root'
                    dot.node(folder_id, label=str(folder_id));

                    for fn in files :
                        file_id = f"{folder_id}/{fn}"
                        dot.node(file_id, label=str(fn))
                        dot.edge(folder_id, file_id)
                    
                #functions and classes
                for entry in analysis_results:
                    file = entry.get('file')
                    if not file:
                        continue

                    for func in entry.get('functions', []):
                        func_id = f'{file}/{func}'
                        dot.node(func_id, label=str(func), shape='box');
                        dot.edge(file, func_id)
                    
                    for cls in entry.get('classes', []):
                        cls_id = f'{file}/{cls}'
                        dot.node(cls_id, label=str(cls), shape='ellipse')
                        dot.edge(file, cls_id)
                
                
                output = dot.render(filename=diagram_path, cleanup=True);
                return output
        
            self.diagram_file = _generate_code_diagram(
                self.file_structure, self.analysis_results, 'structure_diagram'
            );
        ::py::

        print('Diagram generated -> ', self.diagram_file);
    }
}


node LLMDocGenerator {
    has model_name: str = 'gemini/gemini-2.5-flash';
    has code_summary: str = '';

    can summarize with `root entry {
        ::py::
            import openai
            import os

            def _summarize_with_llm(code_summary, model_name):
                key = os.getenv("OPENAI_API_KEY", "")
                if not key:
                    return '⚠️ LLM summarization skipped (no API key)!'

                openai.api_key = key

                try: 
                    response = openai.ChatCompletion.create(
                        model = model_name,
                        messages = [
                            {'role':'system', 'content':'You are a documentation assistant'},
                            {'role':'user', 'content':f'Summarize this codebase in concise Markdown:\n\n{code_summary}'}
                        ],
                        temperature=0.5,
                    )
                    return response.choices[0].message["content"]
                
                except Exception as e:
                    return f' ⚠️ LLM Summarization failed: {e}'

            self.code_summary = _summarize_with_llm(self.code_summary, self.model_name) 
        ::py::

        print('Summary Generated:\n', self.code_summary);
        return self.code_summary;
    }
}


with entry {
    ::py::
        from dotenv import load_dotenv
        load_dotenv();
    ::py::

    #1 - Clone Repo;
    mapper = root ++> RepoMapper();
    mapper.git_url = "https://github.com/dnmuasya/BCS_OUK.git";
    mapper.dest_path = ".temp_repo";
    visit [-->( ` ? RepoMapper ) ];
    repo_path = mapper.last_repo_path;
    #2 - Scan
    scanner = root ++> FileStructureAnalyzer();
    scanner.repo_path = repo_path;
    visit [-->( ` ? FileStructureAnalyzer ) ];
    #file_structure is python dict, so conver in python
    ::py::
        file_structure = scanner.structure;
        file_items = list(file_structure.items())
    ::py::

    #3 - Analyze python/jac file
    analysis_results = [];
    ::py::
        import os
        results_tmp = []

        for item in file_structure.items(): 
            folder = item[0]
            files = item[1]
            for fn in files:
                if fn.endswith('.py') or fn.endswith('.jac') or fn.endswith('.j'):
                    #build absolute path
                    if folder == '':
                        file_path = os.path.join(repo_path, fn)
                    else:
                        file_path = os.path.join(repo_path, folder, fn)
                    
                    results_tmp.append((file_path, folder, fn))
    ::py::

    #loop through collected files
     for item in results_tmp {
        ::py::
            file_path, folder, fn=item
        ::py::

        analyzer = root ++> CodeAnalyzer();
        analyzer.file_path = file_path;
        visit [-->( ` ? CodeAnalyzer ) ];
        ::py::
            rel = os.path.relpath(file_path, repo_path)
            res = {
                'file': os.path.relpath(file_path, repo_path),
                'functions': analyzer.functions,
                'classes': analyzer.classes

            }
            analysis_results.append(res)
        ::py::

    }
    #4 - Diagram
    dg = root ++> DiagramGenerator();
    dg.file_structure = file_structure;
    dg.analysis_results = analysis_results;
    visit [-->( ` ? DiagramGenerator ) ];
    diagram_path = dg.diagram_file;
    #5 - generate docs
    writer = root ++> DocGenie();
    writer.file_structure = file_structure;
    writer.analysis_results = analysis_results;
    writer.diagram_path = diagram_path;
    visit [-->( ` ? DocGenie ) ];
    #6 - LLM summary
    llmnode = root ++> LLMDocGenerator();
    #create a code summary string from analysis_results
    ::py:: 
        code_summary = "\n".join([
            f"File: {r['file']}\\nFunctions: {r['functions']}\\nClasses: {r['classes']}\n" 
            for r in analysis_results]);
    ::py::

    llmnode.code_summary = code_summary;
    visit [-->( ` ? LLMDocGenerator ) ];
    print(
        'Pipeline finished. Docs at: ',
        writer.output_file,
        'Diagram: ',
        diagram_path,
        'LLM Summary length: ',
        len(llmnode.code_summary)
    );
}
