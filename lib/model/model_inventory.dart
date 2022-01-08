class Inventory {
  String vin;
  late String? model;
  late String? variant;
  late String? color;
  String dealerCode;
  String status;
  String otherStatus;
  late String? image1, image2, image3, image4, image5, image6, image7;

  Inventory(
      {required this.vin,
      this.model,
      this.variant,
      this.color,
      required this.dealerCode,
      required this.status,
      required this.otherStatus,
      this.image1,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.image7});

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
        vin: json['vin'],
        model: json['model'] ?? "",
        variant: json['variant'] ?? "",
        color: json['color'] ?? "",
        dealerCode: json['dealer_code'],
        status: json['status'],
        otherStatus: json['other_status'],
        image1: json['image1'] ?? "",
        image2: json['image2'] ?? "",
        image3: json['image3'] ?? "",
        image4: json['image5'] ?? "",
        image5: json['image5'] ?? "",
        image6: json['image6'] ?? "",
        image7: json['image7'] ?? "");
  }
}
