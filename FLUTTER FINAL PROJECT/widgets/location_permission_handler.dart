import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// Widget that handles location permission requests with user-friendly dialogs
class LocationPermissionHandler {
  static final LocationService _locationService = LocationService();

  /// Show permission request dialog and handle the result
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final result = await _locationService.requestLocationPermission();

    if (result.isGranted) {
      return true;
    }

    if (!context.mounted) return false;

    // Show error dialog with appropriate action
    return await _showPermissionDialog(context, result);
  }

  /// Get current location with user-friendly error handling
  /// Returns LocationResult with position or error details
  static Future<LocationResult> getCurrentLocation(BuildContext context) async {
    final result = await _locationService.getCurrentPosition();

    if (result.position != null) {
      return result;
    }

    if (!context.mounted) return result;

    // Show error dialog
    await _showLocationErrorDialog(context, result);
    return result;
  }

  /// Show permission denial dialog with options
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    LocationPermissionResult result,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.location_off, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Location Permission Required'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location access is required to check in.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please allow location permissions and try again.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                // Wrap actions to avoid overflow/overlap on small screens
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                final newResult = await _locationService
                                    .requestLocationPermission();
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(newResult.isGranted);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (result.canOpenSettings) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              await _locationService.openAppSettings();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Settings',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show location error dialog
  static Future<void> _showLocationErrorDialog(
    BuildContext context,
    LocationResult result,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Error'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to access your location.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Please allow location permissions and try again.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (result.canOpenSettings) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _locationService.openLocationSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Check location permission status with visual feedback
  static Future<bool> checkLocationPermissionWithFeedback(
      BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking location permissions...'),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await _locationService.requestLocationPermission();

    if (context.mounted) {
      Navigator.of(context).pop(); // Remove loading dialog
    }

    if (!result.isGranted && context.mounted) {
      await _showPermissionDialog(context, result);
    }

    return result.isGranted;
  }

  /// Show location validation result with appropriate feedback
  static Future<LocationValidationResult> validateLocationWithFeedback(
    BuildContext context, {
    required double targetLat,
    required double targetLng,
    required double radiusMeters,
  }) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting your location...'),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await _locationService.isWithinRadius(
      targetLat: targetLat,
      targetLng: targetLng,
      radiusMeters: radiusMeters,
    );

    if (context.mounted) {
      Navigator.of(context).pop(); // Remove loading dialog
    }

    // Show result feedback
    if (context.mounted && result.error != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Check Failed'),
            ],
          ),
          content: Text(result.error!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (result.canOpenSettings)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _locationService.openAppSettings();
                },
                child: const Text('Settings'),
              ),
          ],
        ),
      );
    }

    return result;
  }
}
