import os;
import git;
import ast;
import shutil;

node RepoCloning {
    has last_repo_path: str = "";

    can clone using root {
        py:
            def clone_repo(git_url, dest):
                from pathlib import Path
                if dest.exists():
                    shutil.rmtree(dest)
                dest.mkdir(parents=True, exist_ok=True)
                try:
                    print(f"Cloning {git_url} into {dest}")
                    git.Repo.clone_from(git_url, str(dest))
                    return str(dest)
                except Exception as e:
                    raise RuntimeError(f"Failed to clone repo: {e}")
        ->
            self.last_repo_path = clone_repo(visitor.git_url, visitor.dest_path);
    }
}

node AnalyzeFileStructure {
    has structure: dict = {};

    can scan using root {
        py:
            import os

            def scan(path):
                fs = {}
                for root, dirs, files in os.walk(path):
                    fs[root] = files
                return fs
        ->
            self.structure = scan(visitor.repo_path);
    }
}

node AnalyzeCodeRelation {
    has functions: list = [];
    has classes: list = [];
    has file_path: str = "";

    can analyze using root {
        py:
            

            def analyze_code(file_path):
                with open(file_path, 'r') as f:
                    tree = ast.parse(f.read(), filename=file_path)

                funcs = []
                clss = []

                for node in tree.body:
                    if isinstance(node, ast.FunctionDef):
                        funcs.append(node.name)
                    elif isinstance(node, ast.ClassDef):
                        clss.append(node.name)

                return funcs, clss
        ->
            self.functions, self.classes = analyze_code(self.file_path);
    }
}

node GenerateDocumentation {
    can write using root {
        py:
            def write_markdown(file_structure, analysis_results, out_file):
                with open(out_file, "w") as md:
                    md.write(" Project Documentation\n\n")

                    md.write(" File Structure\n")
                    for folder, files in file_structure.items():
                        md.write(f" {folder}\n")
                        for f in files:
                            md.write(f"- {f}\n")

                    md.write("\n Code Relationships\n")
                    for row in analysis_results:
                        md.write(f"- {row}\n")

                print(f"Documentation generated at {out_file}")
        ->
            write_markdown(visitor.file_structure, visitor.analysis_results, "documentation.md");
    }
}

walker GenerateDocs {
    has git_url: str;
    has dest_path: str;
    has repo_path: str = "";
    has file_structure: dict = {};
    has analysis_results: list = [];

    can entry {
        # 1. Clone
        repo = spawn here ++> RepoCloning();
        visit repo with clone;

        self.repo_path = repo.last_repo_path;

        # 2. Structure scan
        filescan = spawn here ++> AnalyzeFileStructure();
        filescan.repo_path = self.repo_path;
        visit filescan with scan;

        self.file_structure = filescan.structure;

        # 3. Analyze python files
        for folder, files in self.file_structure.items():
            for f in files:
                if f.endswith(".py"):
                    analyzer = spawn here ++> AnalyzeCodeRelation();
                    analyzer.file_path = folder + "/" + f;
                    visit analyzer with analyze;

                    self.analysis_results.append(
                        f"File: {f} | Functions: {analyzer.functions} | Classes: {analyzer.classes}"
                    );

        # 4. Generate MD
        writer = spawn here ++> GenerateDocumentation();
        visit writer with write;
    }
}

with entry {
    walker GenerateDocs {
        git_url = "https://github.com/username/repository.git";
        dest_path =  "repository";
    }
}
