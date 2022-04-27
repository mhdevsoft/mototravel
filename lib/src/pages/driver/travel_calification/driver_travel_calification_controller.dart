import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mototravel/src/models/TravelHistory.dart';
import 'package:mototravel/src/pages/providers/travel_history_provider.dart';
import 'package:mototravel/src/utils/snackbar.dart' as utils;
class DriverTravelCalificationController {
BuildContext context;
GlobalKey<ScaffoldState> key = new GlobalKey();
Function refresh;
String idTravelHistory;

TravelHistoryProvider _travelHistoryProvider;
TravelHistory travelHistory;

double calification;

Future init (BuildContext context, Function refresh ) 
{
  this.context = context;
  this.refresh = refresh; 
  idTravelHistory =  ModalRoute.of(context).settings.arguments as String;
 _travelHistoryProvider = new TravelHistoryProvider();

  //captura de datos desde el main.activity
  //new version Notification get data
    getTravelHistory();
 
}

void calificate() async {
 if (calification == null)
 {
  utils.Snackbar.showSnackbar(context, key, 'Por Favor Califica a tu cliente');
  return;
 }
 if (calification == 0)
  {
  utils.Snackbar.showSnackbar(context, key, 'La Calificacion minima es 1');
  return;
  }
  Map<String, dynamic> data = {
  'calaficationClient': calification
  };

  await _travelHistoryProvider.update(data, idTravelHistory);
  Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
}

void getTravelHistory() async
{
 travelHistory = await _travelHistoryProvider.getById(idTravelHistory);
  refresh();
}



 
}