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



node LLMDocGenerator {
    has code_summary: str = "";
    has model_name: str = "gemini/gemini-2.5-flash";
    has llm_summary: str = "";

    can summarize with `root entry {
        ::py::
            import openai
            import os

            def summarize(text, model):
                key = os.getenv("OPENAI_API_KEY", "")
                if not key:
                    return "⚠️ No API key — skipping."

                openai.api_key = key

                resp = openai.ChatCompletion.create(
                    model=model,
                    messages=[
                        {"role": "system", "content": "You summarize codebases."},
                        {"role": "user", "content": text}
                    ],
                    temperature=0.4
                )

                return resp.choices[0].message["content"]

            self.llm_summary = summarize(visitor.code_summary, self.model_name);
        ::py::
            print("LLM summary complete.");
    }
}
