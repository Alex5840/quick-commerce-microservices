from pymongo import MongoClient
import os

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")

client = MongoClient(MONGO_URL)
db = client["cart_order_db"]

cart_collection = db["cart"]
orders_collection = db["orders"]
