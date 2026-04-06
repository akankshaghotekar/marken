import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:marken/helper/api/api_service.dart';
import 'package:marken/helper/shared_pref/app_pref.dart';
import 'package:marken/screens/attendance/attendance_report_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/battery_optimization_helper.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isPunchedIn = false;

  late AnimationController _rotationController;

  String? _usersrno;
  String? _employeesrno;
  String? _employeeType;

  double? _lat;
  double? _lng;
  double? _lastValidLat;
  double? _lastValidLng;

  bool _isApiCalling = false;
  bool isDayCompleted = false;

  String? punchInTime;
  String? punchOutTime;

  Timer? _locationTimer;
  File? _capturedImage;

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  double _getSafeLat() {
    if (_lat != null && _lat != 0.0) return _lat!;
    return _lastValidLat ?? 0.0;
  }

  double _getSafeLng() {
    if (_lng != null && _lng != 0.0) return _lng!;
    return _lastValidLng ?? 0.0;
  }

  bool _isValidLocation() => _getSafeLat() != 0.0 && _getSafeLng() != 0.0;

  bool get _isOnsite => (_employeeType ?? '').toUpperCase().trim() == 'ONSITE';

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadUserData();
    _ensureLocationAccess();
    _fetchLocation();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchLocation(),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // DATA LOADING
  // ─────────────────────────────────────────────

  Future<void> _loadUserData() async {
    final user = await AppPref.getUserSrNo();
    final emp = await AppPref.getEmployeeSrNo();
    final type = await AppPref.getEmployeeType();

    setState(() {
      _usersrno = user;
      _employeesrno = emp;
      _employeeType = type;
    });

    await _fetchPunchStatus();
  }

  Future<void> _fetchPunchStatus() async {
    if (_usersrno == null || _employeesrno == null) return;

    final res = await ApiService.getAttendanceStatus(
      usersrno: _usersrno!,
      employeesrno: _employeesrno!,
    );

    if (res['status'] == 0) {
      final status = (res['punch_status'] ?? "").toString().toLowerCase();
      final inTime = res['punch_in_time'] ?? "";
      final outTime = res['punch_out_time'] ?? "";

      if (!mounted) return;
      setState(() {
        punchInTime = inTime.isNotEmpty ? _formatTime(inTime) : null;
        punchOutTime = outTime.isNotEmpty ? _formatTime(outTime) : null;

        if (status == "punch in") {
          isPunchedIn = false;
          isDayCompleted = false;
        } else if (status == "punch out") {
          isPunchedIn = true;
          isDayCompleted = false;
        } else if (status.contains("attendance")) {
          isPunchedIn = false;
          isDayCompleted = true;
        }
      });
    }
  }

  String _formatTime(String dateTime) {
    try {
      final parsed = DateFormat("dd-MMM-yyyy HH:mm:ss").parse(dateTime);
      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return "--:--";
    }
  }

  // ─────────────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────────────

  Future<void> _ensureLocationAccess() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text("Enable location permission in app settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _lastValidLat = pos.latitude;
        _lastValidLng = pos.longitude;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lat = 0.0;
        _lng = 0.0;
      });
    }
  }

  void _showInvalidLocationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Error"),
        content: const Text("Please wait for GPS to get a fix and try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // IMAGE
  // ─────────────────────────────────────────────

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    final target = path.join(
      dir.path,
      "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      target,
      quality: 40,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  // ─────────────────────────────────────────────
  // PUNCH HANDLERS
  // ─────────────────────────────────────────────

  void _onPunchTap() async {
    if (isPunchedIn) {
      await _handlePunchOut();
    } else {
      await _handlePunchIn();
    }
  }

  Future<void> _handlePunchIn() async {
    if (isPunchedIn) return;
    if (!_isValidLocation()) {
      _showInvalidLocationDialog();
      return;
    }

    final picker = ImagePicker();

    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 60,
    );

    if (photo == null) return;

    // Show confirmation dialog with preview
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Punch In"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(photo.path), height: 250, fit: BoxFit.cover),
            const SizedBox(height: 12),
            const Text("Do you want to confirm this punch in?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Retake"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryBlue,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // User tapped Retake — loop back
    if (confirm == false) {
      return _handlePunchIn();
    }

    if (confirm != true) return;

    final compressed = await _compressImage(File(photo.path));
    _capturedImage = compressed;

    await _handlePunch("IN", imageFile: _capturedImage);
  }

  Future<void> _handlePunchOut() async {
    if (!isPunchedIn) return;
    if (!_isValidLocation()) {
      _showInvalidLocationDialog();
      return;
    }

    await _handlePunch("OUT");
  }

  Future<void> _handlePunch(String type, {File? imageFile}) async {
    if (_isApiCalling || _usersrno == null || _employeesrno == null) return;

    setState(() => _isApiCalling = true);
    _rotationController.repeat();

    try {
      final res = await ApiService.markAttendance(
        usersrno: _usersrno!,
        employeesrno: _employeesrno!,
        billDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        inOut: type,
        imgFile: imageFile,
        lat: _getSafeLat().toString(),
        lng: _getSafeLng().toString(),
      );

      if (!mounted) return;

      if (res['status'] == 0) {
        // Update UI immediately
        final currentTime = DateFormat('hh:mm a').format(DateTime.now());
        setState(() {
          if (type == 'IN') {
            isPunchedIn = true;
            isDayCompleted = false;
            punchInTime = currentTime;
            punchOutTime = null;
          } else {
            isPunchedIn = false;
            punchOutTime = currentTime;
          }
        });

        // ONSITE: start / stop background tracking
        if (_isOnsite) {
          if (type == 'IN') {
            final service = FlutterBackgroundService();
            await service.startService();
            await Future.delayed(const Duration(seconds: 1));
            service.invoke('startTracking');

            // Prompt battery optimisation after punch in
            _checkBatteryOptimizationAfterPunchIn();
          } else {
            FlutterBackgroundService().invoke('stopTracking');
          }
        }

        await _fetchPunchStatus(); // refresh from server

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$type successful")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? "Failed to mark attendance"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Submit punch error: $e');
    } finally {
      if (mounted) {
        _rotationController.stop();
        setState(() => _isApiCalling = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  // BATTERY OPTIMISATION (ONSITE only)
  // ─────────────────────────────────────────────

  Future<void> _checkBatteryOptimizationAfterPunchIn() async {
    final isIgnored = await BatteryOptimizationHelper.isIgnored();
    if (isIgnored) return;

    final brand = await BatteryOptimizationHelper.getBrand();

    String extra = '';
    if (brand.contains('vivo')) {
      extra = '\n\nVivo: Battery → App battery management → No restrictions';
    } else if (brand.contains('realme')) {
      extra =
          '\n\nRealme: Battery → App battery usage → Allow background activity';
    } else if (brand.contains('xiaomi') || brand.contains('redmi')) {
      extra = '\n\nRedmi: Battery saver → No restrictions + Enable Autostart';
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Allow Background Tracking'),
        content: Text(
          'To track your location continuously during working hours, '
          'please allow Battery Usage as "No restrictions".'
          '$extra',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await BatteryOptimizationHelper.request();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        showNotification: true,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Text(
            "Mark Attendance",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.primaryBlue,
            ),
          ),

          SizedBox(height: 80.h),

          // ── PUNCH CIRCLE ──
          if (isDayCompleted)
            Text(
              "Attendance Marked for the Day",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isPunchedIn
                  ? Opacity(
                      opacity: _isApiCalling ? 0.6 : 1.0,
                      child: GestureDetector(
                        key: const ValueKey("OUT"),
                        onTap: _isApiCalling ? null : _onPunchTap,
                        child: _PunchCircle(
                          label: _isApiCalling
                              ? "PUNCHING\nOUT..."
                              : "PUNCH\nOUT",
                          iconColor: Colors.green,
                          borderColor: AppColor.primaryBlue,
                          rotation: _rotationController,
                          isLoading: _isApiCalling,
                        ),
                      ),
                    )
                  : Opacity(
                      opacity: _isApiCalling ? 0.6 : 1.0,
                      child: GestureDetector(
                        key: const ValueKey("IN"),
                        onTap: _isApiCalling ? null : _onPunchTap,
                        child: _PunchCircle(
                          label: _isApiCalling
                              ? "PUNCHING\nIN..."
                              : "PUNCH\nIN",
                          iconColor: Colors.red,
                          borderColor: AppColor.primaryBlue,
                          rotation: _rotationController,
                          isLoading: _isApiCalling,
                        ),
                      ),
                    ),
            ),

          SizedBox(height: 80.h),

          // ── TIME INFO ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo(punchInTime ?? "--:--", "Punch In"),
                _timeInfo(punchOutTime ?? "--:--", "Punch Out"),
              ],
            ),
          ),

          // Show GPS coords only for ONSITE (useful for debugging)
          SizedBox(height: 8.h),
          Text(
            "Lat: ${_lat?.toStringAsFixed(6) ?? '0.00'}",
            style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
          ),
          Text(
            "Lng: ${_lng?.toStringAsFixed(6) ?? '0.00'}",
            style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
          ),

          const Spacer(),

          // ── VIEW REPORT BUTTON ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 35.h),
            child: SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    AnimatedPageRoute(page: AttendanceReportScreen()),
                  );
                },
                child: const Text(
                  "View Attendance Report",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25.h),
        ],
      ),
    );
  }

  Widget _timeInfo(String time, String label) {
    return Column(
      children: [
        Icon(Icons.access_time, color: AppColor.primaryBlue, size: 22.sp),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColor.grey),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUNCH CIRCLE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _PunchCircle extends StatelessWidget {
  final String label;
  final Color iconColor;
  final Color borderColor;
  final AnimationController? rotation;
  final bool isLoading;

  const _PunchCircle({
    super.key,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    this.rotation,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RotationTransition(
          turns: rotation ?? const AlwaysStoppedAnimation(0),
          child: Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 6.w),
            ),
          ),
        ),
        Container(
          width: 130.w,
          height: 130.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 4.w),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? CircularProgressIndicator(color: iconColor)
                  : Icon(Icons.touch_app, color: iconColor, size: 32.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
