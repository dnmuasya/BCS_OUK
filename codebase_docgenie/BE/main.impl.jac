import from dotenv {load_dotenv}
import sys;

node Memory {}

walker RepoDocGEn {
    has git_url: str;
    has dest_path: path;
    has repo_path: str;
    has file_structure: dict = {};
    has analysis_results: list = [];
    has diagram_path: str = '';
    has output_doc: str = '';
}

walker RunRepoMapper {
    has git_url: str;
    has dest_path: str;
    can entry {
        repo_mapper = spawn here ++> RepoMapper(git_url=self.git_url, dest_path=self.dest_path);
        visit repo_mapper with clone;
    }
}

with entry {
    walker RunRepoMapper('https://github.com/username/repository.git', 'local_repo_folder');
}
# ---Main Entry ---
can entry {
    report 'Starting Agentic Documentation Generator';

    #1. Clone the Repo
    repo_node = spawn here ++> RepoMapper();
    repo_node.git_url = self.git_url;
    repo_node.dest_path = self.det_path;
    visit repo_node with clone;
    self.repo_path = repo_node.last_repo_path;

    report f' ✅ Repository cloned to  {self.repo_path}';

    #2. Analyze File Structure
    fs_node = spawn here ++> FileStructureAnalyzer();
    fs_node.repo_path = self.repo_path;
    visit fs_node with scan;
    self.file_structure = fs_node.structure;
    report '✅ File structure analysis complete.';

    #3. Analyze Code Relations
    for (folder, files) in self.file_structure.items() {
        for fin fies {
            if f.endswith('.py') or f.endswith('.jac') {
                analyzer = spawn here ++> CodeAnalyzer();
                analyzer.file_path = os.path.join(self.repo_path, folder, f);
                visit analyzer with analyze;
                self.analysis_results.append({
                    'file': analyzer.file_path,
                    'functions': analyzer.functions,
                    'classes': analyzer.classes
                });
            }
        }
    }
    report '✅ Code relationships exracted.';

    #4. Generate Diagram
    diagram_gen = spawn here ++> DiagramGenerator();
    diagram_gen.file_structure = self.file_structure;
    diagram_gen.analysis_results = self.analysis_results;
    visit diagram_gen with build;
    self.diagram_path = diagram_gen.diagram_file;

    report '✅ Diagram generated at {self.diagram_path}';


    #5. Generate Markdown Documentation
    doc_writer = spawn here ++> DocGenie();
    doc_write.file_structure = self.file_structure;
    doc_writer.analysis_results = self.analysis_results;
    doc_writer.diagram_path = self.diagram_path;
    vosit doc_write with write;
    self.output_doc = doc_writer.output_file;

    report f'✅ Documentation generated at {self.output_doc}'; 
}

#
# ENTRY EXECUTION #
with entry {
    walker RepoDocGen(
        git_url='https://github.com/username/repo.git',
        dest_path = 'repo_local'
    );
}
