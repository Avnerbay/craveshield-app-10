import '/components/crisis_floating_button_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'newvictory_widget.dart' show NewvictoryWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewvictoryModel extends FlutterFlowModel<NewvictoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CrisisFloatingButton component.
  late CrisisFloatingButtonModel crisisFloatingButtonModel;

  @override
  void initState(BuildContext context) {
    crisisFloatingButtonModel =
        createModel(context, () => CrisisFloatingButtonModel());
  }

  @override
  void dispose() {
    crisisFloatingButtonModel.dispose();
  }
}
