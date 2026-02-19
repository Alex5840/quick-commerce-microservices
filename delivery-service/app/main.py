from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from datetime import datetime
from app.database import delivery_collection

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

VALID_STATUSES = [
    "PLACED",
    "PACKED",
    "OUT_FOR_DELIVERY",
    "DELIVERED"
]

# ---------------- UPDATE STATUS ----------------

@app.post("/order/{order_id}/update-status")
def update_status(order_id: str, status: str):

    if status not in VALID_STATUSES:
        raise HTTPException(status_code=400, detail="Invalid status")

    existing = delivery_collection.find_one({"order_id": order_id})

    if existing:
        delivery_collection.update_one(
            {"order_id": order_id},
            {
                "$set": {
                    "status": status,
                    "last_updated": datetime.utcnow()
                }
            }
        )
    else:
        delivery_collection.insert_one({
            "order_id": order_id,
            "status": status,
            "last_updated": datetime.utcnow()
        })

    return {"message": "Status updated"}


# ---------------- GET STATUS ----------------

@app.get("/order/{order_id}/status")
def get_status(order_id: str):

    order = delivery_collection.find_one({"order_id": order_id})

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    return {
        "order_id": order_id,
        "status": order["status"],
        "last_updated": order["last_updated"]
    }
