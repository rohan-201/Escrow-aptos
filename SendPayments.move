script SimplePayment
  use 0x1::Payment;

  fun send_payment(receiver: address, amount: u64) {
    let sender: address = 0x1;
    let payment_event: Payment::PaymentEvent;

    assert(Payment::check_account_balance(sender, amount));
    Payment::send_payment(sender, receiver, amount);
    payment_event = Payment::PaymentEvent::new(sender, receiver, amount);
    Payment::emit_event(payment_event);
  }
