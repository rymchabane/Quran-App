import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      bool supported = await auth.isDeviceSupported();
      List<BiometricType> available = await auth.getAvailableBiometrics();
      return supported && available.isNotEmpty;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> isDeviceSupported() async {
    return await auth.isDeviceSupported();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Scan your fingerprint',
        biometricOnly: true,
      );
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}