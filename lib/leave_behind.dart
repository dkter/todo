/**
 * A simple to-do list app.
 * Copyright (C) David Teresi 2019
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */

import 'package:flutter/material.dart';
 
 
class LeaveBehindRightView extends StatelessWidget {
    LeaveBehindRightView({Key key}): super(key: key);
 
    @override
    Widget build(BuildContext context) {
        return new Container(
            color: Colors.red,
            padding: const EdgeInsets.all(16.0),
            child: new Row (
                children: <Widget>[
                    new Icon(Icons.delete, color: Colors.white),
                    new Expanded(
                        child: new Text(''),
                    ),
                ],
            ),
        );
    }
}

class LeaveBehindLeftView extends StatelessWidget {
    LeaveBehindLeftView({Key key}): super(key: key);
 
    @override
    Widget build(BuildContext context) {
        return new Container(
            color: Colors.red,
            padding: const EdgeInsets.all(16.0),
            child: new Row (
                children: <Widget>[
                    new Expanded(
                        child: new Text(''),
                    ),
                    new Icon(Icons.delete, color: Colors.white),
                ],
            ),
        );
    }
}