import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/policy_services.dart';
import '../services/user_services.dart';

import './add_policy_screen.dart';
import './my_account_screen.dart';
import './search_screen.dart';
import './edit_policy_screen.dart';
import './web_view_screen.dart';
import './support_screen.dart';
import './birthdays_screen.dart';
import './home_screen.dart';
import './policy_detail_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PolicyServices>(
            create: (context) => PolicyServicesImplementation()),
        Provider<UserServices>(
            create: (context) => UserServicesImplementation()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LIC-Helper',
        routes: {
          AddPolicyScreen.routeName: (ctx) => AddPolicyScreen(),
          EditPolicyScreen.routeName: (ctx) => EditPolicyScreen(),
          PolicyDetailScreen.routeName: (ctx) => PolicyDetailScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          '/recentPolicies': (ctx) => HomeScreen(isRecent: true),
          SupportScreen.routeName: (ctx) => SupportScreen(),
          BirthdayScreen.routeName: (ctx) => BirthdayScreen(),
          MyAccountScreen.routeName: (ctx) => MyAccountScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          WebViewScreen.routeName: (ctx) => WebViewScreen(),
        },
        home: HomeScreen(),
      ),
    );
  }
}
