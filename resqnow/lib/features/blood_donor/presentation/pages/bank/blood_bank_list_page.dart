import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/domain/usecases/get_blood_banks_nearby.dart';
import 'package:resqnow/domain/entities/blood_bank.dart'; // added import
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

    /// We initialize LocationController here IF not ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = context.read<LocationController>();

      // If location is not yet fetched, initialize it
      if (location.latitude == null || location.longitude == null) {
        location.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    /// WAIT FOR LOCATION FIRST
    final hasLocation =
        location.latitude != null && location.longitude != null;

    if (!hasLocation) {
      return Scaffold(
        appBar: _BloodBankAppBar(), // removed const to allow Consumer
        body: Center(child: Text("Waiting for location...")),
      );
    }

    /// CREATE CONTROLLER ONLY ONCE AFTER LOCATION IS READY
    controller ??= BloodBankListController(
      getBloodBanksNearby: context.read<GetBloodBanksNearby>(),
      locationController: location,
    );

    // Attach a listener to perform a widened search once if needed
    controller!.removeListener(_onControllerUpdated);
    controller!.addListener(_onControllerUpdated);

    /// LOAD BLOOD BANKS ONLY ONCE
    if (!_loadedOnce) {
      _loadedOnce = true;
      controller!.loadBloodBanks();
    }

    return ChangeNotifierProvider.value(
      value: controller!,
      child: _BloodBankListView(), // removed const to allow rebuilds
    );
  }

  void _onControllerUpdated() {
    final c = controller;
    if (c == null) return;

    // When initial search finishes and found nothing, retry once (controller default radius)
    if (!_widenedSearchOnce && !c.isLoading && c.bloodBanks.isEmpty) {
      _widenedSearchOnce = true;
      c.loadBloodBanks(); // removed unsupported radiusKm
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
    // 20km = 20000 meters
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
      appBar: const _BloodBankAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location banner below AppBar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Icon(Icons.location_on,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main content
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.error != null
                    ? Center(child: Text("Error: ${controller.error}"))
                    : controller.bloodBanks.isEmpty
                        ? FutureBuilder<List<BloodBank>>(
                            future: _fetchFallbackBanks(context),
                            builder: (_, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text("No blood banks found nearby."),
                                );
                              }
                              final fallbackBanks = snapshot.data ?? [];
                              if (fallbackBanks.isEmpty) {
                                return const Center(
                                  child: Text("No blood banks found within 20km."),
                                );
                              }
                              return ListView.builder(
                                itemCount: fallbackBanks.length,
                                itemBuilder: (_, index) {
                                  final bank = fallbackBanks[index];
                                  return BloodBankCard(bank: bank);
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: controller.bloodBanks.length,
                            itemBuilder: (_, index) {
                              final bank = controller.bloodBanks[index];
                              return BloodBankCard(bank: bank);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _BloodBankAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _BloodBankAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Nearby Blood Banks"),
      actions: [
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BloodBankMapPage()),
            );
          },
        ),
      ],
    );
  }
}
