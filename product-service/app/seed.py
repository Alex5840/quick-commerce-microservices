from app.database import products_collection

products = [
    {
        "name": "Milk",
        "description": "1L Dairy Milk",
        "price": 50,
        "category": "Dairy",
        "image_url": "https://via.placeholder.com/150",
        "available": True
    },
    {
        "name": "Bread",
        "description": "Whole Wheat Bread",
        "price": 30,
        "category": "Bakery",
        "image_url": "https://via.placeholder.com/150",
        "available": True
    },
    {
        "name": "Apple",
        "description": "Fresh Red Apples",
        "price": 120,
        "category": "Fruits",
        "image_url": "https://via.placeholder.com/150",
        "available": True
    }
]

products_collection.insert_many(products)

print("Products seeded successfully!")
