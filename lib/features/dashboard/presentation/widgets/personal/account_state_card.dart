import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

import '../../../../auth/presentation/provider/auth_provider.dart';



class AccountStateCard extends StatelessWidget {
  const AccountStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuchar los datos reales del usuario
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;

    // 2. Extraer datos del usuario de forma segura
    final String email = currentUser?.email ?? 'No disponible';
    final String phone = currentUser?.phoneNumber ?? 'No disponible';

    // Evaluar estado del correo electrónico
    final bool isEmailVerified = currentUser?.status.toUpperCase() == 'VERIFIED' ||
        currentUser?.status.toUpperCase() == 'ACTIVE';

    // Formatear el teléfono de forma segura (ej: +57 300 •••• 67)
    final String maskedPhone = _maskPhoneNumber(phone);

    // Formatear el correo de forma segura (ej: joan••••@dominio.com)
    final String maskedEmail = _maskEmail(email);

    // Obtener idioma y zona horaria del dispositivo de forma real
    final String deviceCountry = Localizations.localeOf(context).countryCode ?? 'CO';
    final String timeZoneOffset = DateTime.now().timeZoneOffset.isNegative
        ? "GMT${DateTime.now().timeZoneOffset.inHours}"
        : "GMT+${DateTime.now().timeZoneOffset.inHours}";

    // Simular sincronización aproximada basándonos en 'updatedAt' o la hora actual
    final String syncStatus = currentUser?.updatedAt != null
        ? 'Hace un momento'
        : 'Activa';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de la cuenta',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          _buildStateRow('Correo electrónico', maskedEmail, isEmailVerified),
          _buildStateRow('Teléfono vinculado', maskedPhone, phone != 'No disponible'),
          _buildStateRow('Estado del perfil', _translateProfileStatus(currentUser?.profileStatus), currentUser?.profileStatus == 'COMPLETED'),
          _buildStateRow('Sincronización cloud', syncStatus, true),
          _buildStateRow('Idioma de entorno', 'Español ($deviceCountry)', false),
          _buildStateRow('Zona horaria', timeZoneOffset, false),
        ],
      ),
    );
  }

  Widget _buildStateRow(String label, String value, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Row(
            children: [
              if (isSuccess)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES DE FORMATEO ---

  // Método para enmascarar correos electrónicos (ej: joan.sebastian@dominio.com -> joan••••@dominio.com)
  String _maskEmail(String email) {
    if (email == 'No disponible' || !email.contains('@')) return email;

    final List<String> parts = email.split('@');
    final String localPart = parts[0];
    final String domainPart = parts[1];

    // Si el nombre del correo es muy corto (ej: j@abc.com o jo@abc.com), no enmascaramos de más
    if (localPart.length <= 3) {
      return '${localPart[0]}••@$domainPart';
    }

    // De lo contrario, dejamos los primeros 3 o 4 caracteres legibles y el resto en puntos
    final String visible = localPart.substring(0, 3);
    return '$visible••••@$domainPart';
  }

  // Método para enmascarar números de teléfono (ej: +57 300 •••• 67)
  String _maskPhoneNumber(String phone) {
    if (phone == 'No disponible' || phone.length < 4) return phone;
    final String suffix = phone.substring(phone.length - 2);
    final String prefix = phone.substring(0, phone.length - 6);
    return '$prefix •••• $suffix';
  }

  // Traducción visual del estado del perfil
  String _translateProfileStatus(String? status) {
    if (status == null) return 'Incompleto';
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Completo';
      case 'PENDING':
        return 'Pendiente';
      default:
        return 'Incompleto';
    }
  }
}