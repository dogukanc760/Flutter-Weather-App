import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu_app/search_page.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Izmir';
  String abbr = 'c';
  int sicaklik = 0;
  var locationData;
  var woeid;
  late Position position;
  List temps = [1,2,3,4,5];
  List abbr_2 = ['','','','',''];
  List dates = ['','','','',''];


  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print('Oluşan hata: $error');
    }
    print(position);
  }

  Future<void> getLocatiomTemperature() async {
    var response =
        await http.get('https://www.metaweather.com/api/location/$woeid');
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik =
          temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();

      temps[0] =  temperatureDataParsed['consolidated_weather'][1]['the_temp'].round();
      temps[1] =  temperatureDataParsed['consolidated_weather'][2]['the_temp'].round();
      temps[2] =  temperatureDataParsed['consolidated_weather'][3]['the_temp'].round();
      temps[3] =  temperatureDataParsed['consolidated_weather'][4]['the_temp'].round();
      temps[4] =  temperatureDataParsed['consolidated_weather'][5]['the_temp'].round();

      dates[0] = temperatureDataParsed['consolidated_weather'][0]['applicable_date'];
      dates[1] = temperatureDataParsed['consolidated_weather'][1]['applicable_date'];
      dates[2] = temperatureDataParsed['consolidated_weather'][2]['applicable_date'];
      dates[3] = temperatureDataParsed['consolidated_weather'][3]['applicable_date'];
      dates[4] = temperatureDataParsed['consolidated_weather'][4]['applicable_date'];

      abbr = temperatureDataParsed['consolidated_weather'][0]
          ['weather_state_abbr'];
      abbr_2[0] = temperatureDataParsed['consolidated_weather'][1]
      ['weather_state_abbr'];
      abbr_2[1] = temperatureDataParsed['consolidated_weather'][2]
      ['weather_state_abbr'];
      abbr_2[2] = temperatureDataParsed['consolidated_weather'][3]
      ['weather_state_abbr'];
      abbr_2[3] = temperatureDataParsed['consolidated_weather'][4]
      ['weather_state_abbr'];
      abbr_2[4] = temperatureDataParsed['consolidated_weather'][5]
      ['weather_state_abbr'];
    });
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataByLatLong() async {
    locationData = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  void getdataFromAPI() async {
    await getDevicePosition(); //cihazdan konum bilgisi alındı
    await getLocationDataByLatLong(); // lat ve long ile bilgisinizi çekiyoruz
    getLocatiomTemperature(); //woeid bilgisi ile sıcaklık verisi çekiliyor.
  }

  void getdataFromAPINonLocation() async {
    await getLocationData(); // lat ve long ile bilgisinizi çekiyoruz
    getLocatiomTemperature(); //woeid bilgisi ile sıcaklık verisi çekiliyor.
  }

  @override
  void initState() {
    getdataFromAPI();

    super.initState();
  }

  @override

  List<String> weekdays = [
    'Pazartesi',
    'Sali',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];


  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: AssetImage('assets/$abbr.jpg')),
      ),
      child: sicaklik == 0
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/$abbr.png')),
                    Text(
                      '$sicaklik°C',
                      style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(-10, 10))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sehir',
                          style: TextStyle(fontSize: 30, shadows: <Shadow>[
                            Shadow(
                                color: Colors.black38,
                                blurRadius: 5,
                                offset: Offset(-10, 10))
                          ]),
                        ),
                        IconButton(
                            onPressed: () async {
                              sehir = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              getdataFromAPINonLocation();
                              setState(() {
                                sehir = sehir;
                              });
                            },
                            icon: Icon(
                              Icons.search,
                              size: 25,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 110,
                    ),
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          DailyWeather(
                              date: weekdays[DateTime.parse(dates[0]).weekday], image: abbr_2[0], temp: temps[0].toString()),
                          DailyWeather(
                              date: weekdays[DateTime.parse(dates[1]).weekday], image: abbr_2[1], temp: temps[1].toString()),
                          DailyWeather(
                              date: weekdays[DateTime.parse(dates[2]).weekday], image: abbr_2[2], temp: temps[2].toString()),
                          DailyWeather(
                              date: weekdays[DateTime.parse(dates[3]).weekday], image: abbr_2[3], temp: temps[3].toString()),
                          DailyWeather(
                              date: weekdays[DateTime.parse(dates[4]).weekday], image: abbr_2[4], temp: temps[4].toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key? key, required this.image, required this.temp, required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text('$temp°C'),
            Text('$date')
          ],
        ),
      ),
    );
  }
}
