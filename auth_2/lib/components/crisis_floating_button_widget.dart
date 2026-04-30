import '/components/crisis_bottom_sheet_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'crisis_floating_button_model.dart';
export 'crisis_floating_button_model.dart';

class CrisisFloatingButtonWidget extends StatefulWidget {
  const CrisisFloatingButtonWidget({super.key});

  @override
  State<CrisisFloatingButtonWidget> createState() =>
      _CrisisFloatingButtonWidgetState();
}

class _CrisisFloatingButtonWidgetState extends State<CrisisFloatingButtonWidget>
    with TickerProviderStateMixin {
  late CrisisFloatingButtonModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrisisFloatingButtonModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.9, 0.9),
            end: Offset(1.2, 1.2),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          context: context,
          builder: (context) {
            return WebViewAware(
              child: Padding(
                padding: MediaQuery.viewInsetsOf(context),
                child: CrisisBottomSheetWidget(),
              ),
            );
          },
        ).then((value) => safeSetState(() {}));
      },
      child: Container(
        width: 313.5,
        height: 319.8,
        decoration: BoxDecoration(
          color: Color(0xFF175064),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(160.0),
            bottomRight: Radius.circular(160.0),
            topLeft: Radius.circular(160.0),
            topRight: Radius.circular(160.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            'assets/images/Crisis_Button_(14).png',
            width: 70.0,
            height: 70.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
  }
}
