class TaskManager:
    def __init__(self):
        self.tasks = []

    def add_task(self, text, project=None, tags=None):
        for task in self.tasks:
            if task["text"] == text:
                return {"status": "duplicate", "message": text}
        task = {
            "text": text,
            "done": False,
            "project": project,
            "tags": tags or [],
        }
        self.tasks.append(task)
        return {"status": "added", "message": text}

    def get_tasks(self):
        return self.tasks
