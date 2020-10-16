import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/policy_services.dart';
import '../models/policy.dart';
import '../widgets/app_drawer.dart';
import './policy_detail_screen.dart';

class BirthdayScreen extends StatefulWidget {
  static const routeName = '/BirthdayScrceen';
  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  bool selectingmode = false;
  bool isSmsSending = false;
  List<int> selected = [];
  List<Policy> list;

  Widget _selectAll() {
    return FlatButton(
      onPressed: () {
        if (selected.length == list.length) {
          setState(() {
            selected.clear();
          });
        } else {
          setState(() {
            selected.clear();
            for (var i = 0; i < list.length; i++) {
              selected.add(i);
            }
          });
        }
      },
      child: Text(
        (selected.length == list.length) ? 'Select None' : 'Select All',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PolicyServices policyService = Provider.of<PolicyServices>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        leading: selectingmode
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  selected.clear();
                  setState(() {
                    selectingmode = false;
                    isSmsSending = false;
                  });
                },
              )
            : null,
        title: (selectingmode) ? Text('Selecting...') : Text('Birthdays'),
        actions: [if (selectingmode) _selectAll()],
      ),
      body: StreamBuilder(
        stream: policyService.getPolicyStream(),
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            list = policyService.getBirthdaysList(snap);
            if (list == null) {
              return const Center(
                child: Text(
                  "An error occurred,\nTry updating the app from the Play Store",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(fontSize: 22.0),
                ),
              );
            } else if (list.length < 1) {
              return const Center(
                child: Text(
                  "You don't have any upcoming birthdays",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.0),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, i) => Card(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  elevation: 2,
                  color: selectingmode
                      ? selected.contains(i) ? Colors.lightBlue[50] : null
                      : null,
                  child: ListTile(
                    onLongPress: () {
                      setState(() {
                        selectingmode = true;
                      });
                    },
                    onTap: () {
                      if (selectingmode) {
                        setState(() {
                          if (selected.contains(i)) {
                            selected.remove(i);
                          } else {
                            selected.add(i);
                          }
                        });
                      } else {
                        Navigator.of(context).pushNamed(
                            PolicyDetailScreen.routeName,
                            arguments: list[i]);
                      }
                    },
                    leading: selectingmode
                        ? selected.contains(i)
                            ? Icon(Icons.check_box)
                            : Icon(Icons.check_box_outline_blank)
                        : null,
                    title: Text(
                      list[i].customerName,
                      overflow: TextOverflow.fade,
                    ),
                    subtitle: Text(
                      list[i].policyNumber,
                    ),
                    trailing: Text(
                      '${DateFormat.yMMMd().format(list[i].nextInstallment)}',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              );
            }
          } else if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          } else {
            return const Center(
              child: Text(
                "Welcome. Your list is empty",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.0),
              ),
            );
          }
        },
      ),
      floatingActionButton: (selectingmode)
          ? Card(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              elevation: 6,
              child: ListTile(
                leading: Text('${selected.length} selected '),
                trailing: RaisedButton(
                  onPressed: () {
                    setState(() {
                      isSmsSending = true;
                    });
                    selected.forEach((p) async {
                      await policyService.sendBirthdaySms(list[p]);
                    });
                    Future.delayed(const Duration(milliseconds: 1000))
                        .then((_) {
                      setState(() {
                        isSmsSending = false;
                      });
                    });
                  },
                  shape: StadiumBorder(),
                  child: (isSmsSending)
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: 4, top: 6, bottom: 6),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Send Message'),
                  color: Colors.lightBlue[100],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
