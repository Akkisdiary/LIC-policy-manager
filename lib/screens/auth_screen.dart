import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/user_services.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserServices _userServices = UserServicesImplementation();
  var _isLoading = false;
  String _userEmail;
  String _userPassword;

  Future<void> _submitAuthForm(BuildContext ctx) async {
    FocusScope.of(ctx).unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await _userServices.signIn(
        email: _userEmail,
        password: _userPassword,
      );
    } on VerificationException catch (err) {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(err.message),
          backgroundColor: Colors.red[300],
        ),
      );
    } catch (err) {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Something went wrong...'),
          backgroundColor: Colors.red[300],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Builder(
          builder: (BuildContext ctx) {
            return Card(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          key: ValueKey('email'),
                          validator: (value) {
                            if (value.isNotEmpty &&
                                value.contains('@') &&
                                value.endsWith('.com')) {
                              return null;
                            }
                            return 'Please enter a valid email address.';
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                          ),
                          onSaved: (value) {
                            _userEmail = value;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('password'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 7) {
                              return 'Enter a valid password';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          onSaved: (value) {
                            _userPassword = value;
                          },
                        ),
                        // SizedBox(height: 12),
                        if (_isLoading)
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        if (!_isLoading)
                          RaisedButton(
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _submitAuthForm(ctx),
                            color: Colors.blue,
                            shape: const StadiumBorder(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
