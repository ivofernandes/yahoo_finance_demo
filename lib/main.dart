import 'package:color_scale/color_scale.dart';
import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: SafeArea(
              child: Container(
                  margin: EdgeInsets.all(10),
                  child: FutureBuilder(
                    future:
                        const YahooFinanceDailyReader().getDailyData('^GSPC'),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        List<dynamic> historicalData = snapshot.data!;
                        return ListView.builder(
                            itemCount: historicalData.length,
                            itemBuilder: (BuildContext context, int index) {
                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      historicalData[index]['date'] * 1000);
                              double variation = 0;
                              if (index != 0) {
                                double yesterdayValue =
                                    historicalData[index - 1]['adjclose'];
                                double todayValue =
                                    historicalData[index]['adjclose'];

                                variation =
                                    (todayValue / yesterdayValue - 1) * 100;
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ColorScaleWidget(
                                    value: variation,
                                    minValue: -2,
                                    minColor: Colors.red,
                                    maxValue: 2,
                                    maxColor: Colors.green,
                                    child: Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          Text(date.toString()),
                                          Text(variation.toStringAsFixed(2)),
                                          Container(
                                              margin: const EdgeInsets.all(10),
                                              child: Text(historicalData[index]
                                                  .toString())),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Text('Error ${snapshot.error}');
                      }

                      return const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )))),
    );
  }
}
