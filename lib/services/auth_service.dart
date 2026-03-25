import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<({String userId, String message})> requestOtp(String phone) async {
    final data = await _client.post(
      '/auth/request-otp',
      body: {'phone': phone},
      auth: false,
    ) as Map<String, dynamic>;
    final uid = data['user_id'] as String? ?? '';
    final msg = data['message'] as String? ?? 'OTP envoyé';
    return (userId: uid, message: msg);
  }

  Future<({String token, User user, bool isNewUser})> verifyOtp({
    required String userId,
    required String code,
  }) async {
    final data = await _client.post(
      '/auth/verify-otp',
      body: {'user_id': userId, 'code': code},
      auth: false,
    ) as Map<String, dynamic>;
    final token = data['token'] as String? ?? '';
    final u = data['user'];
    final user = u is Map<String, dynamic> ? User.fromJson(u) : User(id: userId, phone: null);
    final isNew = data['is_new_user'] == true;
    return (token: token, user: user, isNewUser: isNew);
  }

  Future<User> me() async {
    final data = await _client.get('/auth/me') as Map<String, dynamic>;
    final u = data['user'] ?? data;
    if (u is Map<String, dynamic>) return User.fromJson(u);
    return User(id: '', phone: null);
  }

  Future<void> completeDriverProfile({
    required String fullName,
    required String city,
    required String photo,
    required String identityDocument,
    required String motorcyclePlate,
  }) async {
    await _client.post(
      '/auth/complete-driver-profile',
      body: {
        'full_name': fullName,
        'city': city,
        'photo': photo,
        'identity_document': identityDocument,
        'motorcycle_plate': motorcyclePlate,
      },
    );
  }
}
