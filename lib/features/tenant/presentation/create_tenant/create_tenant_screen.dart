import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/create_tenant/state/register_tenant_with_owner_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import '../state/tenant_injection.dart';
import 'widgets/success_workspace_view.dart';
import 'widgets/live_workspace_preview_card.dart';
import 'widgets/workspace_form_header.dart';
import 'widgets/future_organization_type_selector.dart';
import 'package:savings_api_frontend/shared/widgets/backend_error_card.dart';
import 'package:savings_api_frontend/shared/widgets/field_label.dart';
import 'mobile/create_tenant_mobile_view.dart';
import 'desktop/create_tenant_desktop_view.dart';

class CreateTenantScreen extends StatefulWidget {
  const CreateTenantScreen({super.key});

  @override
  State<CreateTenantScreen> createState() => _CreateTenantScreenState();
}

class _CreateTenantScreenState extends State<CreateTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descFocusNode = FocusNode();

  bool loading = false;
  String? generatedCode;
  String? _backendErrorMessage;

  late final RegisterTenantWithOwnerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TenantInjection.registerTenantWithOwnerController();
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _registerWithOwner() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() {
      loading = true;
      _backendErrorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final session = auth.session!;
    final user = session.user;

    try {
      final registerWithOwner = await _controller.registerTenantWithOwner(
        nameController.text.trim(),
        descriptionController.text.trim(),
        user.id,
        session.token,
      );

      user.tenants?.add(registerWithOwner.userTenant);
      session.hasTenant = true;
      auth.refreshSession();

      setState(() {
        generatedCode = registerWithOwner.tenant.code;
      });

      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });

    } catch (e) {
      debugPrint('Register tenant error: $e');
      HapticFeedback.vibrate();
      setState(() {
        _backendErrorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20, top: 4, bottom: 4),
          child: AppBackButton(),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 1050;
          bool isTablet = constraints.maxWidth <= 1050 && constraints.maxWidth > 650;

          if (generatedCode != null) {
            return SuccessWorkspaceView(
              organizationName: nameController.text.trim(),
              invitationCode: generatedCode!,
              onContinue: () => Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
            );
          }

          final double horizontalPadding = isDesktop ? 48.0 : (isTablet ? 36.0 : 20.0);
          final content = _buildContent(showPreview: constraints.maxWidth > 800);

          return isDesktop
              ? CreateTenantDesktopView(horizontalPadding: horizontalPadding, content: content)
              : CreateTenantMobileView(horizontalPadding: horizontalPadding, content: content);
        },
      ),
    );
  }

  Widget _buildContent({required bool showPreview}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_backendErrorMessage != null) ...[
          BackendErrorCard(
            title: 'Excepción de aprovisionamiento',
            message: _backendErrorMessage!,
            onClose: () => setState(() => _backendErrorMessage = null),
            borderOpacity: 0.2,
          ),
          const SizedBox(height: 16),
        ],

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.premiumShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WorkspaceFormHeader(),
                      const SizedBox(height: 24),

                      const FieldLabel(fontWeight: FontWeight.w700, label: 'Nombre de la organización'),
                      const SizedBox(height: 6),
                      _buildNameField(),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FieldLabel(fontWeight: FontWeight.w700, label: 'Descripción o propósito'),
                          Text(
                            '${descriptionController.text.length}/200',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),

                      const FieldLabel(fontWeight: FontWeight.w700, label: 'Tipo de organización (Opcional)'),
                      const SizedBox(height: 6),
                      const FutureOrganizationTypeSelector(),
                      const SizedBox(height: 28),

                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),

            if (showPreview) ...[
              const SizedBox(width: 24),
              Expanded(
                flex: 45,
                child: LiveWorkspacePreviewCard(
                  name: nameController.text,
                  description: descriptionController.text,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      focusNode: _nameFocusNode,
      enabled: !loading,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Ej. Corporación Lambda S.A.',
        helperText: 'Será el identificador visible para todos los futuros miembros.',
        helperStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.business_rounded, size: 18, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: loading ? AppColors.background : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? "El nombre es mandatorio para inicializar el tenant" : null,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descFocusNode),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      focusNode: _descFocusNode,
      enabled: !loading,
      maxLines: 3,
      maxLength: 200,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Describe brevemente el alcance u objetivo de este espacio organizacional...',
        counterText: '',
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: loading ? AppColors.background : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      ),
      onFieldSubmitted: (_) => _registerWithOwner(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: loading ? null : _registerWithOwner,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Preparando espacio de trabajo...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
            ],
          )
              : const Text('Confirmar y Crear Organización', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
