import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltrainer_desktop/models/dashboard_report.dart';
import 'package:personaltrainer_desktop/models/trainer_dashboard.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class DashboardProvider extends BaseProvider<DashboardReport> {
  DashboardProvider() : super("Dashboard");

  // SuperAdmin report
  DashboardReport? _report;
  bool _isLoading = false;
  String? _error;

  DashboardReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Trainer dashboard
  TrainerDashboard? _trainerDashboard;
  bool _isTrainerLoading = false;
  String? _trainerError;

  TrainerDashboard? get trainerDashboard => _trainerDashboard;
  bool get isTrainerLoading => _isTrainerLoading;
  String? get trainerError => _trainerError;

  @override
  DashboardReport fromJson(data) {
    return DashboardReport.fromJson(data);
  }

  Future<void> fetchReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawUrl = '${BaseProvider.baseUrl}Dashboard/report';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _report = DashboardReport.fromJson(data);
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized. Please log in again.';
      } else if (response.statusCode == 403) {
        _error = 'Access denied. SuperAdmin role required.';
      } else {
        _error = 'Failed to load report (${response.statusCode}).';
      }
    } catch (e) {
      _error = 'Could not connect to the server.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTrainerDashboard() async {
    _isTrainerLoading = true;
    _trainerError = null;
    notifyListeners();

    try {
      final rawUrl = '${BaseProvider.baseUrl}Dashboard/trainer-dashboard';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _trainerDashboard = TrainerDashboard.fromJson(data);
      } else if (response.statusCode == 401) {
        _trainerError = 'Unauthorized. Please log in again.';
      } else if (response.statusCode == 403) {
        _trainerError = 'Access denied. Administrator role required.';
      } else if (response.statusCode == 404) {
        _trainerError = 'No trainer profile found for your account.';
      } else {
        _trainerError = 'Failed to load dashboard (${response.statusCode}).';
      }
    } catch (e) {
      _trainerError = 'Could not connect to the server.';
    }

    _isTrainerLoading = false;
    notifyListeners();
  }
}

