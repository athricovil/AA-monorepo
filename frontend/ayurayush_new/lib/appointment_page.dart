import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'styles.dart';
import 'app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTime;
  
  final _notesController = TextEditingController();
  String? _selectedDoctor;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Map<String, dynamic>> _availableDoctors = [];
  List<Map<String, dynamic>> _userOrders = [];
  List<Map<String, dynamic>> _userAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadUserOrders();
    _loadUserAppointments();
  }

  Future<void> _loadDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/doctors'),
        headers: {'Authorization': 'Bearer ${await UserSession.getToken()}'}
      );
      
      if (response.statusCode == 200) {
        final doctors = json.decode(response.body) as List;
        setState(() {
          _availableDoctors = doctors.map((d) => {
            'id': d['id'],
            'name': d['name'],
            'specialization': d['specialization'],
            'experience': d['experience'],
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading doctors: $e');
    }
  }

  Future<void> _loadUserOrders() async {
    try {
      final userId = await UserSession.getUserId();
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/orders/user/$userId'),
        headers: {'Authorization': 'Bearer ${await UserSession.getToken()}'}
      );
      
      if (response.statusCode == 200) {
        final orders = json.decode(response.body) as List;
        setState(() {
          _userOrders = orders.where((order) => 
            order['status'] == 'COMPLETED' || order['status'] == 'CONFIRMED'
          ).toList();
        });
      }
    } catch (e) {
      print('Error loading user orders: $e');
    }
  }

  Future<void> _loadUserAppointments() async {
    try {
      final userId = await UserSession.getUserId();
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/appointments/user/$userId'),
        headers: {'Authorization': 'Bearer ${await UserSession.getToken()}'}
      );
      
      if (response.statusCode == 200) {
        final appointments = json.decode(response.body) as List;
        setState(() {
          _userAppointments = appointments;
        });
      }
    } catch (e) {
      print('Error loading user appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryButtonColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Credits
            _buildCreditsSection(),
            SizedBox(height: 24),
            
            // Calendar
            _buildCalendarSection(),
            SizedBox(height: 24),
            
            // Time Slots
            if (_selectedDay != null) _buildTimeSlotsSection(),
            SizedBox(height: 24),
            
            // Doctor Selection
            _buildDoctorSelection(),
            SizedBox(height: 24),
            
            // Notes
            _buildNotesSection(),
            SizedBox(height: 24),
            
            // Schedule Button
            _buildScheduleButton(),
            SizedBox(height: 24),
            
            // Existing Appointments
            _buildExistingAppointments(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsSection() {
    int totalCredits = _userOrders.length * 15; // 15 minutes per product
    int usedCredits = _userAppointments.fold(0, (sum, apt) => sum + (apt['durationMinutes'] ?? 15));
    int remainingCredits = totalCredits - usedCredits;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment Credits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Credits:'),
                Text('$totalCredits minutes'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used Credits:'),
                Text('$usedCredits minutes'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remaining Credits:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$remainingCredits minutes', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (remainingCredits <= 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You have used all your appointment credits. Purchase more products to get additional credits.',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 90)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedTime = null;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: kPrimaryButtonColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: kPrimaryButtonColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    final timeSlots = [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
      '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
      '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM'
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                final isSelected = _selectedTime != null && 
                    DateFormat('hh:mm a').format(_selectedTime!) == time;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTime = DateFormat('hh:mm a').parse(time);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryButtonColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Doctor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (_availableDoctors.isEmpty)
              Text('No doctors available', style: TextStyle(color: Colors.grey))
            else
              DropdownButtonFormField<String>(
                value: _selectedDoctor,
                decoration: InputDecoration(
                  labelText: 'Choose a doctor',
                  border: OutlineInputBorder(),
                ),
                items: _availableDoctors.map((doctor) => DropdownMenuItem(
                  value: doctor['id'].toString(),
                  child: Text('${doctor['name']} - ${doctor['specialization']}'),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctor = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Additional Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Any specific concerns or questions?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    final canSchedule = _selectedDay != null && 
                       _selectedTime != null && 
                       _selectedDoctor != null &&
                       !_isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSchedule ? _scheduleAppointment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryButtonColor,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading 
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Schedule Appointment', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget _buildExistingAppointments() {
    if (_userAppointments.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ..._userAppointments.map((appointment) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(DateTime.parse(appointment['appointmentDate'])),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('Time: ${DateFormat('hh:mm a').format(DateTime.parse(appointment['appointmentDate']))}'),
                    Text('Duration: ${appointment['durationMinutes']} minutes'),
                    if (appointment['notes']?.isNotEmpty == true)
                      Text('Notes: ${appointment['notes']}'),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'RESCHEDULED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _scheduleAppointment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Combine date and time
      final appointmentDateTime = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointmentRequest = {
        'userId': userId,
        'appointmentDate': appointmentDateTime.toIso8601String(),
        'durationMinutes': 15,
        'notes': _notesController.text,
        'doctorId': int.parse(_selectedDoctor!),
      };

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/appointments/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await UserSession.getToken()}'
        },
        body: json.encode(appointmentRequest),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to schedule appointment: ${response.body}');
      }

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Appointment Scheduled!'),
            content: Text('Your appointment has been scheduled successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadUserAppointments(); // Refresh appointments
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }

      // Reset form
      setState(() {
        _selectedDay = null;
        _selectedTime = null;
        _selectedDoctor = null;
        _notesController.clear();
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
