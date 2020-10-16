import 'package:firebase_database/firebase_database.dart';

class Policy implements Comparable {
  String id;
  String imageUrl;
  String customerName;
  String mobNumber;
  String email;
  DateTime dob;
  String gender;
  String address;
  String policyNumber;
  double sumAssured;
  DateTime startDate;
  int period;
  DateTime maturityDate;
  String mode;
  double premium;
  DateTime nextInstallment;
  String nomineeName;
  DateTime nomineeDob;

  Policy({
    this.id,
    this.imageUrl,
    this.customerName,
    this.mobNumber,
    this.email,
    this.dob,
    this.gender,
    this.address,
    this.policyNumber,
    this.sumAssured,
    this.startDate,
    this.period,
    this.maturityDate,
    this.mode,
    this.premium,
    this.nextInstallment,
    this.nomineeName,
    this.nomineeDob,
  });

  Policy.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        imageUrl = snapshot.value['imageUrl'],
        customerName = snapshot.value['customerName'],
        mobNumber = snapshot.value['mobNumber'],
        email = snapshot.value['email'],
        dob = snapshot.value['dob'],
        gender = snapshot.value['gender'],
        address = snapshot.value['address'],
        policyNumber = snapshot.value['policyNumber'],
        sumAssured = snapshot.value['sumAssured'],
        startDate = snapshot.value['startDate'],
        period = snapshot.value['period'],
        // maturityDate = snapshot.value['maturityDate'],
        mode = snapshot.value['mode'],
        premium = snapshot.value['premium'],
        nomineeName = snapshot.value['nomineeName'],
        nomineeDob = snapshot.value['nomineeDob'];

  toJson() {
    return {
      'imageUrl': imageUrl,
      'customerName': customerName,
      'mobNumber': mobNumber,
      'email': email,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'address': address,
      'policyNumber': policyNumber,
      'sumAssured': sumAssured,
      'startDate': startDate.toIso8601String(),
      'period': period,
      'mode': mode,
      'premium': premium,
      'nomineeName': nomineeName,
      if (nomineeDob != null) 'nomineeDob': nomineeDob.toIso8601String(),
    };
  }

  @override
  int compareTo(other) {
    if (this.nextInstallment == null || other == null) {
      return null;
    }

    if (this.nextInstallment.isBefore(other.nextInstallment)) {
      return 1;
    }

    if (this.nextInstallment.isAfter(other.nextInstallment)) {
      return -1;
    }

    if (this.nextInstallment.isAtSameMomentAs(other.nextInstallment)) {
      return 0;
    }

    return null;
  }
}