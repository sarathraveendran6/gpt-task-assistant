import openai

def analyze_task(message, current_tasks):
    # Simulate GPT analysis (replace with real OpenAI call)
    for task in current_tasks:
        if task["text"].lower() == message.lower():
            return {"is_duplicate": True, "reason": "Task already exists"}
    return {"is_duplicate": False}
