import re
import paramiko
from llama_cpp import Llama

# ——————————————————————————
# 1) Read & summarize schema
# ——————————————————————————
raw = open("Subset.sql", "r").read()
m = re.search(r"CREATE\s+TABLE\s+(\w+)\s*\((.*?)\);", raw, flags=re.IGNORECASE | re.DOTALL)
if m:
    table_name = m.group(1)
    cols = [c.strip() for c in m.group(2).split(",")]
    schema_summary = f"Table {table_name}({', '.join(cols)})"
else:
    schema_summary = raw  # fallback

# ——————————————————————————
# 2) Initialize local LLM
# ——————————————————————————
llm = Llama(model_path="Phi-3.5-mini-instruct-Q4_K_M.gguf", n_threads=4)

def make_prompt(question: str) -> str:
    return (
        f"Schema: {schema_summary}\n"
        f"Question: {question}\n"
        "### Response: One valid SQL SELECT query (no extras).\n"
    )

def extract_sql(text: str) -> str:
    return text.strip().split(";", 1)[0].strip() + ";"

def ask_one_query(question: str) -> str:
    prompt = make_prompt(question)
    resp = llm(prompt, max_tokens=128, stop=[";"])
    raw_sql = resp["choices"][0]["text"]

    # Clean up: remove markdown code fences if present
    raw_sql = raw_sql.replace("```sql", "").replace("```", "").strip()

    return extract_sql(raw_sql)


# ——————————————————————————
# 3) Run psql remotely via SSH
# ——————————————————————————
SSH_HOST = "kill.cs.rutgers.edu"
SSH_USER = "lh715"
SSH_PASS = "1Njusalisa."
DB_NAME = "group30"

def run_query_remote(sql: str) -> str:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(SSH_HOST, username=SSH_USER, password=SSH_PASS)

    sql = sql.replace('"', '\\"')  # escape quotes
    psql_cmd = f'psql -h postgres.cs.rutgers.edu -d {DB_NAME} -U {SSH_USER} -c "{sql}"'


    stdin, stdout, stderr = ssh.exec_command(psql_cmd)
    output = stdout.read().decode()
    error = stderr.read().decode()
    ssh.close()

    if error.strip():
        return f"⮕ ERROR: {error.strip()}"
    return output.strip()

# ——————————————————————————
# 4) REPL loop
# ——————————————————————————
def main():
    print("Ask about your schema (or 'exit' to quit):")
    while True:
        q = input(">>> ").strip()
        if q.lower() in ("exit", "quit"):
            print("Goodbye!")
            break

        sql = ask_one_query(q)
        print("\n⮕ Generated SQL:\n", sql)

        result = run_query_remote(sql)
        print("⮕ Result:\n", result, "\n")

if __name__ == "__main__":
    main()
