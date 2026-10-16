CREATE UNIQUE INDEX IF NOT EXISTS coupon_transactions_one_applied_use_per_user
  ON public.coupon_transactions (user_id, coupon_id)
  WHERE status = 'APPLIED'
    AND is_active = 1;

CREATE UNIQUE INDEX IF NOT EXISTS coupon_transactions_one_record_per_payment
  ON public.coupon_transactions (payment_id, coupon_id)
  WHERE payment_id IS NOT NULL;
