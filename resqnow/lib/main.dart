import 'package:flutter/material.dart' hide NotificationListener;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'features/presentation/navigation/app_router.dart';
import 'core/theme/theme_manager.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/condition_categories/data/services/category_service.dart';
import 'features/condition_categories/presentation/controllers/category_controller.dart';
import 'data/datasources/remote/resource_remote_datasource.dart';
import 'data/repositories/resource_repository_impl.dart';
import 'domain/usecases/get_featured_resources.dart';
import 'features/first_aid_resources/presentation/controllers/resource_controller.dart';
import 'features/presentation/controllers/location_controller.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';
import 'features/blood_donor/data/services/blood_bank_service.dart';
import 'data/repositories/blood_bank_repository_impl.dart';
import 'domain/usecases/get_blood_banks_nearby.dart';
import 'features/blood_donor/data/services/blood_donor_service.dart';
import 'data/repositories/blood_donor_repository_impl.dart';
import 'features/hospitals/data/datasources/hospital_remote_datasource.dart';
import 'features/hospitals/data/repositories/hospital_repository_impl.dart';
import 'features/hospitals/domain/repositories/hospital_repository.dart';
import 'features/hospitals/domain/usecases/get_approved_hospitals.dart';
import 'features/hospitals/data/datasources/doctor_remote_datasource.dart';
import 'features/hospitals/data/repositories/doctor_repository_impl.dart';
import 'features/hospitals/domain/repositories/doctor_repository.dart';
import 'features/hospitals/domain/usecases/get_doctors_by_hospital.dart';
import 'features/hospitals/data/datasources/appointment_remote_datasource.dart';
import 'features/hospitals/data/repositories/appointment_repository_impl.dart';
import 'features/hospitals/domain/repositories/appointment_repository.dart';
import 'features/hospitals/domain/usecases/book_appointment.dart';
import 'features/hospitals/domain/usecases/get_hospital_appointments.dart';
import 'features/hospitals/domain/usecases/approve_appointment.dart';
import 'features/hospitals/domain/usecases/reject_appointment.dart';
import 'features/shopping_cart/presentation/controllers/cart_controller.dart';
import 'domain/usecases/register_donor.dart';
import 'domain/usecases/update_donor.dart';
import 'domain/usecases/delete_donor.dart';
import 'domain/usecases/get_my_donor_profile.dart';
import 'domain/usecases/get_donors.dart' as get_donors;
import 'domain/usecases/get_all_donors.dart';
import 'domain/usecases/is_user_donor.dart';
import 'domain/usecases/get_donor_by_id.dart';
import 'features/blood_donor/presentation/controllers/donor_registration_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_profile_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_list_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_details_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/chat/presentation/controllers/chat_controller.dart';
import 'core/services/fcm_service.dart';
import 'features/notifications/presentation/controllers/notification_controller.dart';
import 'features/notifications/presentation/widgets/notification_listener_widget.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeManager();
  await themeManager.initTheme();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
    } else {
      rethrow;
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FCMService().initializeFCM();

  final firestore = FirebaseFirestore.instance;
  final categoryService = CategoryService();
  final resourceRemoteDataSource = ResourceRemoteDataSourceImpl(
    firestore: firestore,
  );
  final resourceRepository = ResourceRepositoryImpl(
    remoteDataSource: resourceRemoteDataSource,
  );
  final getFeaturedResourcesUseCase = GetFeaturedResources(resourceRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => CategoryController(categoryService),
        ),
        ChangeNotifierProvider(
          create: (_) => ResourceController(
            getFeaturedResourcesUseCase: getFeaturedResourcesUseCase,
          ),
        ),
        Provider(
          create: (_) => BloodBankService(
            apiKey: "AIzaSyDZxL1FwXcsvoFFTJ3aHJNNOq3r4Bk_pFs",
          ),
        ),
        Provider(
          create: (context) => BloodBankRepositoryImpl(
            service: context.read<BloodBankService>(),
          ),
        ),
        Provider(
          create: (context) =>
              GetBloodBanksNearby(context.read<BloodBankRepositoryImpl>()),
        ),
        Provider(
          create: (_) => BloodDonorService(
            firestore: firestore,
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider(
          create: (context) => BloodDonorRepositoryImpl(
            service: context.read<BloodDonorService>(),
          ),
        ),
        Provider(
          create: (context) =>
              RegisterDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              UpdateDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetMyDonorProfile(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              DeleteDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) => get_donors.GetDonorsByDistrict(
            context.read<BloodDonorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => get_donors.GetDonorsByTown(
            context.read<BloodDonorRepositoryImpl>(),
          ),
        ),
        Provider<GetAllDonors>(
          lazy: false,
          create: (context) {
            final repository = context.read<BloodDonorRepositoryImpl>();
            return GetAllDonors(repository);
          },
        ),
        Provider(
          create: (context) =>
              IsUserDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetDonorById(context.read<BloodDonorRepositoryImpl>()),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorRegistrationController(
            registerDonorUseCase: context.read<RegisterDonor>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorProfileController(
            getMyDonorProfileUseCase: context.read<GetMyDonorProfile>(),
            updateDonorUseCase: context.read<UpdateDonor>(),
            deleteDonorUseCase: context.read<DeleteDonor>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorListController(
            getDonorsByDistrictUseCase: context
                .read<get_donors.GetDonorsByDistrict>(),
            getDonorsByTownUseCase: context.read<get_donors.GetDonorsByTown>(),
            getAllDonorsUseCase: context.read<GetAllDonors>(),
            locationController: context.read<LocationController>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorDetailsController(
            getDonorByIdUseCase: context.read<GetDonorById>(),
            bloodDonorService: context.read<BloodDonorService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        Provider(create: (_) => HospitalRemoteDatasource()),
        Provider<HospitalRepository>(
          create: (context) => HospitalRepositoryImpl(
            remoteDatasource: context.read<HospitalRemoteDatasource>(),
          ),
        ),
        Provider(
          create: (context) =>
              GetApprovedHospitals(context.read<HospitalRepository>()),
        ),
        Provider<DoctorRemoteDatasource>(
          create: (_) => DoctorRemoteDatasource(),
        ),
        Provider<DoctorRepository>(
          create: (context) => DoctorRepositoryImpl(
            remoteDatasource: context.read<DoctorRemoteDatasource>(),
          ),
        ),
        Provider<GetDoctorsByHospital>(
          create: (context) =>
              GetDoctorsByHospital(context.read<DoctorRepository>()),
        ),
        Provider<AppointmentRemoteDatasource>(
          create: (_) => AppointmentRemoteDatasource(),
        ),
        Provider<AppointmentRepository>(
          create: (context) => AppointmentRepositoryImpl(
            remoteDatasource: context.read<AppointmentRemoteDatasource>(),
          ),
        ),
        Provider<BookAppointment>(
          create: (context) =>
              BookAppointment(context.read<AppointmentRepository>()),
        ),
        Provider<GetHospitalAppointments>(
          create: (context) =>
              GetHospitalAppointments(context.read<AppointmentRepository>()),
        ),
        Provider<ApproveAppointment>(
          create: (context) =>
              ApproveAppointment(context.read<AppointmentRepository>()),
        ),
        Provider<RejectAppointment>(
          create: (context) =>
              RejectAppointment(context.read<AppointmentRepository>()),
        ),
      ],
      child: NotificationListener(child: ResQNowApp()),
    ),
  );
}

class ResQNowApp extends StatefulWidget {
  const ResQNowApp({super.key});

  @override
  State<ResQNowApp> createState() => _ResQNowAppState();
}

class _ResQNowAppState extends State<ResQNowApp> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        final authController = context.read<AuthController>();
        authController.initializeSuspensionMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    router = AppRouter.createRouter(context);

    return MaterialApp.router(
      title: 'ResQNow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      routerConfig: router,
    );
  }
}
