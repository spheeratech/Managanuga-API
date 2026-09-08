
# Ecommerce API Documentation

Base URL:
http://localhost:5000/api

---

# 📦 PRODUCTS MODULE

## 1. Create Product

### Endpoint

POST /products

### Description

Creates a new product.

### Request Body

```json
{
  "name": "Groundnut Oil",
  "price": 275,
  "stock": 50
}
```

---

### Success Response

Status: 201 Created

```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": 1,
    "name": "Groundnut Oil",
    "price": 275,
    "stock": 50
  }
}
```

---

### Error Response

Status: 400 Bad Request

```json
{
  "success": false,
  "message": "Invalid product data"
}
```

---

## 2. Get All Products

### Endpoint

GET /products

### Description

Fetch all products.

---

### Success Response

Status: 200 OK

```json
{
  "success": true,
  "count": 3,
  "data": [
    {
      "id": 1,
      "name": "Groundnut Oil",
      "price": 275,
      "stock": 50
    },
    {
      "id": 2,
      "name": "Sunflower Oil",
      "price": 300,
      "stock": 50
    },
    {
      "id": 3,
      "name": "Sesame Oil",
      "price": 300,
      "stock": 20
    }
  ]
}
```

---

### Error Response

Status: 500 Internal Server Error

```json
{
  "success": false,
  "message": "Server Error"
}
```

---

## 3. Get Product By ID

### Endpoint

GET /products/:id

### Description

Fetch single product by ID.

---

### Success Response

Status: 200 OK

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Groundnut Oil",
    "price": 275,
    "stock": 50
  }
}
```

---

### Error Response

Status: 404 Not Found

```json
{
  "success": false,
  "message": "Product not found"
}
```

---

## 4. Update Product

### Endpoint

PUT /products/:id

### Description

Updates product details.

### Request Body

```json
{
  "price": 300,
  "stock": 45
}
```

---

### Success Response

```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": {
    "id": 1,
    "name": "Groundnut Oil",
    "price": 300,
    "stock": 45
  }
}
```

---

## 5. Delete Product

### Endpoint

DELETE /products/:id

### Description

Deletes a product.

---

### Success Response

```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

---

### Error Response

```json
{
  "success": false,
  "message": "Product not found"
}
```

---

# ADDRESS MODULE

## 1. Add Address

### Endpoint

POST /address

### Description

Add a new address for a user or entity.

### Request Body

```json
{
  "entity_type": "USER",
  "entity_id": 1,
  "address_type": "HOME",
  "full_name": "Susmitha",
  "phone": "9876543210",
  "address_line1": "Main Road",
  "address_line2": "Near Bus Stand",
  "city": "Hyderabad",
  "state": "Telangana",
  "country": "India",
  "postal_code": "500001",
  "is_default": true
}
```

### Success Response

Status: 201 Created

```json
{
  "success": true,
  "message": "Address added successfully",
  "data": {
    "id": 1,
    "entity_type": "USER",
    "entity_id": 1,
    "city": "Hyderabad"
  }
}
```

### Error Response

Status: 400 Bad Request

```json
{
  "success": false,
  "message": "Invalid address data"
}
```

---

## 2. Get All Addresses

### Endpoint

GET /address

### Success Response

```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": 1,
      "entity_type": "USER",
      "entity_id": 1,
      "city": "Hyderabad"
    }
  ]
}
```

---

## 3. Get Address By User

### Endpoint

GET /address?entity_type=USER&entity_id=1

### Success Response

```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": 1,
      "entity_type": "USER",
      "entity_id": 1,
      "full_name": "Susmitha",
      "city": "Hyderabad"
    }
  ]
}
```

---

## 4. Get Address By City

### Endpoint

GET /address?city=Hyderabad

### Success Response

```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "city": "Hyderabad"
    }
  ]
}
```

---

## 5. Update Address

### Endpoint

PUT /address/:id

### Request Body

```json
{
  "city": "Bangalore",
  "state": "Karnataka"
}
```

### Success Response

