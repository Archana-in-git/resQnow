import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/domain/usecases/get_blood_banks_nearby.dart';
import 'package:resqnow/domain/entities/blood_bank.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/blood_bank_list_controller.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/bank/blood_bank_map_page.dart';
import 'package:resqnow/features/blood_donor/presentation/widgets/blood_bank_card.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class BloodBankListPage extends StatefulWidget {
  const BloodBankListPage({super.key});

  @override
  State<BloodBankListPage> createState() => _BloodBankListPageState();
}

class _BloodBankListPageState extends State<BloodBankListPage> {
  BloodBankListController? controller;
  bool _loadedOnce = false;
  bool _widenedSearchOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = context.read<LocationController>();

      if (location.latitude == null || location.longitude == null) {
        location.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    final hasLocation = location.latitude != null && location.longitude != null;

    if (!hasLocation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Blood Banks'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                "Fetching your location...",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    controller ??= BloodBankListController(
      getBloodBanksNearby: context.read<GetBloodBanksNearby>(),
      locationController: location,
    );

    controller!.removeListener(_onControllerUpdated);
    controller!.addListener(_onControllerUpdated);

    if (!_loadedOnce) {
      _loadedOnce = true;
      controller!.loadBloodBanks();
    }

    return ChangeNotifierProvider.value(
      value: controller!,
      child: const _BloodBankListView(),
    );
  }

  void _onControllerUpdated() {
    final c = controller;
    if (c == null) return;

    if (!_widenedSearchOnce && !c.isLoading && c.bloodBanks.isEmpty) {
      _widenedSearchOnce = true;
      c.loadBloodBanks();
    }
  }
}

class _BloodBankListView extends StatelessWidget {
  const _BloodBankListView();

  Future<List<BloodBank>> _fetchFallbackBanks(BuildContext context) async {
    final usecase = context.read<GetBloodBanksNearby>();
    final loc = context.read<LocationController>();
    final lat = loc.latitude!;
    final lon = loc.longitude!;
    return await usecase.call(
      latitude: lat,
      longitude: lon,
      radiusInMeters: 20000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BloodBankListController>();
    final locationLabel = context.watch<LocationController>().locationText;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          controller.loadBloodBanks();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Results Header
              if (!controller.isLoading && controller.error == null)
                _buildResultsHeader(controller, locationLabel),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: controller.isLoading
                    ? _buildLoadingState()
                    : controller.error != null
                    ? _buildErrorState(controller.error!)
                    : controller.bloodBanks.isEmpty
                    ? _buildEmptyState(context)
                    : _buildListView(controller.bloodBanks),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(
    BloodBankListController controller,
    String locationLabel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Location Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT LOCATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locationLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Blood Banks Count Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Found ${controller.bloodBanks.length} Blood Bank${controller.bloodBanks.length != 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tap any card to get directions and donate blood",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Finding nearby blood banks...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This may take a moment",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.accent,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Unable to Load",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return FutureBuilder<List<BloodBank>>(
      future: _fetchFallbackBanks(context),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Expanding search radius...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search_off_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Blood Banks Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No blood banks available within 20km",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final fallbackBanks = snapshot.data ?? [];
        if (fallbackBanks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search_off_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Results in Your Area",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Try using the map view to explore nearby areas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildListView(fallbackBanks);
      },
    );
  }

  Widget _buildListView(List<BloodBank> banks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banks.length,
      itemBuilder: (_, index) {
        final bank = banks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BloodBankCard(bank: bank),
        );
      },
    );
  }
}
