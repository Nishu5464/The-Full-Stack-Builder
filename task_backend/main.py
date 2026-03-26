from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker

app = FastAPI()

# ✅ CORS FIX (VERY IMPORTANT)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE_URL = "sqlite:///./tasks.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)

Base = declarative_base()

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    status = Column(String, default="pending")

Base.metadata.create_all(bind=engine)

@app.get("/tasks")
def get_tasks():
    db = SessionLocal()
    tasks = db.query(Task).all()
    return tasks

@app.post("/tasks")
def create_task(title: str):
    db = SessionLocal()
    task = Task(title=title)
    db.add(task)
    db.commit()
    return {"message": "Task Created"}

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    db = SessionLocal()
    task = db.query(Task).filter(Task.id == task_id).first()
    if task:
        db.delete(task)
        db.commit()
        return {"message": "Deleted"}
    return {"message": "Task Not Found"}