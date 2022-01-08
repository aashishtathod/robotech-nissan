class GetCdrData {
  GetCdrData({
    required this.data,
  });

  List<Datum> data;

  factory GetCdrData.fromJson(Map<String, dynamic> json) {
    return GetCdrData(
      data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
    required this.id,
    required this.vin,
    required this.make,
    required this.mmodel,
    required this.variant,
    required this.dealer,
    required this.customerBookingForm,
    required this.dmsRetailInv,
    required this.dmsGatePass,
    required this.paymentProf,
    required this.registrationDocument,
    this.remark,
  });

  late int id;
  late String vin;
  late String make;
  late String mmodel;
  late String variant;
  late String dealer;
  late String customerBookingForm;
  late String dmsRetailInv;
  late String dmsGatePass;
  late String paymentProf;
  late String registrationDocument;
  late String? remark;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        vin: json["vin"],
        make: json["make"],
        mmodel: json["mmodel"],
        variant: json["variant"],
        dealer: json["dealer"],
        customerBookingForm: json["customer_booking_form"],
        dmsRetailInv: json["DMS_retail_inv"],
        dmsGatePass: json["DMS_gate_pass"],
        paymentProf: json["payment_prof"],
        registrationDocument: json["registration_document"],
        remark: json["remark"] != null ? json["remark"] : "",
      );
}
