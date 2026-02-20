from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException, Body
import requests
import os
from typing import List, Optional
from fastapi import status
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
    print(f"[cart-order-service] add_to_cart called user_id={user_id} product_id={product_id} quantity={quantity}")

    # Try to resolve product details now and store them with the cart entry
    PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://product-service:8002")
    name = None
    price = None
    try:
        resp = requests.get(f"{PRODUCT_SERVICE_URL}/products/{product_id}", timeout=2)
        if resp.status_code == 200:
            prod = resp.json()
            name = prod.get("name")
            price = prod.get("price")
    except Exception as e:
        print(f"[cart-order-service] product lookup failed during add: {e}")

    existing = cart_collection.find_one({
        "user_id": user_id,
        "product_id": product_id
    })

    if existing:
        update_ops = {"$inc": {"quantity": quantity}}
        set_ops = {}
        if name is not None:
            set_ops["name"] = name
        if price is not None:
            set_ops["price"] = price
        if set_ops:
            update_ops["$set"] = set_ops

        cart_collection.update_one({"_id": existing["_id"]}, update_ops)
    else:
        doc = {
            "user_id": user_id,
            "product_id": product_id,
            "quantity": quantity,
        }
        if name is not None:
            doc["name"] = name
        if price is not None:
            doc["price"] = price

        cart_collection.insert_one(doc)

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
    # Return stored cart items (name/price saved at add-time).
    items = []
    for item in cart_collection.find({"user_id": user_id}):
        items.append({
            "id": str(item["_id"]),
            "product_id": item.get("product_id"),
            "quantity": item.get("quantity", 1),
            "name": item.get("name"),
            "price": item.get("price"),
        })

    return items


# ---------------- CREATE ORDER ----------------

@app.post("/order/create", status_code=status.HTTP_201_CREATED)
def create_order(user_id: str, items: Optional[List[dict]] = Body(default=None)):

    # If the client provides items in the request body, use them.
    # Otherwise, fall back to the server-side cart in MongoDB.
    if items:
        # normalize items: expect dicts with product_id and quantity
        cart_items = []
        for it in items:
            cart_items.append({
                "user_id": user_id,
                "product_id": it.get("product_id"),
                "quantity": it.get("quantity", 1)
            })
        # Do not delete server cart when client supplies items.
    else:
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

    # If we used the server-side cart, clear it now.
    if not items:
        cart_collection.delete_many({"user_id": user_id})

    # Notify delivery-service to create initial delivery status (PLACED).
    try:
        DELIVERY_SERVICE_URL = os.getenv("DELIVERY_SERVICE_URL", "http://delivery-service:8004")
        order_id = str(result.inserted_id)
        notify_url = f"{DELIVERY_SERVICE_URL}/order/{order_id}/update-status?status=PLACED"
        print(f"[cart-order-service] notifying delivery-service at {notify_url}")
        resp = requests.post(notify_url, timeout=5)
        print(f"[cart-order-service] delivery notify response: {resp.status_code} {resp.text}")
        if resp.status_code >= 200 and resp.status_code < 300:
            print(f"[cart-order-service] notified delivery-service for order {order_id}")
        else:
            print(f"[cart-order-service] delivery-service notify returned {resp.status_code}")
    except Exception as e:
        print(f"[cart-order-service] failed to notify delivery-service: {e}")

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
    
