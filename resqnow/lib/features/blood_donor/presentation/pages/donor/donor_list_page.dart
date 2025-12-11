import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_list_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/features/blood_donor/presentation/widgets/donor_card.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorListPage extends StatefulWidget {
  const DonorListPage({super.key});

  @override
  State<DonorListPage> createState() => _DonorListPageState();
}

class _DonorListPageState extends State<DonorListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorListController>().loadDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorListController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Nearby Donors"),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  context.push('/donor/filter');
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  context.watch<LocationController>().locationText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: _buildBody(controller),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(DonorListController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          controller.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (controller.donors.isEmpty) {
      return const Center(child: Text("No donors found nearby"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.donors.length,
      itemBuilder: (context, index) {
        final donor = controller.donors[index];
        return _donorCard(context, donor);
      },
    );
  }

  Widget _donorCard(BuildContext context, BloodDonor donor) {
    return DonorCard(
      donor: donor,
      onTap: () {
        context.push('/donor/details/${donor.id}');
      },
    );
  }
}
