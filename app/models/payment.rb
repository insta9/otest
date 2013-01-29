class Payment < ActiveRecord::Base
  attr_accessible :invoice_id, :notes, :paid_full, :payment_amount, :payment_date, :payment_method, :send_payment_notification
  belongs_to :invoice
  paginates_per 10
  def client_name
    self.invoice.client.organization_name rescue "credit?"
  end
  def client_full_name
    "#{self.invoice.client.first_name}  #{self.invoice.client.last_name}"
  end
  def self.update_invoice_status inv_id, c_pay
    invoice = Invoice.find(inv_id)
    diff =   (self.invoice_paid_amount(invoice.id) + c_pay) - invoice.invoice_total
    if diff > 0
      status = 'paid'
      self.add_credit_payment invoice.id, diff
      return_v =  c_pay - diff
    elsif diff < 0
      status = 'partial'
      return_v = c_pay
    else
      status = 'paid'
      return_v = c_pay
    end
    invoice.status = status
    invoice.save
    return return_v
  end

  def self.add_credit_payment inv_id, amount
    credit_pay = Payment.new
    credit_pay.payment_type = 'credit'
    credit_pay.invoice_id = inv_id
    credit_pay.payment_amount = amount
    credit_pay.save
  end
  def client_credit client_id
    invoice_ids =  Invoice.where("client_id = ?",client_id).all
    # total credit
    client_payments = Payment.where("payment_type = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_total_credit =  client_payments.sum{|f| f.payment_amount}
    # avail credit
    client_payments = Payment.where("payment_method = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_avail_credit =  client_payments.sum{|f| f.payment_amount}
    balance = client_total_credit - client_avail_credit
    return balance
  end
  
  def self.invoice_remaining_amount inv_id
    invoice = Invoice.find(inv_id)
    invoice_payments = self.invoice_paid_detail(inv_id)
    # invoice_paid_amount =  invoice_payments.sum{|f| f.payment_amount || 0}
    invoice_paid_amount = 0
    invoice_payments.each do |inv_p|
      invoice_paid_amount= invoice_paid_amount + inv_p.payment_amount unless inv_p.payment_amount.blank?
    end
    return   invoice.invoice_total - invoice_paid_amount
  end

  def self.invoice_paid_amount inv_id
    invoice_payments = self.invoice_paid_detail(inv_id)
    invoice_paid_amount = 0
    invoice_payments.each do |inv_p|
      invoice_paid_amount= invoice_paid_amount + inv_p.payment_amount unless inv_p.payment_amount.blank?
    end
    return   invoice_paid_amount
  end

  def self.invoice_paid_detail inv_id
    Payment.where("invoice_id = ? and (payment_type is null || payment_type != 'credit')",inv_id).all
  end
end
