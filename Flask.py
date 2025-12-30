@app.route('/api/companies/<int:company_id>/alerts/low-stock')
def low_stock_alerts(company_id):

    alerts = []

    inventories = (
        db.session.query(Inventory)
        .join(Product)
        .join(Warehouse)
        .filter(Warehouse.company_id == company_id)
        .all()
    )

    for inv in inventories:
        product = inv.product
        warehouse = inv.warehouse

        # recent sales check
        sales = get_sales_last_30_days(product.id, warehouse.id)
        if sales == 0:
            continue

        avg_daily_sales = sales / 30
        if avg_daily_sales == 0:
            continue

        threshold = product.low_stock_threshold
        if inv.quantity >= threshold:
            continue

        days_until_stockout = int(inv.quantity / avg_daily_sales)

        supplier = get_primary_supplier(product.id)

        alerts.append({
            "product_id": product.id,
            "product_name": product.name,
            "sku": product.sku,
            "warehouse_id": warehouse.id,
            "warehouse_name": warehouse.name,
            "current_stock": inv.quantity,
            "threshold": threshold,
            "days_until_stockout": days_until_stockout,
            "supplier": {
                "id": supplier.id,
                "name": supplier.name,
                "contact_email": supplier.contact_email
            }
        })

    return jsonify({
        "alerts": alerts,
        "total_alerts": len(alerts)
    })
