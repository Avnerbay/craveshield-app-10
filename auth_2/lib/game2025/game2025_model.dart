import '/components/crisis_floating_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'game2025_widget.dart' show Game2025Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Game2025Model extends FlutterFlowModel<Game2025Widget> {
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
