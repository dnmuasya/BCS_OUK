## """Codebase Genius - main jac file
# This file contains the core data structures for the codebase genius multi-agent Jac application.
# Codebase Genius tales a public GitHub repo URL, produces high quality markdown documentation of that 
# codebase with clear prose and explanatory diagrams.
# """
import from byllm.llm{Model}
import from dotenv {load_dotenv}
import graphviz;
import git;
import shutil;
import os;
#include main.impl.jac ;

#Load environment variables from .env file;
glob env_loaded = load_dotenv();
glob llm = Model(model_name = 'gemini/gemini-2.5-flash', verbose=True);


node CodeAnalyzer {
    has file_path: str;
    has functions: list = [];
    has classes: list = [];

    can analyze with `root entry {
        ::py::
            import ast
            from pathlib import Path

            def parse_code(path):
                p = Path(path)
                if not p.exists():
                    return [], []

                funcs, classes = [], []

                if p.suffix == ".py":
                    try:
                        src = p.read_text(encoding="utf-8")
                        tree = ast.parse(src)
                        for node in tree.body:
                            if isinstance(node, ast.FunctionDef):
                                funcs.append(node.name)
                            elif isinstance(node, ast.ClassDef):
                                classes.append(node.name)
                    except Exception as e:
                        print("Python AST error:", e)

                elif p.suffix in (".jac", ".j"):
                    for line in p.read_text(encoding="utf-8").splitlines():
                        s = line.strip()
                        if s.startswith("def "):
                            funcs.append(s.split()[1].split("(")[0])
                        if s.startswith("node "):
                            classes.append(s.split()[1].split("(")[0])

                return funcs, classes

            self.functions, self.classes = parse_code(visitor.file_path);
        ::py::
            print("Analyzed:", visitor.file_path);
    }
}
