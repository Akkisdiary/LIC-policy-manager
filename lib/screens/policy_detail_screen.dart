import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/policy_services.dart';
import '../models/policy.dart';
import './edit_policy_screen.dart';

class PolicyDetailScreen extends StatelessWidget {
  static const routeName = '/PolicyDetailScreen';
  

  @override
  Widget build(BuildContext context) {
    final Policy policy = ModalRoute.of(context).settings.arguments;
    PolicyServices policyService = Provider.of<PolicyServices>(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(policy.customerName),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit),
                        Text('Edit Policy'),
                      ],
                    ),
                  ),
                  value: 'editPolicy',
                ),
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline),
                        Text('Delete'),
                      ],
                    ),
                  ),
                  value: 'delete',
                ),
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'delete') {
                  policyService.deletePolicy(policy.id);
                  Navigator.of(context).pop();
                } else if (itemIdentifier == 'editPolicy') {
                  Navigator.of(context)
                      .pushNamed(EditPolicyScreen.routeName, arguments: policy);
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: width,
              height: width * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width * 0.4,
                    child: Center(
                        child: (policy.imageUrl != null) ? Padding(
                          padding: EdgeInsets.all(width * 0.04),
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                                child: ClipOval(
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.cover,
                                    placeholder: 'assets/images/profile_img.png',
                                    image: policy.imageUrl),
                          ),
                        ),
                      ) : CircleAvatar(
                        radius: width * 0.16,
                        backgroundImage: AssetImage('assets/images/profile_img.png'),
                      ),
                    ),
                  ),
                  Container(
                    width: width * 0.6,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          policy.customerName,
                          maxLines: 3,
                          style: TextStyle(fontSize: 25),
                        ),
                        const Text(
                          'Next premium due:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${DateFormat('dd-MM-yyyy').format(policy.nextInstallment)}',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Policy no:'),
              trailing: SelectableText(
                policy.policyNumber,
              ),
              // onLongPress: () => copyToClipboard(policy.policyNumber),
            ),
            ListTile(
              title: const Text('Start date:'),
              trailing: SelectableText(
                DateFormat('dd-MM-yyyy').format(policy.startDate),
              ),
              // onLongPress: () => copyToClipboard(policy.policyNumber),
            ),
            ListTile(
              title: const Text('Sum assured:'),
              trailing: SelectableText('Rs.${policy.sumAssured}'),
            ),
            ListTile(
              title: const Text('Premium:'),
              trailing: SelectableText('Rs.${policy.premium} / ${policy.mode}'),
            ),
            ListTile(
              title: const Text('Period:'),
              trailing: SelectableText('${policy.period} years'),
            ),
            ListTile(
              title: const Text('Mobile no:'),
              trailing: SelectableText(policy.mobNumber),
              // onLongPress: () => copyToClipboard(policy.mobNumber),
            ),
            ListTile(
              title: const Text('Email:'),
              trailing: SelectableText('${policy.email}'),
              // onLongPress: () => copyToClipboard(policy.email),
            ),
            ListTile(
              title: const Text('Date of Birth:'),
              trailing: SelectableText(
                DateFormat('dd-MM-yyyy').format(policy.dob),
              ),
            ),
            ListTile(
              title: const Text('Gender:'),
              trailing: Text('${policy.gender}'),
            ),
            ListTile(
              title: const Text('Address:'),
              trailing: SelectableText('${policy.address}'),
              // onLongPress: () => copyToClipboard(policy.address),
            ),
            ListTile(
              title: const Text('Nomine:'),
              trailing: SelectableText('${policy.nomineeName}'),
            ),
            if (policy.nomineeName != null)
              ListTile(
                title: const Text('Nomine DOB:'),
                trailing: SelectableText(
                  DateFormat('dd-MM-yyyy').format(policy.nomineeDob),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
