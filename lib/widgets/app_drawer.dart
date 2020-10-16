import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_services.dart';

import '../screens/web_view_screen.dart';
import '../screens/support_screen.dart';
import '../screens/my_account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_policy_screen.dart';
import '../screens/birthdays_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserServices agent = Provider.of<UserServices>(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
                'Hello, ${agent.agentDetails().name}'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Policies'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Upcoming Policies'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/recentPolicies');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Birthdays'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(BirthdayScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Add Policy'),
            onTap: () {
              Navigator.of(context).pushNamed(AddPolicyScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Calculator'),
            onTap: () {
              Navigator.of(context).pushNamed(WebViewScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Account'),
            onTap: () {
              Navigator.of(context).pushNamed(MyAccountScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log Out'),
            onTap: () {
              agent.signOut();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.of(context).pushNamed(SupportScreen.routeName);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
