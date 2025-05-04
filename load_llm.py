from llama_cpp import Llama

MODEL_PATH = "Phi-3.5-mini-instruct-Q4_K_M.gguf"
llm = Llama(model_path=MODEL_PATH, n_threads=4, n_gpu_layers=0)

prompt = (
    "### Instruction:\n"
    "Write an SQL SELECT query that counts the number of rows in the table `users`.\n"
    "### Response:\n"
)

resp = llm(prompt, max_tokens=64, stop=["\n"])

# change this:
# print(resp.choices[0].text.strip())

# to this:
print(resp['choices'][0]['text'].strip())
