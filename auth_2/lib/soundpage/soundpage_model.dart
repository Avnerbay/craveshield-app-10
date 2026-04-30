import '/components/crisis_floating_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_video_player.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'soundpage_widget.dart' show SoundpageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SoundpageModel extends FlutterFlowModel<SoundpageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
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
