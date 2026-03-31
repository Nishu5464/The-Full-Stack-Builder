from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum
from datetime import date
import asyncio
import os

app = FastAPI()

# ✅ CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

if not os.path.exists("tasks.db"):
    open("tasks.db", "w").close()
# ✅ Database setup
DATABASE_URL = "sqlite:///./tasks.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# ✅ ENUM for status
class StatusEnum(str, Enum):
    todo = "To-Do"
    in_progress = "In Progress"
    done = "Done"

# ✅ Task table
class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, default="")
    due_date = Column(String, nullable=True)
    status = Column(String, default="To-Do")
    blocked_by = Column(Integer, ForeignKey("tasks.id"), nullable=True)

Base.metadata.create_all(bind=engine)

# ✅ Schemas
class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = ""
    due_date: Optional[date] = None
    status: Optional[StatusEnum] = StatusEnum.todo
    blocked_by: Optional[int] = None

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[StatusEnum] = None
    blocked_by: Optional[int] = None

# 🔥 FIXED MODEL (IMPORTANT)
class TaskOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    due_date: Optional[str]
    status: str
    blocked_by: Optional[int]

    class Config:
        orm_mode = True   # ✅ FIXED HERE

# ✅ DB dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ✅ Helper: Check blocked state
def is_blocked(task, db):
    if not task.blocked_by:
        return False
    blocker = db.query(Task).filter(Task.id == task.blocked_by).first()
    return blocker and blocker.status != "Done"

# ✅ GET all tasks
@app.get("/tasks", response_model=List[TaskOut])
def get_tasks(
    search: Optional[str] = None,
    status: Optional[str] = None,
    db=Depends(get_db)
):
    query = db.query(Task)

    if search:
        query = query.filter(Task.title.ilike(f"%{search}%"))

    if status and status != "All":
        query = query.filter(Task.status == status)

    query = query.order_by(Task.due_date.asc())

    return query.all()

# ✅ GET single task
@app.get("/tasks/{task_id}", response_model=TaskOut)
def get_task(task_id: int, db=Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    return task

# ✅ CREATE task
@app.post("/tasks", response_model=TaskOut)
async def create_task(task: TaskCreate, db=Depends(get_db)):
    await asyncio.sleep(1)  # optional delay

    if task.blocked_by is not None:
        blocker = db.query(Task).filter(Task.id == task.blocked_by).first()
        if not blocker:
            raise HTTPException(status_code=400, detail="Blocked task not found")

    new_task = Task(
        title=task.title,
        description=task.description,
        due_date=str(task.due_date) if task.due_date else None,
        status=task.status.value if task.status else "To-Do",
        blocked_by=task.blocked_by,
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task

# ✅ UPDATE task
@app.put("/tasks/{task_id}", response_model=TaskOut)
async def update_task(task_id: int, task_update: TaskUpdate, db=Depends(get_db)):
    await asyncio.sleep(1)

    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    if task_update.blocked_by is not None:
        if task_update.blocked_by == task_id:
            raise HTTPException(status_code=400, detail="Task cannot block itself")

        blocker = db.query(Task).filter(Task.id == task_update.blocked_by).first()
        if not blocker:
            raise HTTPException(status_code=400, detail="Blocked task not found")

    if task_update.title is not None:
        task.title = task_update.title

    if task_update.description is not None:
        task.description = task_update.description

    if task_update.due_date is not None:
        task.due_date = str(task_update.due_date)

    if task_update.status is not None:
        task.status = task_update.status.value

    if task_update.blocked_by is not None:
        task.blocked_by = task_update.blocked_by

    db.commit()
    db.refresh(task)

    return task

# ✅ DELETE task
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db=Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    dependent = db.query(Task).filter(Task.blocked_by == task_id).first()
    if dependent:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete task. Other tasks depend on it."
        )

    db.delete(task)
    db.commit()

    return {"message": "Deleted successfully"}