import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_video_player.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'longerexplanations_model.dart';
export 'longerexplanations_model.dart';

class LongerexplanationsWidget extends StatefulWidget {
  const LongerexplanationsWidget({super.key});

  static String routeName = 'longerexplanations';
  static String routePath = '/longerexplanations';

  @override
  State<LongerexplanationsWidget> createState() =>
      _LongerexplanationsWidgetState();
}

class _LongerexplanationsWidgetState extends State<LongerexplanationsWidget> {
  late LongerexplanationsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LongerexplanationsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF0A3D91),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Container(
                                width: 374.0,
                                height: 842.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0A3D91),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              39.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20.0),
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/a_-_2025-10-18T193602.556.png',
                                                                              width: 100.0,
                                                                              height: 100.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFF8BC9A2),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Column(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                SingleChildScrollView(
                                                                                                  child: Column(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                        child: Text(
                                                                                                          'Family Photos & Videos',
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.inter(
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                fontSize: 24.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                        child: ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/a_-_2025-10-18T230919.728.png',
                                                                                                            width: 100.0,
                                                                                                            height: 70.0,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                          borderRadius: BorderRadius.only(
                                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                                            bottomRight: Radius.circular(16.0),
                                                                                                            topLeft: Radius.circular(16.0),
                                                                                                            topRight: Radius.circular(16.0),
                                                                                                          ),
                                                                                                        ),
                                                                                                        child: SingleChildScrollView(
                                                                                                          child: Column(
                                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                                            children: [
                                                                                                              SingleChildScrollView(
                                                                                                                child: Column(
                                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                                  children: [
                                                                                                                    Padding(
                                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                      child: Text(
                                                                                                                        'Personal photos and videos serve as powerful emotional anchors. When facing a craving, the brain is often hijacked by short-term reward systems. By looking at familiar faces or meaningful memories, users activate the limbic system’s positive associations with love, belonging, and responsibility. This visual cue redirects attention from the craving to long-term values, creating an immediate sense of grounding. In psychological terms, this works as a form of classical conditioning — linking the relief of cravings to positive personal experiences, instead of nicotine use.',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                              font: GoogleFonts.inter(
                                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                              ),
                                                                                                                              fontSize: 16.0,
                                                                                                                              letterSpacing: 1.5,
                                                                                                                              fontWeight: FontWeight.w600,
                                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                              lineHeight: 1.4,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 2.0, 0.0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                                    child: Container(
                                                                                                      width: 396.7,
                                                                                                      height: 80.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Color(0xFF8BC9A2),
                                                                                                      ),
                                                                                                      child: Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                                                                        child: ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                            width: 200.0,
                                                                                                            height: 200.0,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFF0A3D91),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Column(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                SingleChildScrollView(
                                                                                                  child: Column(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                        child: Text(
                                                                                                          'Watch How It Works',
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.inter(
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                                fontSize: 24.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                                                                                                        child: Container(
                                                                                                          decoration: BoxDecoration(
                                                                                                            borderRadius: BorderRadius.only(
                                                                                                              bottomLeft: Radius.circular(16.0),
                                                                                                              bottomRight: Radius.circular(16.0),
                                                                                                              topLeft: Radius.circular(16.0),
                                                                                                              topRight: Radius.circular(16.0),
                                                                                                            ),
                                                                                                          ),
                                                                                                          child: SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                SingleChildScrollView(
                                                                                                                  child: Column(
                                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                                    children: [
                                                                                                                      Container(
                                                                                                                        width: 450.0,
                                                                                                                        height: 456.7,
                                                                                                                        decoration: BoxDecoration(
                                                                                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                                        ),
                                                                                                                        child: FlutterFlowVideoPlayer(
                                                                                                                          path: 'assets/videos/Untitled_design_-_2025-10-19T142041.354.mp4',
                                                                                                                          videoType: VideoType.asset,
                                                                                                                          autoPlay: false,
                                                                                                                          looping: true,
                                                                                                                          showControls: true,
                                                                                                                          allowFullScreen: true,
                                                                                                                          allowPlaybackSpeedMenu: false,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 420.0, 0.0, 8.0),
                                                                                                    child: Container(
                                                                                                      width: 396.7,
                                                                                                      height: 63.87,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Color(0xFF8BC9A2),
                                                                                                      ),
                                                                                                      child: ClipRRect(
                                                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                                                        child: Image.asset(
                                                                                                          'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                          width: 200.0,
                                                                                                          height: 200.0,
                                                                                                          fit: BoxFit.cover,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.87,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFFDC2727),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'My Music',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 12.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-18T224327.546.png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: SingleChildScrollView(
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                  child: Text(
                                                                                                                    'Music is one of the fastest ways to regulate mood. Neuroscience shows that music activates dopamine pathways — the same brain systems nicotine hijacks. By listening to personally meaningful songs, whether uplifting or calming, users create a healthier dopamine response that competes directly with craving signals. This technique is rooted in behavioral activation: using enjoyable activities to replace addictive behaviors. Personalized music also provides rhythmic breathing cues and emotional expression, helping reduce stress and improve resilience against urges.',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                          font: GoogleFonts.inter(
                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          ),
                                                                                                                          fontSize: 16.0,
                                                                                                                          letterSpacing: 1.5,
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          lineHeight: 1.4,
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 358.2,
                                                                                                    height: 60.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Color(0xFFDC2727),
                                                                                                    ),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                        width: 455.0,
                                                                                                        height: 20.4,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFF677E58),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Breathing Techniques',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-18T113708.977.png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 14.0),
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        borderRadius: BorderRadius.only(
                                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                                          bottomRight: Radius.circular(16.0),
                                                                                                          topLeft: Radius.circular(16.0),
                                                                                                          topRight: Radius.circular(16.0),
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                SingleChildScrollView(
                                                                                                                  child: Column(
                                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 12.0, 0.0),
                                                                                                                        child: Text(
                                                                                                                          'Conscious breathing interrupts the physiological cycle of stress and craving. Nicotine often creates tension and triggers shallow breathing. Structured breathing routines, like 4-7-8 or box breathing, stimulate the parasympathetic nervous system — lowering heart rate and cortisol. This breaks the “fight or flight” loop that cravings often mimic. Uploading or recording personalized breathing routines reinforces habit-formation: practicing calming responses instead of reaching for nicotine. This is a classic CBT coping mechanism that teaches the body and brain to self-regulate under stress.',
                                                                                                                          textAlign: TextAlign.center,
                                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                                font: GoogleFonts.inter(
                                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                                ),
                                                                                                                                fontSize: 16.0,
                                                                                                                                letterSpacing: 1.5,
                                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                                lineHeight: 1.35,
                                                                                                                              ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
                                                                                                            child: Row(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                                                                                  child: Container(
                                                                                                                    width: 390.2,
                                                                                                                    height: 46.0,
                                                                                                                    decoration: BoxDecoration(
                                                                                                                      color: Color(0xFF677E58),
                                                                                                                    ),
                                                                                                                    child: ClipRRect(
                                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                                      child: Image.asset(
                                                                                                                        'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                                        width: 180.0,
                                                                                                                        fit: BoxFit.cover,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFFA2CDCD),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Personal Sounds',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_(100).png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: SingleChildScrollView(
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                  child: Text(
                                                                                                                    'Sounds of loved ones, pets, or nature tap into deep emotional memory. Hearing a child’s laughter, a partner’s encouragement, or even a dog’s bark instantly triggers oxytocin release — counteracting stress hormones and craving signals. In psychology, this is cue exposure therapy: using positive, safe cues to weaken the link between craving and smoking/vaping. These familiar sounds remind users of their “why” — strengthening motivation and identity as someone who protects and values their loved ones.',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                          font: GoogleFonts.inter(
                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          ),
                                                                                                                          fontSize: 16.0,
                                                                                                                          letterSpacing: 1.5,
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          lineHeight: 1.4,
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                                                                                                  child: Container(
                                                                                                    width: 379.1,
                                                                                                    height: 50.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Color(0xFFA2CDCD),
                                                                                                    ),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                        width: 200.0,
                                                                                                        height: 200.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFFA1B674),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Games & Breaks',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-16T191234.017.png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: Column(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      children: [
                                                                                                        SingleChildScrollView(
                                                                                                          child: Column(
                                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                                            children: [
                                                                                                              SingleChildScrollView(
                                                                                                                child: Column(
                                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                                  children: [
                                                                                                                    Padding(
                                                                                                                      padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                      child: Text(
                                                                                                                        'Cravings typically peak for only 5–10 minutes. Interactive distractions like puzzles or mini-games engage the prefrontal cortex, pulling focus away from the craving. Games also provide quick dopamine hits without nicotine, creating a substitute reward loop. Short breaks like a nap, stretching, or a sip ritual act as behavioral replacement strategies, filling the gap left by smoking rituals. This reduces boredom, stress, and habit triggers while training the brain to choose healthier routines.',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                              font: GoogleFonts.inter(
                                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                              ),
                                                                                                                              fontSize: 16.0,
                                                                                                                              letterSpacing: 1.5,
                                                                                                                              fontWeight: FontWeight.w600,
                                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                              lineHeight: 1.4,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                        ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/a_-_2025-10-19T001510.127.png',
                                                                                                            width: 312.2,
                                                                                                            height: 92.6,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFF6DB9C3),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'My Support',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-16T191932.936.png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: SingleChildScrollView(
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                  child: Text(
                                                                                                                    'Supportive messages, whether written by loved ones or self-recorded, provide immediate external motivation during cravings. Psychologically, this functions as social reinforcement: a reminder that quitting is not just about the individual, but about belonging, accountability, and shared pride. Seeing or hearing encouragement during high-risk moments reduces feelings of isolation, which are known craving triggers, and builds resilience.',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                          font: GoogleFonts.inter(
                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          ),
                                                                                                                          fontSize: 16.0,
                                                                                                                          letterSpacing: 1.5,
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          lineHeight: 1.4,
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 2.0, 0.0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 55.0, 0.0, 0.0),
                                                                                                    child: Container(
                                                                                                      width: 361.7,
                                                                                                      height: 70.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Color(0xFF6DB9C3),
                                                                                                      ),
                                                                                                      child: Padding(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                                                                                        child: ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                            width: 200.0,
                                                                                                            height: 51.31,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xA1ECE8E8),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Personal Quotes & Phrases',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-16T192355.319.png',
                                                                                                        width: 120.0,
                                                                                                        height: 80.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: SingleChildScrollView(
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                  child: Text(
                                                                                                                    'Words hold symbolic power. A motivational quote or personal phrase activates cognitive reframing: shifting the internal dialogue from “I need nicotine” to “I am stronger than this craving.” Personalized affirmations are particularly effective, since they tap into existing beliefs and values. Reading them during a craving interrupts negative thought spirals and strengthens self-efficacy — the belief that one can overcome challenges. This is central to CBT and motivational interviewing strategies for addiction recovery.',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                          font: GoogleFonts.inter(
                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          ),
                                                                                                                          fontSize: 16.0,
                                                                                                                          letterSpacing: 1.5,
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          lineHeight: 1.4,
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 45.0, 0.0, 0.0),
                                                                                                  child: Container(
                                                                                                    width: 364.2,
                                                                                                    height: 60.0,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Color(0x0CCECE8E),
                                                                                                    ),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                        width: 200.0,
                                                                                                        height: 200.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              24.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 0.0),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      elevation: 3.0,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: Radius.circular(16.0),
                                                                                          bottomRight: Radius.circular(16.0),
                                                                                          topLeft: Radius.circular(16.0),
                                                                                          topRight: Radius.circular(16.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 1030.9,
                                                                                        height: 650.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color(0xFFD3D320),
                                                                                          borderRadius: BorderRadius.only(
                                                                                            bottomLeft: Radius.circular(16.0),
                                                                                            bottomRight: Radius.circular(16.0),
                                                                                            topLeft: Radius.circular(16.0),
                                                                                            topRight: Radius.circular(16.0),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            SingleChildScrollView(
                                                                                              child: Column(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                                                                                                    child: Text(
                                                                                                      'Short Breaks',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 24.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/a_-_2025-10-16T193936.467.png',
                                                                                                        width: 120.0,
                                                                                                        height: 83.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        bottomLeft: Radius.circular(16.0),
                                                                                                        bottomRight: Radius.circular(16.0),
                                                                                                        topLeft: Radius.circular(16.0),
                                                                                                        topRight: Radius.circular(16.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    child: SingleChildScrollView(
                                                                                                      child: Column(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          SingleChildScrollView(
                                                                                                            child: Column(
                                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 12.0, 0.0),
                                                                                                                  child: Text(
                                                                                                                    'Cravings often disguise themselves as stress, fatigue, or boredom. Adding personal short-break routines — like meditation, stretching, or simply sipping water — addresses the real underlying need instead of masking it with nicotine. These activities reset the body and mind, promoting mindfulness and calm. From a psychological standpoint, this is urge surfing: allowing the craving wave to rise and pass while staying engaged in a healthy ritual. Over time, the brain learns to tolerate and overcome urges naturally.',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                          font: GoogleFonts.inter(
                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          ),
                                                                                                                          fontSize: 16.0,
                                                                                                                          letterSpacing: 1.5,
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                          lineHeight: 1.4,
                                                                                                                        ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 2.0, 0.0),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                                                                                                    child: Container(
                                                                                                      width: 366.7,
                                                                                                      height: 60.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Color(0xFFD3D320),
                                                                                                      ),
                                                                                                      child: ClipRRect(
                                                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                                                        child: Image.asset(
                                                                                                          'assets/images/Title_Poppins_ExtraBold_(6).png',
                                                                                                          width: 200.0,
                                                                                                          height: 200.0,
                                                                                                          fit: BoxFit.cover,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.0, -1.0),
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF0A3D91),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 12.0, 0.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(HomepageWidget.routeName);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/images/Victory_-_2025-10-24T100658.520.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.0, -1.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(NewvictoryWidget.routeName);
                      },
                      child: Container(
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF0A3D91),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 12.0, 0.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/images/Victory_-_2025-10-25T150312.073.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
