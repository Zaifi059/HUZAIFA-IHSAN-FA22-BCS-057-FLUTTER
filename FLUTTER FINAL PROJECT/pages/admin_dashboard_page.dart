import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_dashboard_service.dart';
import '../widgets/admin_charts.dart';
import '../core/providers/global_refresh_provider.dart';
// Removed file export imports after replacing games list with statistics

/// Provider for admin dashboard service
final adminDashboardServiceProvider = Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

/// Provider for admin dashboard stats
final adminDashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.read(adminDashboardServiceProvider);
  return service.getDashboardStats();
});

/// Provider for admin games with filters
final adminGamesProvider =
    FutureProvider.family<List<AdminGameView>, AdminGameFilters>((
      ref,
      filters,
    ) async {
      final service = ref.read(adminDashboardServiceProvider);
      return service.getAllGames(
        statusFilter: filters.statusFilter,
        creatorFilter: filters.creatorFilter,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
        limit: filters.limit,
        offset: filters.offset,
      );
    });

/// Provider for referee performance
final refereePerformanceProvider = FutureProvider<List<RefereePerformance>>((
  ref,
) async {
  final service = ref.read(adminDashboardServiceProvider);
  return service.getRefereePerformance();
});

/// Provider for user counts (real-time)
final userCountsStreamProvider = StreamProvider<UserCounts>((ref) {
  final service = ref.read(adminDashboardServiceProvider);
  return service.streamUserCounts();
});

/// Provider for user counts (future-based for refresh)
final userCountsProvider = FutureProvider<UserCounts>((ref) async {
  final service = ref.read(adminDashboardServiceProvider);
  return service.getUserCounts();
});

/// Provider for latest real-time user counts
final latestUserCountsProvider = Provider<UserCounts?>((ref) {
  // Try to get from stream first
  final streamAsync = ref.watch(userCountsStreamProvider);
  return streamAsync.whenOrNull(data: (userCounts) => userCounts);
});

/// Admin dashboard page
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdminGameFilters _filters = AdminGameFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    final service = ref.read(adminDashboardServiceProvider);
    final hasAccess = await service.verifyAdminAccess();

    if (!hasAccess && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied: Admin privileges required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch global refresh for real-time sync across all dashboards
    ref.watch(adminProvidersRefreshProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Games', icon: Icon(Icons.sports_soccer)),
            Tab(text: 'Referees', icon: Icon(Icons.people)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _refreshDashboard(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          // Replace full games list with statistics view per requirement
          _buildOverviewTab(),
          _buildRefereesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(adminDashboardStatsProvider);

              return statsAsync.when(
                data: (stats) => _buildStatsCards(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading stats: $error')),
              );
            },
          ),

          const SizedBox(height: 24),

          // Charts Section
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(adminDashboardStatsProvider);

              return statsAsync.when(
                data: (stats) => AdminChartsWidget(stats: stats),
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SizedBox(
                  height: 300,
                  child: Center(child: Text('Error loading charts: $error')),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Real-time User Counts Section
          Text(
            'Real-time User Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final userCountsAsync = ref.watch(userCountsStreamProvider);

              return userCountsAsync.when(
                data: (userCounts) => _buildUserCountsCards(userCounts),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading user counts: $error')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Games',
                stats.gameStats.values
                    .fold(0, (sum, count) => sum + count)
                    .toString(),
                Icons.sports_soccer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Payouts',
                '\$${stats.totalPayouts.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Referees',
                stats.refereeCount.toString(),
                Icons.people,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Recent Activity',
                '${stats.recentActivity} (7 days)',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCountsCards(UserCounts userCounts) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                userCounts.totalUsers.toString(),
                Icons.group,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Referees',
                userCounts.refereeCount.toString(),
                Icons.sports_soccer,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Schedulers',
                userCounts.schedulerCount.toString(),
                Icons.schedule,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Admins',
                userCounts.adminCount.toString(),
                Icons.admin_panel_settings,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              'Last updated: ${userCounts.lastUpdated.toString().substring(0, 19)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  // Removed Games tab implementation – requirement is to show statistics instead of listing games

  // Old games list removed

  // Old card builder removed

  // Status chip removed with games list

  Widget _buildRefereesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final refereesAsync = ref.watch(refereePerformanceProvider);

        return refereesAsync.when(
          data: (referees) => _buildRefereesList(referees),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Error loading referees: $error')),
        );
      },
    );
  }

  Widget _buildRefereesList(List<RefereePerformance> referees) {
    if (referees.isEmpty) {
      return const Center(child: Text('No referees found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: referees.length,
      itemBuilder: (context, index) {
        final referee = referees[index];
        return _buildRefereeCard(referee);
      },
    );
  }

  Widget _buildRefereeCard(RefereePerformance referee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              referee.fullName ?? referee.email,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (referee.fullName != null) ...[
              const SizedBox(height: 4),
              Text(
                referee.email,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        referee.assignedGamesCount.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assigned Games',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        referee.completedGamesCount.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$${referee.totalEarnings.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Earnings',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Export removed with games list

  void _refreshDashboard() {
    // Trigger global refresh to sync all dashboards
    ref.read(globalRefreshProvider.notifier).forceRefresh();

    // Also invalidate specific providers for immediate update
    ref.invalidate(adminDashboardStatsProvider);
    ref.invalidate(adminGamesProvider(_filters));
    ref.invalidate(refereePerformanceProvider);
    ref.invalidate(userCountsProvider);
  }

  // Date format helper removed with games list
}

/// Filters for admin games query
class AdminGameFilters {
  final String? statusFilter;
  final String? creatorFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int limit;
  final int offset;

  AdminGameFilters({
    this.statusFilter,
    this.creatorFilter,
    this.dateFrom,
    this.dateTo,
    this.limit = 50,
    this.offset = 0,
  });

  AdminGameFilters copyWith({
    String? statusFilter,
    String? creatorFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  }) {
    return AdminGameFilters(
      statusFilter: statusFilter ?? this.statusFilter,
      creatorFilter: creatorFilter ?? this.creatorFilter,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
