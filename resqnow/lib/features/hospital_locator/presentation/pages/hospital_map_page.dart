import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/map_constants.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../controllers/hospital_locator_controller.dart';
import '../widgets/hospital_card.dart';

class HospitalMapPage extends StatelessWidget {
  const HospitalMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HospitalLocatorController()..init(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<HospitalLocatorController>(
          builder: (context, controller, _) {
            return Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: MapConstants.defaultCameraPosition,
                  markers: controller.markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController mapController) {
                    controller.onMapCreated(mapController);
                  },
                ),

                // Floating hospital card (only if selected)
                if (controller.selectedHospital != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: UIConstants.screenPadding,
                      ),
                      child: HospitalCard(
                        hospital: controller.selectedHospital!,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
