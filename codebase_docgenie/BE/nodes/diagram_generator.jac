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


node DiagramGenerator {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_file: str = "structure_diagram.svg";

    can build with `root entry {
        ::py::
            import graphviz

            def make_diagram(structure, results, out):
                dot = graphviz.Digraph("CodeStructure", format="svg")

                for folder, files in structure.items():
                    folder_id = folder or "root"
                    dot.node(folder_id)

                    for f in files:
                        fid = f"{folder_id}/{f}"
                        dot.node(fid)
                        dot.edge(folder_id, fid)

                for r in results:
                    file = r.get("file")
                    if not file: continue

                    for fn in r["functions"]:
                        id = f"{file}/{fn}"
                        dot.node(id, shape="box")
                        dot.edge(file, id)

                    for cls in r["classes"]:
                        id = f"{file}/{cls}"
                        dot.node(id, shape="ellipse")
                        dot.edge(file, id)

                return dot.render(out, cleanup=True)

            self.diagram_file = make_diagram(
                visitor.file_structure, visitor.analysis_results, "structure_diagram"
            );
        ::py::
            print("Diagram →", self.diagram_file);
    }
}
