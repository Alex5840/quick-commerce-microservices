import os

SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
