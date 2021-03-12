class RefCodeModel {
  String refCode;
  List referrals;

  RefCodeModel();

  RefCodeModel.fromJSON(Map<String, dynamic> jsonMap) {
    refCode = jsonMap['ref_code'];
    referrals = jsonMap['referrals'];
  }
}
