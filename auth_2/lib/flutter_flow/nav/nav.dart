import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/quit_selection_screen.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => CraveSplashScreen(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => CraveSplashScreen(),
        ),
        FFRoute(
          name: CraveSplashScreen.routeName,
          path: CraveSplashScreen.routePath,
          builder: (context, params) => CraveSplashScreen(),
        ),
        FFRoute(
          name: CraveDisclaimerScreen.routeName,
          path: CraveDisclaimerScreen.routePath,
          builder: (context, params) => CraveDisclaimerScreen(),
        ),
        FFRoute(
          name: CraveRegisterScreen.routeName,
          path: CraveRegisterScreen.routePath,
          builder: (context, params) => CraveRegisterScreen(),
        ),
        FFRoute(
          name: CraveLoginScreen.routeName,
          path: CraveLoginScreen.routePath,
          builder: (context, params) => CraveLoginScreen(),
        ),
        FFRoute(
          name: 'craveSelectAddiction',
          path: '/crave-select-addiction',
          builder: (context, params) => const QuitSelectionScreen(),
        ),
        FFRoute(
          name: CraveDashboardPlaceholderScreen.routeName,
          path: CraveDashboardPlaceholderScreen.routePath,
          builder: (context, params) => CraveDashboardPlaceholderScreen(),
        ),
        FFRoute(
          name: SplashpageWidget.routeName,
          path: SplashpageWidget.routePath,
          builder: (context, params) => SplashpageWidget(),
        ),
        FFRoute(
          name: DisclaimerPageWidget.routeName,
          path: DisclaimerPageWidget.routePath,
          builder: (context, params) => DisclaimerPageWidget(),
        ),
        FFRoute(
          name: Auth2Widget.routeName,
          path: Auth2Widget.routePath,
          builder: (context, params) => Auth2Widget(),
        ),
        FFRoute(
          name: SoundpageWidget.routeName,
          path: SoundpageWidget.routePath,
          builder: (context, params) => SoundpageWidget(),
        ),
        FFRoute(
          name: GamewebviewpacmanWidget.routeName,
          path: GamewebviewpacmanWidget.routePath,
          builder: (context, params) => GamewebviewpacmanWidget(),
        ),
        FFRoute(
          name: GameviewpagepuzzleWidget.routeName,
          path: GameviewpagepuzzleWidget.routePath,
          builder: (context, params) => GameviewpagepuzzleWidget(),
        ),
        FFRoute(
          name: GamviewpagwrubicscubeWidget.routeName,
          path: GamviewpagwrubicscubeWidget.routePath,
          builder: (context, params) => GamviewpagwrubicscubeWidget(),
        ),
        FFRoute(
          name: BoostPageWidget.routeName,
          path: BoostPageWidget.routePath,
          builder: (context, params) => BoostPageWidget(),
        ),
        FFRoute(
          name: ShareVictoryPageWidget.routeName,
          path: ShareVictoryPageWidget.routePath,
          builder: (context, params) => ShareVictoryPageWidget(),
        ),
        FFRoute(
          name: MyArchiveWidget.routeName,
          path: MyArchiveWidget.routePath,
          builder: (context, params) => MyArchiveWidget(),
        ),
        FFRoute(
          name: HomepageWidget.routeName,
          path: HomepageWidget.routePath,
          builder: (context, params) => HomepageWidget(),
        ),
        FFRoute(
          name: MymusicWidget.routeName,
          path: MymusicWidget.routePath,
          builder: (context, params) => MymusicWidget(),
        ),
        FFRoute(
          name: NewsupportWidget.routeName,
          path: NewsupportWidget.routePath,
          builder: (context, params) => NewsupportWidget(),
        ),
        FFRoute(
          name: Shortbreakpage155Widget.routeName,
          path: Shortbreakpage155Widget.routePath,
          builder: (context, params) => Shortbreakpage155Widget(),
        ),
        FFRoute(
          name: DrinkwaterWidget.routeName,
          path: DrinkwaterWidget.routePath,
          builder: (context, params) => DrinkwaterWidget(),
        ),
        FFRoute(
          name: StretchWidget.routeName,
          path: StretchWidget.routePath,
          builder: (context, params) => StretchWidget(),
        ),
        FFRoute(
          name: ColdpageWidget.routeName,
          path: ColdpageWidget.routePath,
          builder: (context, params) => ColdpageWidget(),
        ),
        FFRoute(
          name: WalkWidget.routeName,
          path: WalkWidget.routePath,
          builder: (context, params) => WalkWidget(),
        ),
        FFRoute(
          name: Breath2025Widget.routeName,
          path: Breath2025Widget.routePath,
          builder: (context, params) => Breath2025Widget(),
        ),
        FFRoute(
          name: MyQuotes2025Widget.routeName,
          path: MyQuotes2025Widget.routePath,
          builder: (context, params) => MyQuotes2025Widget(),
        ),
        FFRoute(
          name: Game2025Widget.routeName,
          path: Game2025Widget.routePath,
          builder: (context, params) => Game2025Widget(),
        ),
        FFRoute(
          name: SmakeWidget.routeName,
          path: SmakeWidget.routePath,
          builder: (context, params) => SmakeWidget(),
        ),
        FFRoute(
          name: CubeWidget.routeName,
          path: CubeWidget.routePath,
          builder: (context, params) => CubeWidget(),
        ),
        FFRoute(
          name: BallWidget.routeName,
          path: BallWidget.routePath,
          builder: (context, params) => BallWidget(),
        ),
        FFRoute(
          name: Photo1Widget.routeName,
          path: Photo1Widget.routePath,
          builder: (context, params) => Photo1Widget(),
        ),
        FFRoute(
          name: LaddersWidget.routeName,
          path: LaddersWidget.routePath,
          builder: (context, params) => LaddersWidget(),
        ),
        FFRoute(
          name: 'vap',
          path: '/vap',
          builder: (context, params) => const QuitSelectionScreen(),
        ),
        FFRoute(
          name: MyShieldPageWidget.routeName,
          path: MyShieldPageWidget.routePath,
          builder: (context, params) => MyShieldPageWidget(),
        ),
        FFRoute(
          name: WhyAddContentPageWidget.routeName,
          path: WhyAddContentPageWidget.routePath,
          builder: (context, params) => WhyAddContentPageWidget(),
        ),
        FFRoute(
          name: LongerexplanationsWidget.routeName,
          path: LongerexplanationsWidget.routePath,
          builder: (context, params) => LongerexplanationsWidget(),
        ),
        FFRoute(
          name: NewvictoryWidget.routeName,
          path: NewvictoryWidget.routePath,
          builder: (context, params) => NewvictoryWidget(),
        ),
        FFRoute(
          name: NewbadgesWidget.routeName,
          path: NewbadgesWidget.routePath,
          builder: (context, params) => NewbadgesWidget(),
        ),
        FFRoute(
          name: NewlogWidget.routeName,
          path: NewlogWidget.routePath,
          builder: (context, params) => NewlogWidget(),
        ),
        FFRoute(
          name: MynewvcitoryWidget.routeName,
          path: MynewvcitoryWidget.routePath,
          builder: (context, params) => MynewvcitoryWidget(
            isDay1Active: params.getParam(
              'isDay1Active',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: SubscribeWidget.routeName,
          path: SubscribeWidget.routePath,
          builder: (context, params) => SubscribeWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
      observers: [routeObserver],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splashpage';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