```json
{
  "success": true,
  "message": "Address updated successfully",
  "data": {
    "id": 1,
    "city": "Bangalore",
    "state": "Karnataka"
  }
}
```

---

## 6. Delete Address

### Endpoint

DELETE /address/:id

### Success Response

```json
{
  "success": true,
  "message": "Address deleted successfully",
  "data": {
    "id": 1
  }
}
```

---

## Error

````json
{
  "success": false,
  "message": "Error message"
}
---

# 1. Create Order (From Cart)

## Endpoint
POST /orders

## Description
Creates an order from cart items for a user/entity.

## Request Body

```json
{
  "entity_type": "USER",
  "entity_id": 1
}
````

## Success Response

Status: 201 Created

```json id="ordres1"
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "id": 1,
    "entity_type": "USER",
    "entity_id": 1,
    "total_amount": 1500
  }
}
```

## Error Response

Cart empty

```json id="orderr1"
{
  "success": false,
  "message": "Cart is empty"
}
```

---

# 2. Get All Orders

## Endpoint

GET /orders

## Description

Returns all orders in system.

## Success Response

```json id="ordres2"
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "entity_type": "USER",
      "entity_id": 1,
      "total_amount": 1500,
      "status": "pending"
    }
  ]
}
```

---

# 3. Get Orders By User / Entity

## Endpoint

GET /orders?entity_type=USER&entity_id=1

## Description

Fetch orders for a specific user.

## Success Response

```json id="ordres3"
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": 1,
      "entity_type": "USER",
      "entity_id": 1,
      "total_amount": 1500
    }
  ]
}
```

---

# 4. Get Order By ID

## Endpoint

GET /orders/:id

## Example

GET /orders/1

## Success Response

```json id="ordres4"
{
  "success": true,
  "data": {
    "id": 1,
    "entity_type": "USER",
    "entity_id": 1,
    "total_amount": 1500,
    "status": "pending"
  }
}
```

## Error Response

```json id="orderr4"
{
  "success": false,
  "message": "Order not found"
}
```

---

# 5. Get Order Items

## Endpoint

GET /orders/:id/items

## Description

Returns all products inside an order.

## Success Response

```json id="ordres5"
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "product_id": 2,
      "product_name": "Groundnut Oil",
      "quantity": 2,
      "unit_price": 275,
      "total_price": 550
    }
  ]
}
```

---

# 6. Update Order Status

## Endpoint

PUT /orders/:id

## Description

Update order status (pending → shipped → delivered)

## Request Body

```json id="ordreq6"
{
  "status": "shipped"
}
```

## Success Response

```json id="ordres6"
{
  "success": true,
  "message": "Order updated successfully",
  "data": {
    "id": 1,
    "status": "shipped"
  }
}
```

---

# 7. Delete Order

## Endpoint

DELETE /orders/:id

## Description

Deletes order and its items.

## Success Response

```json id="ordres7"
{
  "success": true,
  "message": "Order deleted successfully",
  "data": {
    "id": 1
  }
}
```

---

# 1. Add Item to Cart

## Endpoint

POST /cart

## Description

Adds product/item to user's cart. If item already exists, quantity increases automatically.

## Request Body

```json
{
  "entity_type": "USER",
  "entity_id": 1,
  "item_type": "PRODUCT",
  "item_id": 2,
  "quantity": 2
}
```

## Success Response

Status: 201 Created

```json id="cartblue1"
{
  "success": true,
  "message": "Item added successfully",
  "data": {
    "cart_id": 1,
    "product_id": 2,
    "product_name": "Groundnut Oil",
    "price": 275,
    "quantity": 2,
    "total_price": 550
  }
}
```

---

# 2. Get Cart Items (By User)

## Endpoint

GET /cart?entity_type=USER&entity_id=1

## Description

Fetch all items in a specific user's cart.

## Success Response

```json id="cartblue2"
{
  "success": true,
  "count": 2,
  "data": [
    {
      "cart_id": 1,
      "product_id": 2,
      "product_name": "Groundnut Oil",
      "price": 275,
      "quantity": 2,
      "total_price": 550
    }
  ]
}
```

---

# 3. Get All Cart Items (Admin/Test)

## Endpoint

GET /cart

## Description

Returns ALL cart items in system (used for debugging/admin only).

---

# 4. Get Cart Item By ID

## Endpoint

GET /cart/:id

## Success Response

```json id="cartblue3"
{
  "success": true,
  "data": {
    "cart_id": 1,
    "product_name": "Groundnut Oil",
    "quantity": 2,
    "total_price": 550
  }
}
```

---

# 5. Update Cart Item Quantity

## Endpoint

PUT /cart/:id

## Request Body

```json id="cartblue4"
{
  "quantity": 5
}
```

## Success Response

```json id="cartblue5"
{
  "success": true,
  "message": "Item updated successfully",
  "data": {
    "cart_id": 1,
    "quantity": 5,
    "total_price": 1375
  }
}
```

---

# 6. Delete Cart Item

## Endpoint

DELETE /cart/:id

## Success Response

```json id="cartblue6"
{
  "success": true,
  "message": "Item deleted successfully",
  "data": {
    "id": 1
  }
}
```

## 1. Test Backend

### Endpoint

GET /auth/test

### Description

Checks if authentication service is running.

### Success Response

```json
{
  "message": "Backend working"
}
```

---

## 2. Send OTP

### Endpoint

POST /auth/send-otp

### Description

Sends OTP to the user's mobile number for login.

### Request Body

```json
{
  "mobile": "9876543210"
}
```

### Success Response

```json
{
  "message": "OTP sent successfully"
}
```

### Error Response

```json
{
  "message": "Mobile required"
}
```

---

## 3. Verify OTP (Login)

### Endpoint

POST /auth/verify-otp

### Description

Verifies OTP and logs in the user.
If user does not exist, a new user is created automatically.

### Request Body

```json
{
  "mobile": "9876543210",
  "otp": "123456"
}
```

### Success Response

```json
{
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "mobile": "9876543210"
  }
}
```

### Error Response

```json
{
  "message": "Invalid OTP"
}
```

# 1. Create Payment

## Endpoint

POST /payments

## Description

Creates a new payment for an order.

---

## Request Body

```json id="payreq1"
{
  "order_id": 1,
  "payment_gateway": "RAZORPAY",
  "amount": 1500,
  "status": "PENDING",
  "gateway_order_id": "order_xyz",
  "gateway_payment_id": "pay_xyz"
}
```

---

## Success Response

Status: 201 Created

```json id="payres1"
{
  "success": true,
  "message": "Payment created successfully",
  "data": {
    "id": 1,
    "order_id": 1,
    "payment_gateway": "RAZORPAY",
    "amount": 1500,
    "status": "PENDING"
  }
}
```

---

# 2. Get All Payments

## Endpoint

GET /payments

## Description

Fetch all payment records.

---

## Success Response

```json id="payres2"
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "order_id": 1,
      "amount": 1500,
      "status": "PENDING"
    }
  ]
}
```

---

# 3. Get Payment By ID

## Endpoint

GET /payments/:id

## Example

GET /payments/1

---

## Success Response

```json id="payres3"
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "amount": 1500,
    "status": "PENDING"
  }
}
```

---

## Error Response

```json id="payerr1"
{
  "success": false,
  "message": "Payment not found"
}
```

---

# 4. Update Payment Status

## Endpoint

PUT /payments/:id

## Description

Update payment status (PENDING → SUCCESS → FAILED)

---

## Request Body

```json id="payreq2"
{
  "status": "SUCCESS"
}
```

---

## Success Response

```json id="payres4"
{
  "success": true,
  "message": "Payment updated successfully",
  "data": {
    "id": 1,
    "status": "SUCCESS"
  }
}
```

---

# 5. Delete Payment

## Endpoint

DELETE /payments/:id

---

## Success Response

```json id="payres5"
{
  "success": true,
  "message": "Payment deleted successfully",
  "data": {
    "id": 1
  }
}
```
