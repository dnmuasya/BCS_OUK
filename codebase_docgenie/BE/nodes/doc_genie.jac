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

node DocGenie {
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_path: str = "";
    has output_file: str = "documentation.md";

    can write with `root entry {
        ::py::
            def write_doc(fs, results, diagram, out):
                with open(out, "w", encoding="utf-8") as md:
                    md.write("# Project Documentation\n\n")
                    md.write("## File Structure\n\n")

                    for d, files in fs.items():
                        md.write(f"### {d or '/'}\n")
                        for f in files:
                            md.write(f" - {f}\n")
                        md.write("\n")

                    md.write("\n## Code Relationships\n")
                    for r in results:
                        md.write(f"\n### {r['file']}\n")
                        md.write(f"- Classes: {', '.join(r['classes'])}\n")
                        md.write(f"- Functions: {', '.join(r['functions'])}\n")

                    if diagram:
                        md.write("\n## Diagram\n")
                        md.write(f"![diagram]({diagram})\n")

                return out

            self.output_file = write_doc(
                visitor.file_structure,
                visitor.analysis_results,
                visitor.diagram_path,
                self.output_file
            );
        ::py::
            print("Docs →", self.output_file);
    }
}
