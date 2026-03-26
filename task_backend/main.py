from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker
from pydantic import BaseModel

app = FastAPI()

# ✅ CORS — allows Flutter app to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Database setup
DATABASE_URL = "sqlite:///./tasks.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# ✅ Task table model
class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    status = Column(String, default="pending")

Base.metadata.create_all(bind=engine)

# ✅ Pydantic schemas for request bodies
class TaskCreate(BaseModel):
    title: str

class TaskUpdate(BaseModel):
    status: str

# ✅ DB session dependency — properly closes session after each request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ✅ GET /tasks — fetch all tasks
@app.get("/tasks")
def get_tasks(db=Depends(get_db)):
    return db.query(Task).all()

# ✅ POST /tasks — create a new task (JSON body)
@app.post("/tasks")
def create_task(task: TaskCreate, db=Depends(get_db)):
    new_task = Task(title=task.title)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

# ✅ PUT /tasks/{id} — update task status
@app.put("/tasks/{task_id}")
def update_task(task_id: int, task_update: TaskUpdate, db=Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if task:
        task.status = task_update.status
        db.commit()
        db.refresh(task)
        return task
    return {"message": "Task Not Found"}

# ✅ DELETE /tasks/{id} — delete a task
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db=Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if task:
        db.delete(task)
        db.commit()
        return {"message": "Deleted"}
    return {"message": "Task Not Found"}
