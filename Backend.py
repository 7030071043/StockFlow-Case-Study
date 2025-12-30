from decimal import Decimal
from flask import request, jsonify
from sqlalchemy.exc import IntegrityError

@app.route('/api/products', methods=['POST'])
def create_product():
    data = request.get_json()

    required_fields = ['name', 'sku', 'price', 'warehouse_id']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"{field} is required"}), 400

    initial_quantity = data.get('initial_quantity', 0)
    if initial_quantity < 0:
        return jsonify({"error": "Initial quantity cannot be negative"}), 400

    try:
        price = Decimal(str(data['price']))
    except:
        return jsonify({"error": "Invalid price format"}), 400

    try:
        with db.session.begin():

            product = Product(
                name=data['name'],
                sku=data['sku'],
                price=price
            )
            db.session.add(product)
            db.session.flush()  # get product.id

            inventory = Inventory(
                product_id=product.id,
                warehouse_id=data['warehouse_id'],
                quantity=initial_quantity
            )
            db.session.add(inventory)

        return jsonify({
            "message": "Product created",
            "product_id": product.id
        }), 201

    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "SKU already exists"}), 409
