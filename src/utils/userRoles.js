const ROLE_NAMES_BY_ID = {
  1: "SUPER_ADMIN",
  2: "ADMIN",
  3: "VENDOR",
  4: "RESELLER",
  5: "CUSTOMER",
  6: "USER",
};

const ROLE_IDS_BY_NAME = Object.fromEntries(
  Object.entries(ROLE_NAMES_BY_ID).map(([id, name]) => [name, Number(id)]),
);

const getRoleName = (role) => {
  const normalizedRole = String(role ?? "").trim().toUpperCase();
  if (Object.prototype.hasOwnProperty.call(ROLE_IDS_BY_NAME, normalizedRole)) {
    return normalizedRole;
  }

  return ROLE_NAMES_BY_ID[Number(role)] || null;
};

module.exports = {
  ROLE_IDS_BY_NAME,
  ROLE_NAMES_BY_ID,
  getRoleName,
};
