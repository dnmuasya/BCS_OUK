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


node FileStructureAnalyzer {
    has repo_path: str;
    has structure: dict = {};

    can scan with `root entry {
        ::py::
            import os
            from pathlib import Path

            def _scan(p):
                out = {}
                base = Path(p)
                if not base.exists(): return out

                for root, dirs, files in os.walk(base):
                    rel = os.path.relpath(root, base)
                    if rel == ".": rel = ""
                    out[rel] = [f for f in files if not f.startswith(".")]
                return out

            self.structure = _scan(visitor.repo_path);
        ::py::
            print("Scanned", len(self.structure), "folders");
    }
}
