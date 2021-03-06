class AAWSA {
  String user;
  String url;
  String title;
  String bankBranch;
  String paymentDate;
  String transRef;
  int accountNo;
  String customerKey;
  String accountName;
  String billMonth;
  int currentRead;
  int previousRead;
  int consumption;
  double amount;
  String billerBranch;
  AAWSA();

  AAWSA.fromDB(
      {this.user,
      this.url,
      this.title,
      this.bankBranch,
      this.paymentDate,
      this.transRef,
      this.accountNo,
      this.customerKey,
      this.accountName,
      this.billMonth,
      this.currentRead,
      this.previousRead,
      this.consumption,
      this.amount,
      this.billerBranch});

  factory AAWSA.fromJson(Map<String, dynamic> json) {
    AAWSA bill = AAWSA();
    if (json["title"] != null) {
      bill.title = json["title"]["text"] ?? "---";
    }
    if (json["bank_branch"] != null) {
      bill.bankBranch = json["bank_branch"]["text"] ?? "---";
    }
    if (json["payment_date"] != null) {
      bill.paymentDate = json["payment_date"]["text"] ?? "---";
    }
    if (json["tran_ref"] != null) {
      bill.transRef = json["tran_ref"]["text"] ?? "---";
    }
    if (json["account_no"] != null) {
      bill.accountNo = json["account_no"]["valueInteger"] ?? 0;
    }
    if (json["customer_key"] != null) {
      bill.customerKey = json["customer_key"]["text"] ?? "---";
    }
    if (json["account_name"] != null) {
      bill.accountName = json["account_name"]["text"] ?? "---";
    }
    if (json["bill_month"] != null) {
      bill.billMonth = json["bill_month"]["text"] ?? "---";
    }
    if (json["current_read"] != null) {
      bill.currentRead = json["current_read"]["valueInteger"] ?? 0;
    }
    if (json["previous_read"] != null) {
      bill.previousRead = json["previous_read"]["valueInteger"] ?? 0;
    }
    if (json["amount"] != null) {
      bill.amount = double.parse(json["amount"]["text"]) ?? 0;
    }
    if (json["consumption"] != null) {
      bill.consumption = json["consumption"]["valueInteger"] ?? 0;
    }
    if (json['biller_branch'] != null) {
      bill.billerBranch = json["biller_branch"]["text"] ?? "---";
    }
    return bill;
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'user': user,
      'title': title,
      'biller_branch': billerBranch,
      'bank_branch': bankBranch,
      'payment_date': paymentDate,
      'tran_ref': transRef,
      'account_no': accountNo,
      'customer_key': customerKey,
      'account_name': accountName,
      'bill_month': billMonth,
      'current_read': currentRead,
      'previous_read': previousRead,
      'amount': amount,
      'consumption': consumption,
    };
  }
}
