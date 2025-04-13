from backend.supabase_client import supabase
from typing import List, Optional

class TaskService:
    @staticmethod
    def add_task(text: str, project: Optional[str] = None, tags: Optional[List[str]] = None):
        # check if it already exists
        existing = supabase.table("tasks").select("id").eq("text", text).execute()
        if existing.data:
            return {"status": "duplicate", "message": text}

        supabase.table("tasks").insert({
            "text": text,
            "done": False,
            "project": project,
            "tags": tags or [],
        }).execute()
        return {"status": "added", "message": text}

    @staticmethod
    def get_tasks():
        res = supabase.table("tasks").select("*").order("created_at", desc=False).execute()
        return res.data

    @staticmethod
    def delete_task(text: str):
        res = supabase.table("tasks").delete().eq("text", text).execute()
        return {"status": "deleted" if res.count > 0 else "not found"}

    @staticmethod
    def edit_task(old_text: str, new_text: Optional[str] = None, project: Optional[str] = None, tags: Optional[List[str]] = None):
        # Check if the task exists
        existing = supabase.table("tasks").select("*").eq("text", old_text).execute()
        if not existing.data:
            return {"status": "not found", "message": old_text}

        # Update the task with new values
        update_data = {}
        if new_text:
            update_data["text"] = new_text
        if project is not None:
            update_data["project"] = project
        if tags is not None:
            update_data["tags"] = tags

        supabase.table("tasks").update(update_data).eq("text", old_text).execute()
        return {"status": "updated", "message": old_text}
