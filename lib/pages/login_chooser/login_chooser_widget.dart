import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_chooser_model.dart';
export 'login_chooser_model.dart';

class LoginChooserWidget extends StatefulWidget {
  const LoginChooserWidget({Key? key}) : super(key: key);

  @override
  _LoginChooserWidgetState createState() => _LoginChooserWidgetState();
}

class _LoginChooserWidgetState extends State<LoginChooserWidget> {
  late LoginChooserModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginChooserModel());
  }

  @override
  void dispose() {
    _model.dispose();

    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child:
          Stack(
           children: [
             Container(
               decoration: BoxDecoration(
                 image: DecorationImage(
                   image: AssetImage('assets/background.png'),
                   fit: BoxFit.cover,
                 ),
               ),
             ),

    Positioned(
    top: 250,
    child: SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Padding(
                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                   child: AutoSizeText(
                     'I AM A:',
                     textAlign: TextAlign.center,
                     style: FlutterFlowTheme.of(context).headlineLarge.override(
                       fontFamily: 'Outfit',
                       color: Color(0xFF0097FF),
                       fontSize: 56.0,
                     ),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 40.0, 40.0),
                   child: FFButtonWidget(
                     onPressed: () {
                       Navigator.pushReplacementNamed(
                           context, "/signup_parent");
                     },
                     text: 'PARENT',
                     options: FFButtonOptions(
                       height: 40.0,
                       padding:
                       EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                       iconPadding:
                       EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                       color: Color(0xFF0097FF),
                       textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                         fontFamily: 'Readex Pro',
                         color: Colors.white,
                         fontSize: 36.0,
                       ),
                       elevation: 3.0,
                       borderSide: BorderSide(
                         color: Colors.transparent,
                         width: 1.0,
                       ),
                       borderRadius: BorderRadius.circular(8.0),
                     ),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 40.0, 0.0),
                   child: FFButtonWidget(
                     onPressed: () {
                       Navigator.pushReplacementNamed(
                           context, "/login_child");
                     },
                     text: 'CHILD',
                     options: FFButtonOptions(
                       height: 40.0,
                       padding:
                       EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                       iconPadding:
                       EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                       color: Color(0xFF0097FF),
                       textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                         fontFamily: 'Readex Pro',
                         color: Colors.white,
                         fontSize: 36.0,
                       ),
                       elevation: 3.0,
                       borderSide: BorderSide(
                         color: Colors.transparent,
                         width: 1.0,
                       ),
                       borderRadius: BorderRadius.circular(8.0),
                     ),
                   ),
                 ),
               ],
             )
             )
    )],
          )
        ),
      ),
    );
  }
}
