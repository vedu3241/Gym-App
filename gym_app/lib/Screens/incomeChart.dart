import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:http/http.dart';

class IncomeChart extends StatefulWidget {
  const IncomeChart({super.key});

  @override
  _IncomeChartState createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  List<double> incomes = []; // Store income values for each month
  int selectedYear = DateTime.now().year; // Default to current year
  List<int> availableYears = [];

  Future<void> fetchAvailableYears() async {
    try {
      List<int> years = await ApiService().getAvailableYears();
      setState(() {
        availableYears = years;
        // Ensure selectedYear is in availableYears
        if (!availableYears.contains(selectedYear)) {
          selectedYear = availableYears.isNotEmpty
              ? availableYears.first
              : DateTime.now().year;
        }
      });
      fetchData(selectedYear); // Fetch data for initially selected year
    } catch (e) {
      print('Error fetching years: $e');
    }
  }

  Future<void> fetchData(int year) async {
    try {
      Response res = await ApiService().getIncomeValues(year);
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        List<double> temp = (jsonData['data'] as Map<String, dynamic>)
            .values
            .map<double>((value) => value.toDouble())
            .toList();

        setState(() {
          // JSON structure is like {"January": 1000, "February": 1500, ...}
          incomes = temp;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAvailableYears();
  }

  double calculateMaxY(List<double> incomes) {
    if (incomes.isEmpty) return 1.0;

    double maxIncome =
        incomes.reduce((value, element) => value > element ? value : element);
    double interval = 100; // You can adjust this interval to fit your needs
    return ((maxIncome / interval).ceil() * interval).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(text: "Dashboard"),
      body: incomes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Drop down for selecting year
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30.0),
                    child: SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<int>(
                        iconSize: 40,
                        // iconEnabledColor: Colors.white,
                        decoration: const InputDecoration(
                          label: Text("Year", style: TextStyle(fontSize: 18)),
                          // labelStyle: TextStyle(
                          //   color: Colors.white,
                          // ),
                          // filled: true,
                          // fillColor: Color.fromARGB(255, 99, 137, 152),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        value: selectedYear,
                        onChanged: (int? year) {
                          if (year != null) {
                            setState(() {
                              selectedYear = year;
                            });
                            fetchData(
                              selectedYear,
                            ); // Fetch data for the selected year
                          }
                        },
                        items: availableYears.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 0,
                      maxHeight: 500,
                    ),
                    padding: const EdgeInsets.only(right: 15),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        maxY: calculateMaxY(incomes),
                        barGroups: List.generate(
                          incomes.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: incomes[index],
                                color: Colors.blueAccent[400],
                              ),
                            ],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getBottomTitles),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Jan', style: style);
        break;
      case 1:
        text = const Text('Feb', style: style);
        break;
      case 2:
        text = const Text('Mar', style: style);
        break;
      case 3:
        text = const Text('Apr', style: style);
        break;
      case 4:
        text = const Text('May', style: style);
        break;
      case 5:
        text = const Text('Jun', style: style);
        break;
      case 6:
        text = const Text('Jul', style: style);
        break;
      case 7:
        text = const Text('Aug', style: style);
        break;
      case 8:
        text = const Text('Sep', style: style);
        break;
      case 9:
        text = const Text('Oct', style: style);
        break;
      case 10:
        text = const Text('Nov', style: style);
        break;
      case 11:
        text = const Text('Dec', style: style);
        break;
      default:
        text = const Text('N/A', style: style);
        break;
    }
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
}
