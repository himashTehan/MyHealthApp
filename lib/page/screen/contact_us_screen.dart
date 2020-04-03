import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selftrackingapp/app_localizations.dart';
import 'package:selftrackingapp/models/contact_us_contact.dart';
import 'package:selftrackingapp/networking/data_repository.dart';
import 'package:selftrackingapp/utils/tracker_colors.dart';
import 'package:selftrackingapp/widgets/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../../utils/tracker_colors.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    BuildContext contextOriginal = context;
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: GetIt.instance<DataRepository>().fetchContactUsContacts(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Text(
                      "An error has occured fetching contacts, try again later"),
                );
                break;
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
                break;
              case ConnectionState.active:
                return Center(
                  child: Text(
                      "An error has occured fetching contacts, try again later"),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasData) {
                  List<ContactUsContact> contacts = snapshot.data;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      print(contacts[index]);
                      return _contactCard(
                          contextOriginal,
                          contacts[index].title,
                          contacts[index].phoneNumber,
                          contacts[index].address,
                          contacts[index].subContacts);
                    },
                    itemCount: contacts.length,
                  );
                } else {
                  return Center(
                    child: Text("An error has occured, try again later. "),
                  );
                }
                break;
              default:
                return Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ));
  }

  Widget _contactCard(BuildContext contextParent, String title,
      String phoneNumber, String address, List<ContactUsContact> subContacts) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Container(
        decoration: BoxDecoration(
            color: TrackerColors.primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomText(
              subContacts == null
                  ? phoneNumber
                  : AppLocalizations.of(context).translate(phoneNumber),
              style: h1TextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            CustomText(
              AppLocalizations.of(context).translate(title),
              style: h3TextStyle.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.0),
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: RaisedButton(
                  color: Colors.green,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10.0),
                  onPressed: () async {
                    if (subContacts == null &&
                        await canLaunch("tel:$phoneNumber")) {
                      await launch("tel:$phoneNumber");
                    } else if (subContacts != null) {
                      await showDialog(
                        barrierDismissible: true,
                        context: contextParent,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          title: Container(
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context).translate(
                                        "medical_consultation_service_title"),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    AppLocalizations.of(context).translate(
                                        "medical_consultation_service_foc"),
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.lightBlue),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ),
                          content: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 300,
                                  height: 200,
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FlatButton(
                                          color: Colors.blue,
                                          onPressed: () async {
                                            await launch(subContacts[index]
                                                    .phoneNumber
                                                    .split(",")[
                                                Platform.isIOS ? 1 : 0]);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CustomText(
                                              subContacts[index].title,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: subContacts.length,
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: [
                            FlatButton(
                                child: Text("Ok"),
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop()),
                          ],
                        ),
                      );
                    } else {
                      await showDialog(
                        barrierDismissible: true,
                        context: contextParent,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          title: Text("Oops, something went wrong"),
                          content: Text(
                              "Failed to make phone call, try again later."),
                          actions: [
                            FlatButton(
                                child: Text("Ok"),
                                onPressed: () => Navigator.of(context).pop()),
                          ],
                        ),
                      );
                    }
                  },
                  child: subContacts == null
                      ? Icon(Icons.phone, color: Colors.white)
                      : Icon(Icons.help, color: Colors.white)),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 2.0,
                    ),
                    CustomText(
                      address,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
