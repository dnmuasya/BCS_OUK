import streamlit as st;
from streamlit.components.v1 import html as components_html

# --- PAGE CONFIG ---
st.set_page_config(
    page_title='Agentic Repo DocGenerator',
    page_icon='🤖',
    layout="centered"
)

# --- CSS STYLING ---
st.markdown("""
    <style>
        /* Make the chat container wider and centered */
        .main > div {
            max-width: 1000px;
            padding-left: 50px;
            padding-right: 50px;
        }

        /* Full height layout */
        .block-container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            padding-top: 1rem;
            padding-bottom: 0;
        }

        /* Ensure tabs stay at top */
        .stTabs {
            position: sticky;
            top: 0;
            z-index: 100;
            background-color: white;
            padding-bottom: 1rem;
        }

        /* Chat wrapper with proper flex layout */
        .chat-wrapper {
            display: flex;
            flex-direction: column;
            height: calc(100vh - 200px);
            overflow: hidden;
        }

        /* Scrollable chat messages area */
        .chat-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 1rem 0;
            margin-bottom: 1rem;
            max-height: calc(100vh - 300px);
        }

        .chat-input {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            background-color: white;
            padding: 1rem 0;
            border-top: 1px solid #e0e0e0;
            z-index: 50;
        }

        /* Style adjustments for better spacing */
        .stChatInput {
            margin: 0 !important;
        }

        /* Custom scrollbar for chat area */
        .chat-scroll::-webkit-scrollbar {
            width: 8px;
        }

        .chat-scroll::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }

        .chat-scroll::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }

        .chat-scroll::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        /* Ensure message spacing */
        .stChatMessage {
            margin-bottom: 1rem;
        }
    </style>
""", unsafe_allow_html=True)

BASE_URL = 'https://localhost:8000'
CODEBASE_ENDPOINT = f'{BASE_URL}/walker/codebase_github'


# --- Title ---
st.title('🧠CodeBase Genius - AI Code Documentation Generator')
st.markdown('''
This system: 
    - Clones any Github Repo
    - Analyzes Python and Jac files
    - Builds a visual structure diagram
    - Generates Markdown documentation with optional AI summaries
            ''')

repo_url = st.text_input('🔗 Enter GitHub Repository URL', placeholder='https://github.com/username/repo.git')

if st.button('Generate Documentation'):
    if not repo_url.strip():
        st.error('Please enter a valid GitHub Reposiroty URL!')
    else:
        try:
            #step 1 - Clone
            repo_url = clone_repo(repo_url)

            #step 2 - Analyze structure
            structure = analyze_file_structure(repo_path)

            #step 3 - Analyze code relationships
            analysis_results = []
            st.info('🔍 Analyzing code relationships ...')
            for folder, files in structure.items():
                for f in files:
                    if f.endswith(('.py', '.ja')):
                        fpath = Path(repo_path) / folder / f
                        funcs, clss = analyze_code(fpath)
                        analysis_results.append({
                            'file': str(fpath.relative_to(repo_path)),
                            'functions': funcs,
                            'classes': clss,
                        })

                
            #step 4 - Generate Diagram
            diagram_path = generate_code_diagram(file_structure, analysis_results)
            st.image(str(diagram_path), caption='Code Structure Diagram')

            #Step 5 - Summarize with LLM
            summary_text = summarize_with_llm(str(analysis_results))

            #Step 6 - Generate Markdown
            doc_path = generate_markdown(file_structure, analysis_results, output_file)
            with open(doc_path, 'r', encoding='utf-8') as f:
                md_content = f.read()
                st.download_button(
                    '⬇️ Download documentation.md',
                    data=md_content,
                    file_name='documentation.md',
                    mime='text/markdown',
                )
                st.markdown('-----')
                st.markdown('### 📖 Preview')
                st.markdown(md_content)
        except Exception as e:
            st.error(f' ❌ Error: {e}')
