import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/policy.dart';
import '../services/policy_services.dart';
import '../widgets/app_drawer.dart';

import './policy_detail_screen.dart';
import './search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreen';
  final bool isRecent;

  HomeScreen({this.isRecent = false});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool selectingmode = false;
  bool isSmsSending = false;
  List<int> selected = [];

  List<Policy> list;

  DateTime start = DateTime.now();
  DateTime end = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 7);

  void _presentDatePicker(String type) {
    DatePicker.showDatePicker(context,
    theme: DatePickerTheme(containerHeight: 210.0,),
    showTitleActions: true,
    minTime: (type == 'DOB-S') ? DateTime(2000) : start,
    maxTime: DateTime(2100),
    onConfirm: (pickedDate) {
      if (pickedDate == null) {
        return;
      } else if (type == 'DOB-S') {
        setState(() {
          start = pickedDate;
        });
      } else if (type == 'DOB-E') {
        setState(() {
          end = pickedDate;
        });
      } else {
        print('Date Picker Error');
      }
      setState(() {});
      }, currentTime: DateTime.now(), locale: LocaleType.en,);
  }

  Widget _selectAll() {
    return FlatButton(
      onPressed: () {
        if (selected.length == list.length) {
          selected = [];
        } else {
          selected.clear();
          for (var i = 0; i < list.length; i++) {
            selected.add(i);
          }
        }
        setState(() {});
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
        title: (selectingmode)
            ? const Text('Selecting...')
            : (widget.isRecent)
                ? const Text('Upcoming Policies')
                : const Text('All Policies'),
        actions: [
          (selectingmode)
              ? _selectAll()
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                )
        ],
        bottom: (widget.isRecent)
            ? PreferredSize(
                preferredSize:  Size.fromHeight(AppBar().preferredSize.height),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () => _presentDatePicker('DOB-S'),
                      child: Text(
                        '${DateFormat('dd-MM-yyyy').format(start)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'to',
                      style: TextStyle(color: Colors.white),
                    ),
                    FlatButton(
                      onPressed: () => _presentDatePicker('DOB-E'),
                      child: Text(
                        '${DateFormat('dd-MM-yyyy').format(end)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: StreamBuilder(
        stream: policyService.getPolicyStream(),
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            if (widget.isRecent) {
              list = policyService.getUpcomingPoliciesList(snap, start, end);
            } else {
              list = policyService.getPoliciesList(snap);
            }
            if (list == null) {
              return const Center(
                child: Text(
                  "An error occurred,\nTry updating the app from the Play Store",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(fontSize: 22.0),
                ),
              );
            }
            else if (list.length < 1) {
              return const Center(
                child: Text(
                  "Your list is empty",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(fontSize: 22.0),
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
                        if (selected.contains(i)) {
                          selected.remove(i);
                        } else {
                          selected.add(i);
                        }
                        setState(() {});
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
                      await policyService.sendSmsToPolicy(list[p]);
                    });
                    Future.delayed(const Duration(milliseconds: 2000))
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
                      : Text('Send SMS'),
                  color: Colors.lightBlue[100],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
