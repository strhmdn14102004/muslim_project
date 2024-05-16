import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String? _userEmail;
  @override
  void initState() {
    super.initState();
    _getUserEmail();
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

    for (var time in times) {
      // _schedulePrayerNotification(time['name']!, time['time']!);
    }
  }

// void _schedulePrayerNotification(String prayerName, String prayerTime) async {
//   final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'notif',
//     '$prayerName Notification',
//     channelDescription: 'Notification for $prayerName prayer',
//     icon: 'app_icon', // Ensure this matches the filename without the prefix
//     sound: RawResourceAndroidNotificationSound('azan'),
//     importance: Importance.max,
//     priority: Priority.high,
//   );

//   final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
//     sound: 'azan.aiff',
//   );

//   final platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//     iOS: iOSPlatformChannelSpecifics,
//   );

//   // Get the time for the first prayer of the day
//   final now = tz.TZDateTime.now(tz.local);
//   final dateFormat = DateFormat("HH:mm");
//   final prayerDateTime = dateFormat.parse(prayerTime);
//   var prayerDate = tz.TZDateTime(
//     tz.local,
//     now.year,
//     now.month,
//     now.day,
//     prayerDateTime.hour,
//     prayerDateTime.minute,
//   );

//   // Check if the prayer time is already past, if so, schedule for the next day
//   if (prayerDate.isBefore(now)) {
//     prayerDate = prayerDate.add(Duration(days: 1)); // Update prayerDate
//   }

//   // Schedule the notification
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     0,
//     'Sudah waktu $prayerName',
//     'Sudah waktu $prayerName',
//     prayerDate,
//     platformChannelSpecifics,
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     payload: '$prayerName Notification',
//   );

//   // Log to verify the scheduled time
//   print('Scheduled $prayerName notification at: $prayerDate');

//   // Schedule a daily repeating notification for the prayer
//   await flutterLocalNotificationsPlugin.periodicallyShow(
//     0,
//     'Sudah waktu $prayerName',
//     'Sudah waktu $prayerName',
//     RepeatInterval.daily,
//     platformChannelSpecifics,
//     androidAllowWhileIdle: true,
//     payload: '$prayerName Notification',
//   );
// }

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
    final String backgroundImage = DateTime.now().hour >= 17
        ? "assets/images/background.png"
        : "assets/images/background1.png";
    return Scaffold(
      //     appBar: AppBar(
      //        backgroundColor: Colors.transparent,
      // elevation: 0,
      //       centerTitle: true,
      //       title: const Text("Muslim Pro"),
      //     ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogoutConfirmationDialog(context);
        },
        child: const Icon(Icons.door_back_door_outlined),
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
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Selamat Datang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                  height: 50,
                  width: 50,
                  child: const Image(
                      image: AssetImage('assets/images/photo_profil.png'))),
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
          padding: const EdgeInsets.all(16.0),
          child: _smallListItem(
            name: nextPrayer['name']!,
            time: nextPrayer['time']!,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPrayerSchedulesPage(),
              ),
            );
          },
          child: const Text("Lihat Semua Jadwal"),
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
