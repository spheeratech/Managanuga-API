const pool = require("../../db");

/* --------------------------------
   HELPER: GET CART ITEM DETAILS
-------------------------------- */
const getCartItemDetails = async (cartId) => {
  const result = await pool.query(
    `
    SELECT
        c.id AS cart_id,
        c.entity_type,
        c.entity_id,
        c.item_type,
        c.item_id AS product_id,
        p.name AS product_name,
        p.price,
        p.stock,
        c.quantity,
        (p.price * c.quantity) AS total_price,
        c.created_at
    FROM cart_items c
    JOIN products p
      ON p.id = c.item_id
    WHERE c.id = $1
    `,
    [cartId],
  );

  return result.rows[0];
};

/* --------------------------------
   ADD ITEM
-------------------------------- */
const addItem = async (data) => {
  const { entity_type, entity_id, item_type, item_id, quantity } = data;

  const existing = await pool.query(
    `
    SELECT *
    FROM cart_items
    WHERE entity_type = $1
      AND entity_id = $2
      AND item_type = $3
      AND item_id = $4
    `,
    [entity_type, entity_id, item_type, item_id],
  );

  // Item already exists
  if (existing.rowCount > 0) {
    const updated = await pool.query(
      `
      UPDATE cart_items
      SET quantity = quantity + $1
      WHERE entity_type = $2
        AND entity_id = $3
        AND item_type = $4
        AND item_id = $5
      RETURNING *
      `,
      [quantity, entity_type, entity_id, item_type, item_id],
    );

    return await getCartItemDetails(updated.rows[0].id);
  }

  // New item
  const result = await pool.query(
    `
    INSERT INTO cart_items (
      entity_type,
      entity_id,
      item_type,
      item_id,
      quantity
    )
    VALUES ($1,$2,$3,$4,$5)
    RETURNING *
    `,
    [entity_type, entity_id, item_type, item_id, quantity],
  );

  return await getCartItemDetails(result.rows[0].id);
};

/* --------------------------------
   GET ALL ITEMS
-------------------------------- */
const getItems = async (entity_type, entity_id) => {
  const result = await pool.query(
    `
    SELECT
      c.id AS cart_id,
      c.entity_type,
      c.entity_id,
      c.item_type,
      c.item_id AS product_id,
      p.name AS product_name,
      p.price,
      p.stock,
      c.quantity,
      (p.price * c.quantity) AS total_price,
      c.created_at
    FROM cart_items c
    JOIN products p
      ON p.id = c.item_id
    WHERE c.entity_type = $1
      AND c.entity_id = $2
    ORDER BY c.id DESC
    `,
    [entity_type, entity_id],
  );

  return result.rows;
};

/* --------------------------------
   GET ITEM BY ID
-------------------------------- */
const getItemById = async (id) => {
  return await getCartItemDetails(id);
};

/* --------------------------------
   UPDATE ITEM
-------------------------------- */
const updateItem = async (id, quantity) => {
  const result = await pool.query(
    `
    UPDATE cart_items
    SET quantity = $1
    WHERE id = $2
    RETURNING *
    `,
    [quantity, id],
  );

  if (result.rowCount === 0) {
    return null;
  }

  return await getCartItemDetails(id);
};

/* --------------------------------
   DELETE ITEM
-------------------------------- */
const deleteItem = async (id) => {
  const result = await pool.query(
    `
    DELETE FROM cart_items
    WHERE id = $1
    RETURNING *
    `,
    [id],
  );

  return result.rows[0];
};
const getAllItems = async () => {
  const result = await pool.query(`
    SELECT
      c.id AS cart_id,
      c.entity_type,
      c.entity_id,
      c.item_type,
      c.item_id AS product_id,
      p.name AS product_name,
      p.price,
      p.stock,
      c.quantity,
      (p.price * c.quantity) AS total_price,
      c.created_at
    FROM cart_items c
    JOIN products p
      ON p.id = c.item_id
    ORDER BY c.id DESC
  `);

  return result.rows;
};

module.exports = {
  addItem,
  getItems,
  getItemById,
  updateItem,
  deleteItem,
  getAllItems,
};
