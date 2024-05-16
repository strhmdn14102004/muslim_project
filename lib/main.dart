import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:muslim/api/api_manager.dart';
import 'package:muslim/firebase_options.dart';
import 'package:muslim/helper/app_colors.dart';
import 'package:muslim/helper/dimension.dart';
import 'package:muslim/module/auth/login/login_page.dart';
import 'package:muslim/module/home/home_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final ApiManager apiManager = ApiManager();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => HomeBloc(apiManager: apiManager),
        ),
      ],
      child: GlobalLoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/loading_clock.json",
                frameRate: FrameRate(60),
                width: Dimensions.size100 * 2,
                repeat: true,
              ),
              Text(
                "Memuat...",
                style: TextStyle(
                  fontSize: Dimensions.text20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        overlayColor: Colors.black,
        overlayOpacity: 0.8,
        child: GetMaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          title: "Muslim",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: "Barlow",
            colorScheme: AppColors.lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: "Barlow",
            colorScheme: AppColors.darkColorScheme,
          ),
          themeMode: ThemeMode.system,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? Container(),
            );
          },
          home: LoginScreen(),
        ),
      ),
    );
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
