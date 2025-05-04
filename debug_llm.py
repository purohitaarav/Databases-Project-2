# from llama_cpp import Llama

# llm = Llama(model_path="Phi-3.5-mini-instruct-Q4_K_M.gguf", n_threads=4)

# def ask_one_query(instruction: str) -> str:
#     prompt = (
#         f"### Instruction:\n"
#         f"{instruction}\n"
#         f"### Response:\n"
#         "- Give me exactly one SQL query, no explanation.\n"
#     )
#     resp = llm(prompt, max_tokens=128, stop=[";"])
#     raw = resp["choices"][0]["text"]
#     return raw.split(";", 1)[0].strip() + ";"

# print(ask_one_query(
#     "Write an SQL SELECT query that counts the number of rows in the table `users`."
# ))
#!/usr/bin/env python3
#!/usr/bin/env python3
#!/usr/bin/env python3
#!/usr/bin/env python3
import re
import psycopg2
from llama_cpp import Llama

# ——————————————————————————
# 1) Read & summarize your schema (one-liner)
# ——————————————————————————
raw = open("Subset.sql", "r").read()
m = re.search(
    r"CREATE\s+TABLE\s+(\w+)\s*\((.*?)\);",
    raw,
    flags=re.IGNORECASE | re.DOTALL
)
if m:
    table_name = m.group(1)
    cols = [c.strip() for c in m.group(2).split(",")]
    schema_summary = f"Table {table_name}({', '.join(cols)})"
else:
    schema_summary = raw  # fallback, but likely too big

# ——————————————————————————
# 2) Initialize your local LLM
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
    return extract_sql(resp["choices"][0]["text"])

# ——————————————————————————
# 3) Database connection & execution
# ——————————————————————————
DB_PARAMS = {
    "host":     "postgres.cs.rutgers.edu",
    "database": "group30",
    "user":     "lh715",
    "password": "1Njusalisa."
}

def run_query(sql: str):
    with psycopg2.connect(**DB_PARAMS) as conn:
        with conn.cursor() as cur:
            cur.execute(sql)
            # assume a single-value result like COUNT(*)
            return cur.fetchone()[0]

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

        try:
            result = run_query(sql)
            print("⮕ Result:", result, "\n")
        except Exception as e:
            print("⮕ ERROR executing SQL:", e, "\n")

if __name__ == "__main__":
    main()
