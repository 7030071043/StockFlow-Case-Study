-- =========================
-- Companies
-- =========================
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Warehouses
-- =========================
CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_warehouse_company
        FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- =========================
-- Products
-- =========================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    product_type VARCHAR(50), -- e.g. raw, finished, bundle
    low_stock_threshold INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_company
        FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- =========================
-- Inventory (Product ↔ Warehouse)
-- =========================
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    CONSTRAINT uq_product_warehouse
        UNIQUE (product_id, warehouse_id)
);

-- =========================
-- Inventory Movements (Audit Trail)
-- =========================
CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    inventory_id INT NOT NULL,
    change_quantity INT NOT NULL,
    reason VARCHAR(50), -- sale, restock, adjustment
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movement_inventory
        FOREIGN KEY (inventory_id) REFERENCES inventory(id)
);

-- =========================
-- Suppliers
-- =========================
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Product ↔ Supplier Mapping
-- =========================
CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    PRIMARY KEY (product_id, supplier_id),
    CONSTRAINT fk_ps_product
        FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_ps_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- =========================
-- Product Bundles
-- =========================
CREATE TABLE product_bundles (
    bundle_product_id INT NOT NULL,
    child_product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (bundle_product_id, child_product_id),
    CONSTRAINT fk_bundle_parent
        FOREIGN KEY (bundle_product_id) REFERENCES products(id),
    CONSTRAINT fk_bundle_child
        FOREIGN KEY (child_product_id) REFERENCES products(id)
);

-- =========================
-- Indexes for Performance
-- =========================
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_products_company ON products(company_id);
CREATE INDEX idx_warehouses_company ON warehouses(company_id);
