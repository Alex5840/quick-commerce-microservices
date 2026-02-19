from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from bson import ObjectId
from datetime import datetime
from app.database import cart_collection, orders_collection

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- ADD TO CART ----------------

@app.post("/cart/add")
def add_to_cart(user_id: str, product_id: str, quantity: int):

    existing = cart_collection.find_one({
        "user_id": user_id,
        "product_id": product_id
    })

    if existing:
        cart_collection.update_one(
            {"_id": existing["_id"]},
            {"$inc": {"quantity": quantity}}
        )
    else:
        cart_collection.insert_one({
            "user_id": user_id,
            "product_id": product_id,
            "quantity": quantity
        })

    return {"message": "Item added to cart"}


# ---------------- REMOVE FROM CART ----------------

@app.post("/cart/remove")
def remove_from_cart(user_id: str, product_id: str):

    cart_collection.delete_one({
        "user_id": user_id,
        "product_id": product_id
    })

    return {"message": "Item removed from cart"}


# ---------------- VIEW CART ----------------

@app.get("/cart")
def view_cart(user_id: str):

    items = []
    for item in cart_collection.find({"user_id": user_id}):
        items.append({
            "id": str(item["_id"]),
            "product_id": item["product_id"],
            "quantity": item["quantity"]
        })

    return items


# ---------------- CREATE ORDER ----------------

@app.post("/order/create")
def create_order(user_id: str):

    cart_items = list(cart_collection.find({"user_id": user_id}))

    if not cart_items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    total_items = sum(item["quantity"] for item in cart_items)

    order = {
        "user_id": user_id,
        "items": cart_items,
        "total_items": total_items,
        "created_at": datetime.utcnow()
    }

    result = orders_collection.insert_one(order)

    cart_collection.delete_many({"user_id": user_id})

    return {
        "message": "Order created",
        "order_id": str(result.inserted_id)
    }


# ---------------- GET ORDERS ----------------

@app.get("/orders")
def get_orders(user_id: str):

    orders = []
    for order in orders_collection.find({"user_id": user_id}):
        orders.append({
            "order_id": str(order["_id"]),
            "total_items": order["total_items"],
            "created_at": order["created_at"]
        })

    return orders
