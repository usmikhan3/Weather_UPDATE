import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //VARIABLES
  int temperature;
  String location = "karachi";
  int woeid = 2211096;
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';
  var minTemperatureForecast = new List(7);
  var maxTemperatureForecast = new List(7);
  var abbreviationForecast = new List(7);



  //API URL FOR SEARCH AND LOCATION
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  //FUNCTION FOR SEARCHING
  void fetchSearch(String input) async{
    try{
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    }catch(error){
      setState(() {
        errorMessage = "Sorry, we don't have data about this city. Try another one.";
      });
    }
  }

//FUNCTION FOR LOCATION
  void fetchLocation() async{
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];
    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];

    });
}

//FUNCTION FOR FUTURE PREDICTION
  void fetchLocationDay() async{
    var today = new DateTime.now();
    for (var i = 0; i<7;i++){
      var locationDayResult = await http
          .get(locationApiUrl + woeid.toString() + '/' + new DateFormat('y/M/d')
          .format(today.add(new Duration(days: i + 1)))
          .toString());
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data["weather_state_abbr"];

      });

    }

  }

onTextFieldSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();

}


  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop)
          )
        ),
      child: temperature == null ? Center(child: CircularProgressIndicator(),) : Scaffold(
        backgroundColor: Colors.transparent,
        //MAIN COLUMN CONTAING EVERY WIDGETS
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //COLUMN HAVING ABB IMAGE and TEMP and LOC
                Column(
                  children: [
                    Center(
                        child: Image.network( 'https://www.metaweather.com/static/img/weather/png/' + abbreviation + '.png', width: 100,),

                    ),
                    Center(
                      child: Text(temperature.toString() + ' °C',
                        style: TextStyle(
                            color: Colors.white, fontSize: 60.0),
                      ),

                    ),
                    Center(
                        child: Text(location,
                          style: TextStyle(
                              color: Colors.white, fontSize: 40.0),
                        )
                    ),
                  ],
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      children: [
                        for(var i =0; i<7; i++)
                          forecastElement(i+1, abbreviationForecast[i], maxTemperatureForecast[i], minTemperatureForecast[i])
                      ],
                    ),
                  ),
                ),



                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search for city",
                            hintStyle: TextStyle(color: Colors.white, fontSize: 20.0),
                              prefixIcon:
                              Icon(Icons.search, color: Colors.white)
                          ),
                          onSubmitted: (String input){
                            onTextFieldSubmitted(input);
                          },
                          style: TextStyle(
                            color: Colors.white, fontSize: 20.0
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(right: 32.0, left: 32.0),
                        child: Text(errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize:
                                Platform.isAndroid ? 15.0 : 20.0)),
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
}

Widget forecastElement(daysFromNow, abbreviation, maxTemperature, minTemperature){
  var now = new DateTime.now();
  var oneDayfromNow = now.add(new Duration(days: daysFromNow));
  
  return Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(205, 212, 220, 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(new DateFormat.E().format(oneDayfromNow),
              style: TextStyle(
                  color: Colors.white, fontSize: 25.0)),
          Text(new DateFormat.MMMd().format(oneDayfromNow),
              style: TextStyle(
                  color: Colors.white, fontSize: 20.0)),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Image.network('https://www.metaweather.com/static/img/weather/png/' +
                abbreviation +
                '.png',
              width: 50,),
          ),
          Text('High: ' + maxTemperature.toString() + ' °C',
              style: TextStyle(
                  color: Colors.white, fontSize: 20.0)),
          Text('Low: ' + minTemperature.toString() + ' °C',
              style: TextStyle(
                  color: Colors.white, fontSize: 20.0))
        ],
      ),
    ),
  );
}

