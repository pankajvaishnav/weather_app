import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/constants/constants.dart';
import 'package:weather_app/pages/city_and_country_selector.dart';
import 'package:weather_app/extensions/extensions.dart';
import 'package:weather_app/services/location_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  bool _showProgressIndicator = true;
  bool _isCelsius = true;
  String _cityName = "";

  Weather? _weather;
  List<Weather>? _weatherList;
  List<Map>? _weatherListUnique;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  callback(city) {
    setState(() {
      _showProgressIndicator = true;
      _cityName = city;
    });
    _fetchWeather();
  }

  _fetchWeather() async {
    try {
      if (_cityName.isEmpty) {
        String cityName = await LocationServices.getCurrentCity();

        setState(() {
          _cityName = cityName;
        });
      }

      await _wf.currentWeatherByCityName(_cityName).then((value) {
        setState(() {
          _weather = value;
          _showProgressIndicator = false;
        });
      });
      await _wf.fiveDayForecastByCityName(_cityName).then((value) {
        setState(() {
          _weatherList = value;

          Set<String> unique = {};
          List<Map> list = [];

          for (final weather in _weatherList ?? []) {
            DateTime now = weather.date!;
            if (unique.add(DateFormat("dd.MM.yyyy").format(now))) {
              list.add({
                "day": DateFormat("EEEE").format(now),
                "weatherIcon": weather?.weatherIcon,
                "tempMinC": weather.tempMin?.celsius,
                "tempMaxC": weather.tempMax?.celsius,
                "tempMinF": weather.tempMin?.fahrenheit,
                "tempMaxF": weather.tempMax?.fahrenheit
              });
            } else {
              if (DateFormat("h:mm a").format(now) == "11:30 AM") {
                list.last['weatherIcon'] = weather?.weatherIcon;
              }
              if (weather?.tempMin?.celsius < list.last['tempMinC']) {
                list.last['tempMinC'] = weather?.tempMin?.celsius;
                list.last['tempMinF'] = weather?.tempMin?.fahrenheit;
              }
              if (weather?.tempMax?.celsius > list.last['tempMaxC']) {
                list.last['tempMaxC'] = weather?.tempMin?.celsius;
                list.last['tempMaxF'] = weather?.tempMin?.fahrenheit;
              }
            }
          }
          list.first['day'] = "Today";
          // list.first['tempMinC'] = _weather?.tempMin?.celsius;
          // list.first['tempMinF'] = _weather?.tempMin?.fahrenheit;
          // list.first['tempMaxC'] = _weather?.tempMax?.celsius;
          // list.first['tempMaxF'] = _weather?.tempMax?.fahrenheit;
          list[1]['day'] = "Tomorrow";
          _weatherListUnique = list;
        });
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorPopup(context, e);
    } finally {
      // if (_weather?.areaName?.toLowerCase() != _cityName.toLowerCase()) {
      //   // ignore: use_build_context_synchronously
      //   showErrorPopup(context, "City Not Found !");
      // }
      setState(() {
        _showProgressIndicator = false;
      });
    }
  }

  showErrorPopup(context, message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$message'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: _showProgressIndicator
            ? const SizedBox()
            : _locationHeader(context),
        centerTitle: true,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_weather == null && !_showProgressIndicator) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Something went wrong !",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 16,
            ),
            MaterialButton(
                onPressed: () async {
                  setState(() {
                    _showProgressIndicator = true;
                    _fetchWeather();
                  });
                },
                color: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                )),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade600,
            // Colors.blue.shade300,
            // Colors.blue.shade200,
            Colors.blue.shade200
          ],
          // stops: [0.8, 1.0],
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: _showProgressIndicator
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.04,
                    ),
                    _dateTimeInfo(),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.05,
                    ),
                    _weatherIcon(),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    _currentTemp(),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    _extraInfo(),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    if (_weatherListUnique != null &&
                        _weatherListUnique!.isNotEmpty)
                      _upcomgWeatherReport(),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _locationHeader(context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CityAndCountrySelector(
                    callback: callback,
                  ))),
      child: Text(
        _weather?.areaName ?? "",
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 35,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              "  ${DateFormat("dd.MM.yyyy").format(now)}",
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription == null
              ? ""
              : _weather!.weatherDescription!.toTitleCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return GestureDetector(
      onTap: () => setState(() {
        _isCelsius = !_isCelsius;
      }),
      child: Text(
        !_isCelsius
            ? "${_weather?.temperature?.fahrenheit?.toStringAsFixed(0) == '-0' ? '0' : _weather?.temperature?.fahrenheit?.toStringAsFixed(0)}° F"
            : "${_weather?.temperature?.celsius?.toStringAsFixed(0) == '-0' ? '0' : _weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 90,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.90,
      decoration: BoxDecoration(
        color: Colors.blue.shade400,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      padding: const EdgeInsets.all(
        8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _isCelsius = !_isCelsius;
                }),
                child: Text(
                  _weatherListUnique == null || _weatherListUnique!.isEmpty
                      ? "Max: "
                      : !_isCelsius
                          ? "Max: ${_weatherListUnique?.first['tempMaxF']?.toStringAsFixed(0) == '-0' ? '0' : _weatherListUnique?.first['tempMaxF']?.toStringAsFixed(0)}° F"
                          : "Max: ${_weatherListUnique?.first['tempMaxC']?.toStringAsFixed(0) == '-0' ? '0' : _weatherListUnique?.first['tempMaxC']?.toStringAsFixed(0)}° C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _isCelsius = !_isCelsius;
                }),
                child: Text(
                  _weatherListUnique == null || _weatherListUnique!.isEmpty
                      ? "Min: "
                      : !_isCelsius
                          ? "Min: ${_weatherListUnique?.first['tempMinF']?.toStringAsFixed(0) == '-0' ? '0' : _weatherListUnique?.first['tempMinF']?.toStringAsFixed(0)}° F"
                          : "Min: ${_weatherListUnique?.first['tempMinC']?.toStringAsFixed(0) == '-0' ? '0' : _weatherListUnique?.first['tempMinC']?.toStringAsFixed(0)}° C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _upcomgWeatherReport() {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.90,
      decoration: BoxDecoration(
        color: Colors.blue.shade400,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      padding: const EdgeInsets.all(
        8.0,
      ),
      child: Column(
        children: [
          for (final weather in _weatherListUnique ?? [])
            _weatherWidget(weather)
        ],
      ),
    );
  }

  Widget _weatherWidget(Map weather) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              weather['day'],
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          Flexible(
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.045,
              width: MediaQuery.sizeOf(context).height * 0.045,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "http://openweathermap.org/img/wn/${weather['weatherIcon']}@4x.png"),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          Expanded(
            child: Text(
              !_isCelsius
                  ? "Max: ${weather['tempMaxF']?.toStringAsFixed(0) == '-0' ? '0' : weather['tempMaxF']?.toStringAsFixed(0)}° F"
                  : "Max: ${weather['tempMaxC']?.toStringAsFixed(0) == '-0' ? '0' : weather['tempMaxC']?.toStringAsFixed(0)}° C",
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isCelsius = !_isCelsius;
              }),
              child: Text(
                !_isCelsius
                    ? "Min: ${weather['tempMinF']?.toStringAsFixed(0) == '-0' ? '0' : weather['tempMinF']?.toStringAsFixed(0)}° F"
                    : "Min: ${weather['tempMinC']?.toStringAsFixed(0) == '-0' ? '0' : weather['tempMinC']?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
