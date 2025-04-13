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
