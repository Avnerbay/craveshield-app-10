import '/components/crisis_floating_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_video_player.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drinkwater_model.dart';
export 'drinkwater_model.dart';

class DrinkwaterWidget extends StatefulWidget {
  const DrinkwaterWidget({super.key});

  static String routeName = 'drinkwater';
  static String routePath = '/drinkwater';

  @override
  State<DrinkwaterWidget> createState() => _DrinkwaterWidgetState();
}

class _DrinkwaterWidgetState extends State<DrinkwaterWidget> {
  late DrinkwaterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrinkwaterModel());

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Container(
              width: 403.4,
              height: 872.2,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: FlutterFlowVideoPlayer(
                path:
                    'assets/videos/Untitled_design_-_2025-10-03T010243.473.mp4.mp4',
                videoType: VideoType.asset,
                autoPlay: true,
                looping: true,
                showControls: false,
                allowFullScreen: true,
                allowPlaybackSpeedMenu: false,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 118.0, 0.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(NewvictoryWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'assets/images/Victory_-_2025-10-25T134219.864.png',
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 36.0, 0.0, 0.0),
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
                    'assets/images/Victory_-_2025-10-25T134347.689.png',
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1.0, 1.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 12.0),
                child: Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(),
                  child: wrapWithModel(
                    model: _model.crisisFloatingButtonModel,
                    updateCallback: () => safeSetState(() {}),
                    child: CrisisFloatingButtonWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
