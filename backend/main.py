from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime
from typing import List
import os
from pydantic import BaseModel

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@database:5432/appdb")

# SQLAlchemy setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database model
class DataItem(Base):
    __tablename__ = "data_items"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

# Pydantic models
class DataItemResponse(BaseModel):
    id: int
    name: str
    description: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class DataItemCreate(BaseModel):
    name: str
    description: str

# Create tables
Base.metadata.create_all(bind=engine)

# FastAPI app
app = FastAPI(
    title="FastAPI Backend",
    description="Backend service for Angular-FastAPI-PostgreSQL demo",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Initialize database with sample data
def init_db():
    db = SessionLocal()
    try:
        # Check if data already exists
        existing_count = db.query(DataItem).count()
        if existing_count == 0:
            # Add sample data
            sample_data = [
                DataItem(name="Sample Item 1", description="This is the first sample item from the database"),
                DataItem(name="Sample Item 2", description="This is the second sample item from the database"),
                DataItem(name="Docker Demo", description="This item demonstrates the Docker Compose setup"),
                DataItem(name="Angular Integration", description="This shows Angular frontend connecting to FastAPI backend"),
                DataItem(name="PostgreSQL Data", description="This data is stored in PostgreSQL database")
            ]
            
            for item in sample_data:
                db.add(item)
            db.commit()
            print("Sample data initialized")
        else:
            print(f"Database already contains {existing_count} items")
    except Exception as e:
        print(f"Error initializing database: {e}")
        db.rollback()
    finally:
        db.close()

# API Routes
@app.get("/")
async def root():
    return {"message": "FastAPI Backend is running", "status": "healthy"}

@app.get("/health")
async def health_check():
    try:
        # Test database connection
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": "disconnected", "error": str(e)}

@app.get("/api/data", response_model=List[DataItemResponse])
async def get_data(db: Session = Depends(get_db)):
    """Get all data items from the database"""
    try:
        items = db.query(DataItem).all()
        return items
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.post("/api/data", response_model=DataItemResponse)
async def create_data(item: DataItemCreate, db: Session = Depends(get_db)):
    """Create a new data item"""
    try:
        db_item = DataItem(name=item.name, description=item.description)
        db.add(db_item)
        db.commit()
        db.refresh(db_item)
        return db_item
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/api/data/{item_id}", response_model=DataItemResponse)
async def get_data_item(item_id: int, db: Session = Depends(get_db)):
    """Get a specific data item by ID"""
    try:
        item = db.query(DataItem).filter(DataItem.id == item_id).first()
        if item is None:
            raise HTTPException(status_code=404, detail="Item not found")
        return item
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

# Startup event
@app.on_event("startup")
async def startup_event():
    print("Starting FastAPI application...")
    init_db()
    print("FastAPI application started successfully")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("BACKEND_PORT", 8001)))

