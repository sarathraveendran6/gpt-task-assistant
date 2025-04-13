from supabase import create_client, Client

SUPABASE_URL = "https://emidjpwyfgydkedwwqhj.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtaWRqcHd5Zmd5ZGtlZHd3cWhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1MzA1ODIsImV4cCI6MjA2MDEwNjU4Mn0.pk6i8iJFTfOzOfxMbn1UnPNqyhwgF0pN0ydCrEb47PQ"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

if __name__ == "__main__":
    res = supabase.table("tasks").insert({
        "text": "Test cloud task",
        "done": False,
        "project": "Personal",
        "tags": ["setup", "test"]
    }).execute()
    print(res)

