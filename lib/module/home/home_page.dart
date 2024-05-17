import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:muslim/helper/app_colors.dart';
import 'package:muslim/helper/dimension.dart';
import 'package:muslim/module/auth/login/login_page.dart';
import 'package:muslim/module/home/home_bloc.dart';
import 'package:muslim/module/home/home_event.dart';
import 'package:muslim/module/home/home_state.dart';
import 'package:muslim/module/semua%20jadwal/semua_jadwal_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _calendarButtonTag = 'calendar_button_tag';
  final String _LogoutButtonTag = 'logout_button_tag';
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _initializeNotifications();
    _requestNotificationPermission();
    _loadPrayerTimes();
  }

  void _getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
    }
  }

  void _loadPrayerTimes() {
    context.read<HomeBloc>().add(LoadPrayerTimes());
  }

  Future<void> _initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (int? id, String? title,
                String? body, String? payload) async {});
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'app_icon',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Ayo sholat',
      'Sholat Sekarang, jangan ditunda tunda\nmau jodoh mu allah tunda juga???~sasat',
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  void _schedulePrayerNotifications(Map<String, dynamic> prayerTimes) {
    final List<Map<String, String>> times = [
      {"name": "Imsak", "time": prayerTimes['data']['jadwal']['imsak']},
      {"name": "Subuh", "time": prayerTimes['data']['jadwal']['subuh']},
      {"name": "Terbit", "time": prayerTimes['data']['jadwal']['terbit']},
      {"name": "Dhuha", "time": prayerTimes['data']['jadwal']['dhuha']},
      {"name": "Dzuhur", "time": prayerTimes['data']['jadwal']['dzuhur']},
      {"name": "Ashar", "time": prayerTimes['data']['jadwal']['ashar']},
      {"name": "Maghrib", "time": prayerTimes['data']['jadwal']['maghrib']},
      {"name": "Isya", "time": prayerTimes['data']['jadwal']['isya']},
    ];

    for (var time in times) {}
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text("Ya, Logout"),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else if (hour < 20) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _requestNotificationPermission() async {
    var status = await Permission.notification.request();
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final String backgroundImage = isDarkMode
        ? "assets/images/background.png"
        : "assets/images/background1.png";

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadPrayerTimes();
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return _buildLoading();
                } else if (state is HomeLoaded) {
                  _schedulePrayerNotifications(state.prayerTimes);
                  return _buildNextPrayerTime(state.prayerTimes);
                } else if (state is HomeError) {
                  return _buildError(state.message);
                } else {
                  return _buildInitial();
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: FloatingActionButton(
              heroTag: _calendarButtonTag,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPrayerSchedulesPage(),
                  ),
                );
              },
              child: const Icon(Icons.schedule_outlined),
            ),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: _LogoutButtonTag,
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottie/loading_clock.json",
            frameRate: const FrameRate(60),
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
    );
  }

  Widget _buildInitial() {
    return const Center(
      child: Text("Tarik ke bawah untuk refresh"),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildNextPrayerTime(Map<String, dynamic> prayerTimes) {
    final now = DateTime.now();
    final dateFormat = DateFormat("HH:mm");
    final greeting = _getGreeting();

    final List<Map<String, String>> times = [
      {"name": "Imsak", "time": prayerTimes['data']['jadwal']['imsak']},
      {"name": "Subuh", "time": prayerTimes['data']['jadwal']['subuh']},
      {"name": "Terbit", "time": prayerTimes['data']['jadwal']['terbit']},
      {"name": "Dhuha", "time": prayerTimes['data']['jadwal']['dhuha']},
      {"name": "Dzuhur", "time": prayerTimes['data']['jadwal']['dzuhur']},
      {"name": "Ashar", "time": prayerTimes['data']['jadwal']['ashar']},
      {"name": "Maghrib", "time": prayerTimes['data']['jadwal']['maghrib']},
      {"name": "Isya", "time": prayerTimes['data']['jadwal']['isya']},
    ];

    Map<String, String>? nextPrayer;
    Duration shortestDuration = const Duration(hours: 24);

    for (var time in times) {
      final prayerTime = dateFormat.parse(time['time']!);
      final prayerDateTime = DateTime(
          now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);

      if (prayerDateTime.isAfter(now)) {
        final duration = prayerDateTime.difference(now);
        if (duration < shortestDuration) {
          shortestDuration = duration;
          nextPrayer = time;
        }
      }
    }

    if (nextPrayer == null) {
      return const Center(child: Text("Belum ada Jadwal Selanjutnya"));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    greeting,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  _showNotification();
                },
                child: Container(
                    height: 50,
                    width: 50,
                    child: const Image(
                        image: AssetImage('assets/images/photo_profil.png'))),
              ),
            )
          ],
        ),
        if (_userEmail != null)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 15),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                _userEmail!,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              "Jadwal Sholat Selanjutnya",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _smallListItem(
            name: nextPrayer['name']!,
            time: nextPrayer['time']!,
          ),
        ),
      ],
    );
  }

  Widget _smallListItem({required String name, required String time}) {
    return IntrinsicHeight(
      child: Center(
        child: Container(
          width: 250,
          padding: EdgeInsets.all(Dimensions.size20),
          margin: EdgeInsets.symmetric(vertical: Dimensions.size10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.size20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mosque_outlined, color: AppColors.primary(), size: 40),
              SizedBox(width: Dimensions.size20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
