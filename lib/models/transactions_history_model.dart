class UserSummary {
  String? userName;
  String? userId;
  String? email;
  bool? isFriend;
  bool? requestSent;
  bool? requestReceived;

  UserSummary(
      {this.userName,
      this.userId,
      this.email,
      this.isFriend,
      this.requestSent,
      this.requestReceived});

  UserSummary.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    email = json['email'];
    isFriend = json['isFriend'];
    requestSent = json['requestSent'];
    requestReceived = json['requestReceived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['userId'] = this.userId;
    data['email'] = this.email;
    data['isFriend'] = this.isFriend;
    data['requestSent'] = this.requestSent;
    data['requestReceived'] = this.requestReceived;
    return data;
  }
}

class PaymentDetails {
  String? cardToken;
  String? vpa;
  String? cardType;
  Card? card;

  PaymentDetails({this.cardToken, this.vpa, this.cardType, this.card});

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    cardToken = json['cardToken'];
    vpa = json['vpa'];
    cardType = json['cardType'];
    card = json['card'] != null ? new Card.fromJson(json['card']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cardToken'] = this.cardToken;
    data['vpa'] = this.vpa;
    data['cardType'] = this.cardType;
    if (this.card != null) {
      data['card'] = this.card!.toJson();
    }
    return data;
  }
}

class Card {
  String? maskedNumber;
  String? expMonth;
  String? expYear;

  Card({this.maskedNumber, this.expMonth, this.expYear});

  Card.fromJson(Map<String, dynamic> json) {
    maskedNumber = json['maskedNumber'];
    expMonth = json['expMonth'];
    expYear = json['expYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['maskedNumber'] = this.maskedNumber;
    data['expMonth'] = this.expMonth;
    data['expYear'] = this.expYear;
    return data;
  }
}

class TransactionsHistoryModel {
  String? transactionId;
  UserSummary? userSummary;
  String? userId; // Changed from Null? to String?
  String? lobbyId;
  String? lobbyName;
  String? groupUserIds; // Changed from Null? to String?
  String? houseId;
  double? amount;
  String? currency;
  String? paymentMode;
  PaymentDetails? paymentDetails;
  String? entityDetails; // Changed from Null? to String?
  String? status;
  int? statusCode;
  String? statusMessage;
  String? txnSuccessDate; // Changed from Null? to String?
  String? txnFailureDate; // Changed from Null? to String?
  String? txnExpiryDate; // Changed from Null? to String?
  String? settlementStatus; // Changed from Null? to String?
  String? isSettled; // Changed from Null? to String?
  String? settlementDate; // Changed from Null? to String?
  String? expectedSettlementDate; // Changed from Null? to String?

  TransactionsHistoryModel({
    this.transactionId,
    this.userSummary,
    this.userId,
    this.lobbyName,
    this.lobbyId,
    this.groupUserIds,
    this.houseId,
    this.amount,
    this.currency,
    this.paymentMode,
    this.paymentDetails,
    this.entityDetails,
    this.status,
    this.statusCode,
    this.statusMessage,
    this.txnSuccessDate,
    this.txnFailureDate,
    this.txnExpiryDate,
    this.settlementStatus,
    this.isSettled,
    this.settlementDate,
    this.expectedSettlementDate,
  });

  TransactionsHistoryModel.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    userSummary = json['userSummary'] != null
        ? UserSummary.fromJson(json['userSummary'])
        : null;
    userId = json['userId']?.toString(); // Convert to String
    lobbyId = json['lobbyId'];
    lobbyName = json['lobbyName'];
    groupUserIds = json['groupUserIds']?.toString(); // Convert to String
    houseId = json['houseId'];
    amount = json['amount']?.toDouble(); // Ensure it's a double
    currency = json['currency'];
    paymentMode = json['paymentMode'];
    paymentDetails = json['paymentDetails'] != null
        ? PaymentDetails.fromJson(json['paymentDetails'])
        : null;
    entityDetails = json['entityDetails']?.toString(); // Convert to String
    status = json['status'];
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    txnSuccessDate = json['txnSuccessDate']?.toString(); // Convert to String
    txnFailureDate = json['txnFailureDate']?.toString(); // Convert to String
    txnExpiryDate = json['txnExpiryDate']?.toString(); // Convert to String
    settlementStatus =
        json['settlementStatus']?.toString(); // Convert to String
    isSettled = json['isSettled']?.toString(); // Convert to String
    settlementDate = json['settlementDate']?.toString(); // Convert to String
    expectedSettlementDate =
        json['expectedSettlementDate']?.toString(); // Convert to String
  }

  Map<String, dynamic> toJson() {
    return {
      'lobbyName': lobbyName,
      'transactionId': transactionId,
      'userSummary': userSummary?.toJson(),
      'userId': userId,
      'lobbyId': lobbyId,
      'groupUserIds': groupUserIds,
      'houseId': houseId,
      'amount': amount,
      'currency': currency,
      'paymentMode': paymentMode,
      'paymentDetails': paymentDetails?.toJson(),
      'entityDetails': entityDetails,
      'status': status,
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'txnSuccessDate': txnSuccessDate,
      'txnFailureDate': txnFailureDate,
      'txnExpiryDate': txnExpiryDate,
      'settlementStatus': settlementStatus,
      'isSettled': isSettled,
      'settlementDate': settlementDate,
      'expectedSettlementDate': expectedSettlementDate,
    };
  }
}
