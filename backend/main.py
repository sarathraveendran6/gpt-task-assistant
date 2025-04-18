from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from fastapi.middleware.cors import CORSMiddleware

from backend.task_service import TaskService
from backend.gpt_helper import analyze_task  # optional if GPT used

app = FastAPI()

# Allow CORS for Flutter access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class TaskRequest(BaseModel):
    message: str
    project: Optional[str] = None
    tags: Optional[List[str]] = []

class EditTaskRequest(BaseModel):
    old_message: str
    new_message: Optional[str] = None
    project: Optional[str] = None
    tags: Optional[List[str]] = None

@app.get("/get_tasks")
def get_tasks():
    return {"tasks": TaskService.get_tasks()}

@app.post("/add_task")
def add_task(request: TaskRequest):
    result = TaskService.add_task(
        text=request.message,
        project=request.project,
        tags=request.tags
    )
    return result

@app.delete("/delete_task/{task_text}")
def delete_task(task_text: str):
    result = TaskService.delete_task(task_text)
    if result["status"] == "deleted":
        return result
    raise HTTPException(status_code=404, detail="Task not found")

@app.put("/edit_task")
def edit_task(request: EditTaskRequest):
    result = TaskService.edit_task(
        old_text=request.old_message,
        new_text=request.new_message,
        project=request.project,
        tags=request.tags
    )
    if result["status"] == "updated":
        return result
    raise HTTPException(status_code=404, detail="Task not found")
