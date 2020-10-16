import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/policy.dart';

abstract class PolicyServices {
  Stream<Event> getPolicyStream();

  List<Policy> getPoliciesList(AsyncSnapshot snapshot);

  List<Policy> searchPolicies(AsyncSnapshot snapshot, String string);

  List<Policy> getUpcomingPoliciesList(
    AsyncSnapshot snapshot,
    DateTime start,
    DateTime end,
  );

  List<Policy> getBirthdaysList(AsyncSnapshot snapshot);

  Future<void> addNewPolicy(Policy _editedPolicy, File _userImageFile);

  Future<void> updatePolicy(Policy _updatedPolicy, File _updatedImageFile);

  Future<void> deletePolicy(String policyId);

  Future<DataSnapshot> getPolicyListFuture();

  Future<Null> sendSmsToPolicy(Policy policy);

  Future<Null> sendBirthdaySms(Policy policy);
}

class PolicyServicesImplementation implements PolicyServices {
  final User user = FirebaseAuth.instance.currentUser;
  final _dbRef = FirebaseDatabase.instance.reference();
  final _storageRref = FirebaseStorage.instance.ref();
  static const platform = const MethodChannel('sendSms');

  Stream<Event> getPolicyStream() {
    return _dbRef
        .child(user.uid)
        .child('policies')
        .orderByChild('startDate')
        .onValue;
  }

  Future<DataSnapshot> getPolicyListFuture() async {
    return _dbRef.child('policies').orderByKey().once();
  }

