import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/contants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoaded = false;
  num temp = 0.0;
  num press = 0;
  num hum = 0;
  num cover = 0;
  String cityName = '';

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.black),
          child: Visibility(
            visible: isLoaded,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: Column(
              children: [
                Container(
                  width: size.width * 0.85,
                  height: size.height * 0.09,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        setState(() {
                          cityName = value;
                          getCityWeather(cityName);
                          isLoaded = false;
                          controller.clear();
                        });
                      },
                      controller: controller,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search City',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 25,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.pin_drop,
                        color: Colors.red,
                        size: 40,
                      ),
                      Text(
                        cityName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: size.height * 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature: ${temp.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: size.height * 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pressure: ${press.toInt()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: size.height * 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Humidity: ${hum.toInt()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: size.height * 0.12,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cloud Cover: ${cover.toInt()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getCurrentLocation() async {
    var location = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );

    if (location != null) {
      print('Lat:${location.latitude} Long: ${location.longitude}');
      getCurrentCityWeather(location);
      // print('object');
    } else {
      print('Data Unavailable');
    }
  }

  getCityWeather(String cityName) async {
    var client = http.Client();

    var uri = '${domain}q=$cityName&appid=$apiKey';

    var url = Uri.parse(uri);

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = jsonDecode(data);
      print(data);
      updateUi(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  getCurrentCityWeather(Position position) async {
    var client = http.Client();

    var uri = '${domain}lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey';

    var url = Uri.parse(uri);

    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = jsonDecode(data);
      print(data);
      updateUi(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  updateUi(var decodedData) {
    setState(
      () {
        if (decodedData == null) {
          temp = 0;
          press = 0;
          hum = 0;
          cover = 0;
          cityName = 'Not Available';
        } else {
          // print(decodedData['main']['temp']);
          // double n = double.parse(decodedData['main']['temp']);
          // temp = n - 273;
          temp = (decodedData['main']['temp'] - 273) as num;

          press = decodedData['main']['pressure'];
          hum = decodedData['main']['humidity'];
          cover = decodedData['clouds']['all'];
          cityName = decodedData['name'];
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
