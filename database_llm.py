import re
import sys
import paramiko
import getpass
from llama_cpp import Llama
from contextlib import contextmanager
from pathlib import Path

@contextmanager
def suppress_stdout_stderr():
    import os
    with open(os.devnull, 'w') as devnull:
        old_stdout = sys.stdout
        old_stderr = sys.stderr
        try:
            sys.stdout = devnull
            sys.stderr = devnull
            yield
        finally:
            sys.stdout = old_stdout
            sys.stderr = old_stderr

def extract_sql(llm_output_text):
    lines = llm_output_text.strip().split("+-+-+")
    try:
        sql = lines[1].strip()
    except IndexError:
        sql = None
    return sql

def build_prompt(schema_text, user_question):
    return f"""
You are a SQL query generator.

Given a database schema and a natural language question, generate a valid, executable SQL query that answers the question.

Schema:
{schema_text}

Rules:
- Only use the tables and columns in the schema.
- Always include a FROM clause.
- If information is missing, respond exactly with: ERROR: Insufficient schema information.
- Output only the SQL query, and nothing else.
- Surround the query with the text: +-+-+

Question: {user_question}
"""

class RemoteSession:
    def __init__(self, hostname, username, password, port=22):
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.client.connect(hostname, port=port, username=username, password=password)
        print(f"Connected to {hostname}.")

    def run_command(self, command):
        stdin, stdout, stderr = self.client.exec_command(command)
        output = stdout.read().decode()
        exit_status = stdout.channel.recv_exit_status()
        return output, exit_status

    def close(self):
        self.client.close()
        print("Connection closed.")

def main():
    model_path = str(Path("Phi-3.5-mini-instruct-Q4_K_M.gguf").resolve())
    with suppress_stdout_stderr():
        llm = Llama(model_path=model_path, n_ctx=3072, n_threads=4)

    schema_file = sys.argv[1] if len(sys.argv) > 1 else "Subset.sql"
    with open(schema_file, "r") as f:
        schema_text = f.read()

    hostname = "ilab.cs.rutgers.edu"
    username = input("Enter your NetID: ")
    password = getpass.getpass("Enter your iLab password: ")
    session = RemoteSession(hostname, username, password)

    while True:
        user_question = input("\nAsk a question (or type 'exit' to quit): ")
        if user_question.lower().strip() == "exit":
            break

        prompt = build_prompt(schema_text, user_question)
        print("Awaiting response...")

        exit_status = 1
        retries = 3
        while exit_status != 0 and retries > 0:
            with suppress_stdout_stderr():
                result = llm(prompt, max_tokens=200)
            sql = extract_sql(result["choices"][0]["text"])
            if not sql:
                retries -= 1
                continue
            safe_sql = sql.replace('"', '\\"')
            command = f'python3 ~/CS336/ilab_script.py "{safe_sql}"'
            output, exit_status = session.run_command(command)
            retries -= 1

        if retries == 0:
            print("❌ No valid SQL query generated after 3 attempts.")
        else:
            print("\n✅ Generated SQL Query:\n")
            print(sql)
            print("\n📄 Output:")
            print(output)

    session.close()

if __name__ == "__main__":
    main()