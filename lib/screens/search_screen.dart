import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/policy_services.dart';
import '../models/policy.dart';
import './policy_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = new TextEditingController();

  List<Policy> list = [];
  bool selectingmode = false;
  List<int> selected = [];

  @override
  Widget build(BuildContext context) {
    PolicyServices policyService = Provider.of<PolicyServices>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: TextField(
          controller: _searchController,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.black),
          ),
          onChanged: (value) {
            setState(
              () {
                searchQuery = value.trim();
              },
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: policyService.getPolicyStream(),
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            list = policyService.searchPolicies(snap, searchQuery);
            if (list == null) {
              return const Center(
                child: Text(
                  "An error occurred,\nTry updating the app from the Play Store",
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
                      '${DateFormat('dd-MM-yyyy').format(list[i].nextInstallment)}',
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
    );
  }
}
