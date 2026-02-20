# 🛒 Quick Commerce Microservices Application

## 📌 Project Overview

This project is a Quick Commerce Application built using a Microservices Architecture.  
The system allows users to browse products, add items to cart, place orders, and track delivery status.

The application is fully containerized using Docker and built with:

- **Backend:** Python + FastAPI
- **Frontend:** Flutter (Web)
- **Database:** MongoDB
- **Architecture:** Microservices
- **Containerization:** Docker & Docker Compose

---

# 🏗 System Architecture

The system consists of **exactly 4 independent microservices**:

## 1️⃣ User Service (Port: 8001)
Responsible for:
- User Registration
- User Login
- JWT Authentication
- User Profile Retrieval

### APIs:
- `POST /register`
- `POST /login`
- `GET /profile`

### Features:
- Password hashing using bcrypt
- JWT token generation
- Secure authentication using Bearer Token

---

## 2️⃣ Product Catalog Service (Port: 8002)
Responsible for:
- Listing all products
- Fetching product by ID
- Category listing

### APIs:
- `GET /products`
- `GET /products/{product_id}`
- `GET /categories`

### Product Fields:
- product_id
- name
- description
- price
- category
- image_url
- availability

---

## 3️⃣ Cart + Order Service (Port: 8003)
Responsible for:
- Adding items to cart
- Removing items from cart
- Viewing cart
- Creating orders
- Viewing user orders

### APIs:
- `POST /cart/add`
- `POST /cart/remove`
- `GET /cart`
- `POST /order/create`
- `GET /orders`

### Order Fields:
- order_id
- user_id
- products
- quantity
- total_amount
- timestamp

---

## 4️⃣ Delivery + Order Status Service (Port: 8004)
Responsible for:
- Tracking order delivery status
- Updating order status

### APIs:
- `GET /order/{order_id}/status`
- `POST /order/{order_id}/update-status`

### Order Lifecycle:
- PLACED
- PACKED
- OUT_FOR_DELIVERY
- DELIVERED

---

# 🗄 Database

- MongoDB is used as the database.
- Each microservice uses its own collection.
- MongoDB runs as a Docker container.

---

# 🐳 Running the Backend (Docker)

Make sure Docker is installed.

From the project root:

```bash
docker-compose up --build
```

Services will run on:

- User Service → http://localhost:8001
- Product Service → http://localhost:8002
- Cart Service → http://localhost:8003
- Delivery Service → http://localhost:8004
- MongoDB → Port 27017

Swagger documentation is available at:

```
http://localhost:<port>/docs
```

---

# 📱 Frontend (Flutter Web)

The Flutter frontend consumes backend REST APIs.

## Screens Implemented:
- Login Screen
- Signup Screen
- Home Screen (Product Listing)
- Product Detail Screen
- Cart Screen
- Order Confirmation Screen
- Order Tracking Screen

## Run Flutter:

```bash
flutter run -d chrome
```

---

# 🔐 Authentication

- JWT-based authentication
- Passwords hashed using bcrypt
- Bearer token required for protected routes

---

# 🧩 Microservices Communication

Each service:
- Runs independently
- Has its own Dockerfile
- Exposes REST APIs
- Communicates over HTTP
- Uses JSON format

---

# 📦 Folder Structure

```
quick-commerce-app/
│
├── user-service/
├── product-service/
├── cart-order-service/
├── delivery-service/
├── flutter_app/
├── docker-compose.yml
└── README.md
```

---

# ⚠ Assumptions

- Single warehouse model
- Simple delivery status progression
- Stateless backend services
- No payment gateway integration

---

# 🚀 Future Improvements

- Kubernetes deployment
- CI/CD pipeline
- Payment integration
- Admin dashboard
- Real-time order tracking with WebSockets

---

# 🤖 AI Usage Declaration

AI tools (ChatGPT) were used for:
- Debugging errors
- API integration support
- UI improvements
- Architecture guidance

All final implementation and integration were manually performed.

---

# 🎯 Conclusion

This project demonstrates:

- Microservices architecture
- JWT authentication
- MongoDB integration
- Docker containerization
- Full frontend-backend integration

The system satisfies the assignment requirements and follows clean architectural principles.
