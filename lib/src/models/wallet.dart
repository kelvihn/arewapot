class WalletModel {
  final String id;
  final String balance;
  final String userId;

  WalletModel({this.id, this.balance, this.userId});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
        id: json['id'], balance: json['balance'], userId: json['user_id']);
  }
}
