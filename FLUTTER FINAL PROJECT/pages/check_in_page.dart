import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/checkin_repository.dart';
import '../services/location_service.dart';
import '../features/auth/data/providers/auth_provider.dart';

/// Provider for the CheckInRepository
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository();
});

/// Provider for the current check-in state
final checkInStateProvider =
    StateNotifierProvider<CheckInStateNotifier, CheckInState>((ref) {
  final repository = ref.read(checkInRepositoryProvider);
  return CheckInStateNotifier(repository);
});

/// Check-in page for referees to check in to games
class CheckInPage extends ConsumerStatefulWidget {
  final String gameId;

  const CheckInPage({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _performCheckIn() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location not available. Please refresh location first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current user from auth state
    final authState = ref.read(authStateProvider);
    final user = authState?.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final notifier = ref.read(checkInStateProvider.notifier);
    await notifier.performCheckIn(
      gameId: widget.gameId,
      refereeId: user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Check-In',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Game ID: ${widget.gameId}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _currentPosition != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Location Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingLocation)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting your location...'),
                        ],
                      )
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✓ Location acquired'),
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    else
                      const Text('❌ Location not available'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Check-in Status
            if (checkInState.isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Processing check-in...'),
                    ],
                  ),
                ),
              ),

            if (checkInState.error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checkInState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (checkInState.checkInResult != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Check-in Successful!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payout Transaction: ${checkInState.checkInResult!.payoutTxHash}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Checked in at: ${checkInState.checkInResult!.checkedInAt.toString()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Location'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_currentPosition != null && !checkInState.isLoading)
                            ? _performCheckIn
                            : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// State for check-in operations
class CheckInState {
  final bool isLoading;
  final String? error;
  final CheckInResult? checkInResult;

  CheckInState({
    this.isLoading = false,
    this.error,
    this.checkInResult,
  });

  CheckInState copyWith({
    bool? isLoading,
    String? error,
    CheckInResult? checkInResult,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      checkInResult: checkInResult ?? this.checkInResult,
    );
  }
}

/// State notifier for check-in operations
class CheckInStateNotifier extends StateNotifier<CheckInState> {
  final CheckInRepository _repository;

  CheckInStateNotifier(this._repository) : super(CheckInState());

  Future<void> performCheckIn({
    required String gameId,
    required String refereeId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.recordCheckIn(
        gameId: gameId,
        refereeId: refereeId,
      );

      state = state.copyWith(
        isLoading: false,
        checkInResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = CheckInState();
  }
}
