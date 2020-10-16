import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/agent.dart';

abstract class UserServices {
  Future<void> signIn({
    @required String email,
    @required String password,
  });

  void signOut();

  Future<void> updateProfile(String name, File picture);

  Future<bool> resetPassword();

  Agent agentDetails();
}

class UserServicesImplementation implements UserServices {
  final _auth = FirebaseAuth.instance;
  final _storageRref = FirebaseStorage.instance.ref();
  final _dbRef = FirebaseDatabase.instance.reference();

  Future<void> signIn({
    @required String email,
    @required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var user = _auth.currentUser;

      // Check if user has verified his mail, if not then send verification email.
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('1');
        _auth.signOut();
        print('2');
        throw VerificationException(
            title: 'Verify email',
            message:
                'A verification email has been sent to your registered mail');
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'wrong-password' || err.code == 'user-not-found') {
        throw VerificationException(
            title: 'Invalid_Credentials',
            message: 'Please check your email or password');
      } else if (err.code == 'too-many-requests') {
        throw VerificationException(
            title: 'Too_Many_Requests',
            message: 'We have blocked you for suspicious activity.');
      } else {
        throw VerificationException(
            title: err.code, message: 'Something went wrong...');
      }
    }
  }

  void signOut() {
    _auth.signOut();
  }

  Future<void> updateProfile(String name, File picture) async {
    String imgUrl;
    if (picture != null) {
      print('Uploading Image...');
      final ref = _storageRref
          .child('user_images')
          .child(_auth.currentUser.uid + '.jpg');
      await ref.putFile(picture).onComplete;
      imgUrl = await ref.getDownloadURL();
    } else {
      print('No image found');
    }

    _auth.currentUser.updateProfile(displayName: name, photoURL: imgUrl);
    _dbRef.child('users').child(_auth.currentUser.uid).set({'name': name});
  }

  Future<bool> resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser.email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Agent agentDetails() {
    var user = _auth.currentUser;
    Agent agent = Agent(
      email: user.email,
      name: user.displayName,
      imgUrl: user.photoURL,
    );
    return agent;
  }
}

class VerificationException implements Exception {
  final String title;
  final String message;
  VerificationException({@required this.title, @required this.message});
}
