import 'package:fit2eat/features/auth/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:fit2eat/features/scanner/data/models/scan_result.dart';
import 'package:fit2eat/features/history/data/services/firestore_service.dart';
import 'package:fit2eat/features/scanner/presentation/screens/result_screen.dart'; // To navigate to ResultScreen

class feedScreen extends StatefulWidget {
  static const String routeName = '/feed'; // Add this line
  const feedScreen({super.key});

  @override
  State<feedScreen> createState() => feedScreen();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanResult>> _scanHistoryFuture;

  