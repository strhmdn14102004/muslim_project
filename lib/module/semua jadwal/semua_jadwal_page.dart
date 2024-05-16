import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim/helper/app_colors.dart';
import 'package:muslim/helper/dimension.dart';
import 'package:muslim/module/home/home_bloc.dart';
import 'package:muslim/module/home/home_state.dart';

class AllPrayerSchedulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Jadwal Shalat Hari Ini",
          style: TextStyle(),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return _buildPrayerScheduleGrid(state.prayerTimes);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPrayerScheduleGrid(Map<String, dynamic> prayerTimes) {
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.size20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Dimensions.size10,
              mainAxisSpacing: Dimensions.size10,
              childAspectRatio: 2.5,
            ),
            itemCount: times.length,
            itemBuilder: (context, index) {
              return _gridItem(
                name: times[index]['name']!,
                time: times[index]['time']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _gridItem({required String name, required String time}) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.size20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.mosque, color: AppColors.primary(), size: 24),
          SizedBox(width: Dimensions.size10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text(time,
                  style: const TextStyle(fontSize: 15, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
