from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from bson import ObjectId
from app.database import products_collection

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Get all products
@app.get("/products")
def get_products():
    products = []
    for product in products_collection.find():
        products.append({
            "id": str(product["_id"]),
            "name": product["name"],
            "description": product["description"],
            "price": product["price"],
            "category": product["category"],
            "image_url": product["image_url"],
            "available": product["available"]
        })
    return products


# Get single product
@app.get("/products/{product_id}")
def get_product(product_id: str):
    product = products_collection.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return {
        "id": str(product["_id"]),
        "name": product["name"],
        "description": product["description"],
        "price": product["price"],
        "category": product["category"],
        "image_url": product["image_url"],
        "available": product["available"]
    }


# Get categories
@app.get("/categories")
def get_categories():
    categories = products_collection.distinct("category")
    return categories
