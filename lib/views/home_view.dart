import 'package:flutter/material.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<HomeView> {
//  @override

  bool _showCreateForm = false;
  final _formKey = new GlobalKey<FormState>();
  String _name;
  bool _isPrivate = false;

  Widget build(BuildContext context) {


    final user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context);

    if (user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (user.watchGroupId != null && user.watchGroupId.length > 0) {
        // Show content if the user has chosen a watch group
        return new Container(
          height: 0.0,
          width: 0.0,
        );
      } else {
        // Show content if the user hasn't chosen a watch group
        if (!_showCreateForm) {
          return Center(
            child: Column(children: <Widget>[
              welcomeHeading(),
              showJoinButton(),
              showCreateButton(),
            ]),
          );
        } else {
          return new Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: _formKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  showNameInput(),
//                  showPrivateSwitch(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      showCancelFormButton(),
                      showCreateFormButton(),
                    ],
                  ),
//                  showPrimaryButton(),
//                  showErrorMessage(),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  Widget welcomeHeading() {
    return Center(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to NightWatch',
                  style: new TextStyle(
                    fontSize: 25.0,
                    color: new Color(0xFF212121),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Would you like to join an existing neighbourhood watch group or create a new one?',
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: new Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showJoinButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Join',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: joinExisting,
        ),
      ),
    );
  }

  Widget showCreateButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Create',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: showCreateForm,
        ),
      ),
    );
  }

  Widget showCancelFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Color.fromRGBO(254, 109, 64, 1),
                width: 1,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.white,
          child: new Text('Cancel',
              style: new TextStyle(
                  fontSize: 20.0, color: Color.fromRGBO(254, 109, 64, 1))),
          onPressed: cancelCreateForm,
        ),
      ),
    );
  }

  Widget showCreateFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Create',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: showCreateForm,
        ),
      ),
    );
  }

  joinExisting() {
    print('join');
  }

  showCreateForm() {
    setState(() {
      _showCreateForm = true;
    });
  }

  cancelCreateForm() {
    setState(() {
      _showCreateForm = false;
    });
  }

  Widget showNameInput() {
    return Column(
      children: <Widget>[
        Text(
          'Give your Neightbourhood Watch Group a name so others can find it',
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
//              focusedBorder: OutlineInputBorder(
//                borderSide: BorderSide(color: Colors.black, width: 2.0),
//              ),
//              enabledBorder: OutlineInputBorder(
//                borderSide: BorderSide(color: Colors.black, width: 2.0),
//              ),
              hintText: 'Name',
              icon: new Icon(
                Icons.security,
                color: Color.fromRGBO(254, 109, 64, 1),
              ),
            ),
            validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
            onSaved: (value) => _name = value.trim(),
          ),
        ),
      ],
    );
  }

  showPrivateSwitch() {
    if (_isPrivate == null){
      return Container(height: 0.0, width: 0.0);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: Column(
        children: <Widget>[
          Text(
            'Making your group private will prevent others from being able to find it',
            style: new TextStyle(
              fontSize: 18.0,
//            color: Colors.black,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                'Private',
                style: new TextStyle(
                  fontSize: 18.0,
//            color: Colors.black,
                ),
              ),
              Switch(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
