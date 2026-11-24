const referrals = new Map();

const savePendingReferral = (customerId, referrerId) => {
  referrals.set(String(customerId).trim().toUpperCase(), {
    referrerId: String(referrerId).trim(),
    expiresAt: Date.now() + 30 * 60 * 1000,
  });
};

const getPendingReferral = (customerId) => {
  const key = String(customerId).trim().toUpperCase();
  const entry = referrals.get(key);

  if (!entry || entry.expiresAt <= Date.now()) {
    referrals.delete(key);
    return null;
  }

  return entry.referrerId;
};

module.exports = {
  savePendingReferral,
  getPendingReferral,
};