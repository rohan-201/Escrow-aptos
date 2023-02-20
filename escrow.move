// Define a struct for the escrow agreement
struct Escrow {
  payer: address, // Address of the payer
  payee: address, // Address of the payee
  amount: u64, // Amount to be held in escrow
  paid: u64, // Amount paid so far
}

// Define the escrow smart contract
module Escrow {
  // Define the storage for the escrow agreement
  resource EscrowAccount {
    agreement: Escrow,
    complete: bool,
  }

  // Define the public function to create an escrow account
  public fun create_escrow(payer: address, payee: address, amount: u64): &mut EscrowAccount {
    // Require that the amount to be held in escrow is greater than zero
    assert(amount > 0, 77);

    // Create a new escrow agreement
    let agreement = Escrow {
      payer: payer,
      payee: payee,
      amount: amount,
      paid: 0,
    };

    // Store the escrow agreement in storage
    let account = EscrowAccount {
      agreement: agreement,
      complete: false,
    };

    return &mut account;
  }

  // Define the public function to make a payment
  public fun make_payment(account: &mut EscrowAccount, amount: u64, payer: &signer) {
    // Require that the payment amount is greater than zero
    assert(amount > 0, 77);

    // Require that the payment comes from the payer
    assert(payer == account.agreement.payer, 78);

    // Require that the payment does not exceed the remaining amount in escrow
    assert(account.agreement.amount - account.agreement.paid >= amount, 79);

    // Add the payment to the amount paid so far
    account.agreement.paid += amount;

    // If the amount paid is equal to the amount to be held in escrow, mark the escrow agreement as complete
    if account.agreement.paid == account.agreement.amount {
      account.complete = true;
    }
  }

  // Define the public function to release the escrowed funds to the payee
  public fun release_funds(account: &mut EscrowAccount, payee: &signer) {
    // Require that the escrow agreement is complete
    assert(account.complete, 80);

    // Require that the funds are released by the payee
    assert(payee == account.agreement.payee, 81);

    // Transfer the funds to the payee
    let amount = account.agreement.amount;
    move_to(payee, amount);

    // Mark the escrow agreement as complete
    account.complete = true;
  }

  // Define the public function to cancel the escrow agreement and return the funds to the payer
  public fun cancel_escrow(account: &mut EscrowAccount, payer: &signer) {
    // Require that the escrow agreement is not complete
    assert(!account.complete, 82);

    // Require that the escrow agreement is cancelled by the payer
    assert(payer == account.agreement.payer, 83);

    // Return the funds to the payer
    let amount = account.agreement.amount - account.agreement.paid;
    move_to(payer, amount);

    // Mark the escrow agreement as complete
    account.complete = true;
  }
}