  List<Policy> getPoliciesList(AsyncSnapshot snapshot) {
    List<Policy> list = List();
    try {
      snapshot.data.snapshot.value.forEach(
        (i, element) {
          DateTime _startDate = DateTime.parse(element['startDate']);
          DateTime _nextInstallment = DateTime.parse(element['startDate']);
          DateTime _maturityDate = DateTime(
              _startDate.year + int.parse(element['period'].toString()),
              _startDate.month,
              _startDate.day);
          String _mode = element['mode'];
          while (_nextInstallment.isBefore(DateTime.now())) {
            if (_mode == 'yearly') {
              _nextInstallment = DateTime(_nextInstallment.year + 1,
                  _nextInstallment.month, _nextInstallment.day);
            } else if (_mode == 'halfyearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 6, _nextInstallment.day);
            } else if (_mode == 'quarterly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 3, _nextInstallment.day);
            } else if (_mode == 'monthly' || _mode == 'sss') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 1, _nextInstallment.day);
            } else {
              print('ERROR: Wrong policy type -> $_mode');
              throw BuildException(
                  title: 'Mode error', message: 'Something went wrong');
            }
          }
          list.add(
            Policy(
              id: i,
              imageUrl: element['imageUrl'],
              customerName: element['customerName'],
              mobNumber: element['mobNumber'],
              email: element['email'],
              dob: DateTime.parse(element['dob']),
              gender: element['gender'],
              address: element['address'],
              policyNumber: element['policyNumber'],
              sumAssured: double.parse(element['sumAssured'].toString()),
              startDate: _startDate,
              period: int.parse(element['period'].toString()),
              maturityDate: _maturityDate,
              mode: _mode,
              premium: double.parse(element['premium'].toString()),
              nextInstallment: _nextInstallment,
              nomineeName: element['nomineeName'],
              nomineeDob: (element['nomineeDob'] != null)
                  ? DateTime.parse(element['nomineeDob'])
                  : null,
            ),
          );
        },
      );
    } catch (e) {
      print(e);
      print('get POLICIES');
      return list = null;
    }
    list.sort((a, b) {
      return a.compareTo(b);
    });
    return list.reversed.toList();
  }

  List<Policy> searchPolicies(AsyncSnapshot snapshot, String string) {
    List<Policy> list = List();
    try {
      snapshot.data.snapshot.value.forEach(
        (i, element) {
          DateTime _startDate = DateTime.parse(element['startDate']);
          DateTime _nextInstallment = DateTime.parse(element['startDate']);
          DateTime _maturityDate = DateTime(
              _startDate.year + int.parse(element['period'].toString()),
              _startDate.month,
              _startDate.day);
          String _mode = element['mode'];
          while (_nextInstallment.isBefore(DateTime.now())) {
            if (_mode == 'yearly') {
              _nextInstallment = DateTime(_nextInstallment.year + 1,
                  _nextInstallment.month, _nextInstallment.day);
            } else if (_mode == 'halfyearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 6, _nextInstallment.day);
            } else if (_mode == 'quarterly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 3, _nextInstallment.day);
            } else if (_mode == 'monthly' || _mode == 'sss') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 1, _nextInstallment.day);
            } else {
              print('ERROR: Wrong policy type -> $_mode');
              throw BuildException(
                  title: 'Mode error', message: 'Something went wrong');
            }
          }
          if (element['customerName']
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              element['policyNumber']
                  .toLowerCase()
                  .contains(string.toLowerCase())) {
            list.add(
              Policy(
                id: i,
                imageUrl: element['imageUrl'],
                customerName: element['customerName'],
                mobNumber: element['mobNumber'],
                email: element['email'],
                dob: DateTime.parse(element['dob']),
                gender: element['gender'],
                address: element['address'],
                policyNumber: element['policyNumber'],
                sumAssured: double.parse(element['sumAssured'].toString()),
                startDate: _startDate,
                period: int.parse(element['period'].toString()),
                maturityDate: _maturityDate,
                mode: _mode,
                premium: double.parse(element['emi'].toString()),
                nextInstallment: _nextInstallment,
                nomineeName: element['nomineeName'],
                nomineeDob: (element['nomineeDob'] != null)
                    ? DateTime.parse(element['nomineeDob'])
                    : null,
              ),
            );
          }
        },
      );
    } catch (e) {
      print(e);
      return list = null;
    }
    list.sort((a, b) {
      return a.compareTo(b);
    });
    return list.reversed.toList();
  }

  List<Policy> getUpcomingPoliciesList(
    AsyncSnapshot snapshot,
    DateTime start,
    DateTime end,
  ) {
    List<Policy> list = List();
    try {
      snapshot.data.snapshot.value.forEach(
        (i, element) {
          DateTime _startDate = DateTime.parse(element['startDate']);
          DateTime _nextInstallment = DateTime.parse(element['startDate']);
          DateTime _maturityDate = DateTime(
              _startDate.year + int.parse(element['period'].toString()),
              _startDate.month,
              _startDate.day);
          String _mode = element['mode'];
          while (_nextInstallment.isBefore(DateTime.now())) {
            if (_mode == 'yearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 12, _nextInstallment.day);
            } else if (_mode == 'halfyearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 6, _nextInstallment.day);
            } else if (_mode == 'quarterly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 3, _nextInstallment.day);
            } else if (_mode == 'monthly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 1, _nextInstallment.day);
            } else {
              print('ERROR: Wrong policy type -> $_mode');
              throw BuildException(
                  title: 'Mode error', message: 'Something went wrong');
            }
          }
          if (_nextInstallment.isBefore(end) &&
              _nextInstallment.isAfter(start)) {
            list.add(
              Policy(
                id: i,
                imageUrl: element['imageUrl'],
                customerName: element['customerName'],
                mobNumber: element['mobNumber'],
                email: element['email'],
                dob: DateTime.parse(element['dob']),
                gender: element['gender'],
                address: element['address'],
                policyNumber: element['policyNumber'],
                sumAssured: double.parse(element['sumAssured'].toString()),
                startDate: _startDate,
                period: int.parse(element['period'].toString()),
                maturityDate: _maturityDate,
                mode: _mode,
                premium: double.parse(element['premium'].toString()),
                nextInstallment: _nextInstallment,
                nomineeName: element['nomineeName'],
                nomineeDob: (element['nomineeDob'] != null)
                    ? DateTime.parse(element['nomineeDob'])
                    : null,
              ),
            );
          }
        },
      );
    } catch (e) {
      print(e);
      return list = null;
    }
    list.sort((a, b) {
      return a.compareTo(b);
    });
    return list.reversed.toList();
  }

  List<Policy> getBirthdaysList(AsyncSnapshot snapshot) {
    List<Policy> list = List();
    try {
      snapshot.data.snapshot.value.forEach(
        (i, element) {
          DateTime _dob = DateTime.parse(element['dob']);
          DateTime _startDate = DateTime.parse(element['startDate']);
          DateTime _nextInstallment = DateTime.parse(element['startDate']);
          DateTime _maturityDate = DateTime(
              _startDate.year + int.parse(element['period'].toString()),
              _startDate.month,
              _startDate.day);
          String _mode = element['mode'];
          while (_nextInstallment.isBefore(DateTime.now())) {
            if (_mode == 'yearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 12, _nextInstallment.day);
            } else if (_mode == 'halfyearly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 6, _nextInstallment.day);
            } else if (_mode == 'quarterly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 3, _nextInstallment.day);
            } else if (_mode == 'monthly') {
              _nextInstallment = DateTime(_nextInstallment.year,
                  _nextInstallment.month + 1, _nextInstallment.day);
            } else {
              throw BuildException(
                  title: 'Mode error', message: 'Something went wrong');
            }
          }
          if (_dob.month == DateTime.now().month &&
              _dob.day == DateTime.now().day) {
            list.add(
              Policy(
                id: i,
                imageUrl: element['imageUrl'],
                customerName: element['customerName'],
                mobNumber: element['mobNumber'],
                email: element['email'],
                dob: _dob,
                gender: element['gender'],
                address: element['address'],
                policyNumber: element['policyNumber'],
                sumAssured: double.parse(element['sumAssured'].toString()),
                startDate: _startDate,
                period: int.parse(element['period'].toString()),
                maturityDate: _maturityDate,
                mode: _mode,
                premium: double.parse(element['premium'].toString()),
                nextInstallment: _nextInstallment,
                nomineeName: element['nomineeName'],
                nomineeDob: (element['nomineeDob'] != null)
                    ? DateTime.parse(element['nomineeDob'])
                    : null,
              ),
            );
          }
        },
      );
    } catch (e) {
      print(e);
      return list = null;
    }

    list.sort((a, b) {
      return a.compareTo(b);
    });
    return list.reversed.toList();
  }

  Future<void> addNewPolicy(Policy _editedPolicy, File _userImageFile) async {
    var policyRef = _dbRef.child(user.uid).child('policies').push();
    if (_userImageFile != null) {
      final ref =
          _storageRref.child('policy_images').child(policyRef.key + '.jpg');
      await ref.putFile(_userImageFile).onComplete;
      _editedPolicy.imageUrl = await ref.getDownloadURL();
    } else {
      print('No Image Selected');
    }
    await policyRef.set(_editedPolicy.toJson());
  }

  Future<void> updatePolicy(
      Policy _updatedPolicy, File _updatedImageFile) async {
    if (_updatedImageFile != null) {
      print(_updatedPolicy.id);
      final ref =
          _storageRref.child('policy_images').child(_updatedPolicy.id + '.jpg');
      await ref.putFile(_updatedImageFile).onComplete;
      _updatedPolicy.imageUrl = await ref.getDownloadURL();
    } else {
      print('No Image Selected');
    }
    await _dbRef
        .child(user.uid)
        .child('policies')
        .child(_updatedPolicy.id)
        .set(_updatedPolicy.toJson());
  }

  Future<void> deletePolicy(String policyId) async {
    await _dbRef.child(user.uid).child('policies').child(policyId).remove();
  }

  Future<Null> sendSmsToPolicy(Policy policy) async {
    // Message Length == 160 chars ...

    try {
      final String result =
          await platform.invokeMethod('send', <String, dynamic>{
        "phone": "+91${policy.mobNumber}",
        "msg":
            "${policy.customerName}, your policy number ${policy.policyNumber} is due on ${DateFormat('dd-MM-yyyy').format(policy.nextInstallment)}. Please pay Rs.${policy.premium.toString()} before due date. Your policy will mature on ${DateFormat('dd-MM-yyyy').format(policy.maturityDate)}\n- ${user.displayName}"
      });
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future<Null> sendBirthdaySms(Policy policy) async {
    // Message Length == 160 chars ...
    try {
      final String result =
          await platform.invokeMethod('send', <String, dynamic>{
        "phone": "+91${policy.mobNumber}",
        "msg":
            "Sincerely wishing you the best of celebrations on this wonderful day of yours. Happy birthday!\n\n- ${user.displayName}"
      });
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}

class BuildException implements Exception {
  final String title;
  final String message;
  BuildException({
    @required this.title,
    @required this.message,
  });
}
