# CourseWork
1. OLTP Database Schema (3NF)
```
┌─────────────────┐
│   Categories    │
├─────────────────┤
│ PK category_id  │
│    category_name│
│    description  │
│    created_at   │
└─────────────────┘
         │
         │ 1:N
         ▼
┌──────────────────┐
│  Subcategories   │
├──────────────────┤
│ PK subcategory_id│
│ FK category_id   │
│    subcategory_  │
│    name          │
│    description   │
└──────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐     ┌─────────────────┐
│    Products     │     │     Brands      │
├─────────────────┤     ├─────────────────┤
│ PK product_id   │     │ PK brand_id     │
│ FK subcategory_ │◄────│    brand_name   │
│    id           │ N:1 │    country      │
│ FK brand_id     │     │    website      │
│    product_name │     └─────────────────┘
│    sku          │
│    price        │
│    description  │
│    warranty_    │
│    months       │
│    created_at   │
└─────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐     ┌─────────────────┐
│   Inventory     │     │   Order_Items   │
├─────────────────┤     ├─────────────────┤
│ PK inventory_id │     │ PK order_item_id│
│ FK product_id   │     │ FK order_id     │
│    quantity     │     │ FK product_id   │◄─┐
│    location     │     │    quantity     │  │
│    last_updated │     │    unit_price   │  │
└─────────────────┘     │    subtotal     │  │
                        └─────────────────┘  │
                                 ▲           │
                                 │ N:1       │
                                 │           │
┌─────────────────┐     ┌────────┴────────┐  │
│   Customers     │     │     Orders      │  │
├─────────────────┤     ├─────────────────┤  │
│ PK customer_id  │     │ PK order_id     │  │
│    email        │◄────│ FK customer_id  │  │
│    first_name   │ 1:N │    order_date   │  │
│    last_name    │     │    shipping_    │  │
│    phone        │     │    address      │  │
│    address      │     │    order_status │  │
│    city         │     │    payment_     │  │
│    country      │     │    method       │  │
│    postal_code  │     │    total_amount │  │
│    created_at   │     └─────────────────┘  │
└─────────────────┘                          │
                                             │
                                Products ────┘
```
2. OLAP Database Schema (Snowflake)
```
                    ┌─────────────────────┐
                    │     Dim_Date        │
                    ├─────────────────────┤
                    │ PK date_key         │
                    │    date             │
                    │    year             │
                    │    quarter          │
                    │    month            │
                    │    month_name       │
                    │    week             │
                    │    day_of_week      │
                    │    day_name         │
                    │    is_weekend       │
                    └─────────────────────┘
                              ▲
                              │
┌────────────────────┐        │        ┌────────────────────────┐
│   Dim_Customer     │        │        │      Fact_Sales        │
│   (SCD Type 2)     │        │        ├────────────────────────┤
├────────────────────┤        │        │ PK sales_key           │
│ PK customer_key    │◄───────┼────────│ FK date_key            │
│    customer_id     │        │        │ FK customer_key        │
│    email           │        │        │ FK product_key         │
│    first_name      │        │        │ FK location_key        │
│    last_name       │        │        │    quantity_sold       │
│    city            │        │        │    unit_price          │
│    country         │        │        │    total_amount        │
│    customer_segment│        │        │    discount_amount     │
│    start_date      │        │        └────────────────────────┘
│    end_date        │        │                    │
│    is_current      │        │                    │
└────────────────────┘        │                    │
                              │                    ▼
┌────────────────────┐        │        ┌────────────────────────┐
│   Dim_Product      │        │        │    Fact_Inventory      │
├────────────────────┤        │        ├────────────────────────┤
│ PK product_key     │◄───────┼────────│ PK inventory_key       │
│    product_id      │        │        │ FK date_key            │
│    product_name    │        │        │ FK product_key         │
│    category        │        │        │ FK location_key        │
│    subcategory     │        │        │    quantity_on_hand    │
│    brand           │        │        │    quantity_available  │
│    price_range     │        │        │    reorder_point       │
└────────────────────┘        │        │    days_in_stock       │
         ▲                    │        └────────────────────────┘
         │                    │                    │
         │                    │                    ▼
         │           ┌────────┴────────┐  ┌──────────────────┐
         │           │  Dim_Location   │  │ Bridge_Product_  │
         │           ├─────────────────┤  │    Category      │
         │           │ PK location_key │  ├──────────────────┤
         │           │    country      │  │ PK bridge_key    │
         │           │    region       │  │ FK product_key   │
         │           │    city         │  │    category_     │
         │           └─────────────────┘  │    group_key     │
         │                                │    weight        │
         └────────────────────────────────└──────────────────┘
```
