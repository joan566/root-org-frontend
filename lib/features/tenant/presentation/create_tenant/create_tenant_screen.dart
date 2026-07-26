import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/create_tenant/state/register_tenant_with_owner_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../state/tenant_injection.dart';

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
            return _SuccessWorkspaceView(
              organizationName: nameController.text.trim(),
              invitationCode: generatedCode!,
              onContinue: () => Navigator.pushReplacementNamed(context, "/dashboard"),
            );
          }

          return Row(
            children: [
              if (isDesktop)
                const Expanded(
                  flex: 40,
                  child: _LeftIdentityWorkspacePanel(),
                ),

              Expanded(
                flex: isDesktop ? 60 : 100,
                child: Stack(
                  children: [
                    const _BackgroundAbstractDesign(),
                    Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 48.0 : (isTablet ? 36.0 : 20.0),
                          16,
                          isDesktop ? 48.0 : (isTablet ? 36.0 : 20.0),
                          24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 960),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isDesktop) ...[
                                const _MobileBrandHeader(),
                                const SizedBox(height: 24),
                              ],

                              if (_backendErrorMessage != null) ...[
                                _BackendErrorCard(
                                  message: _backendErrorMessage!,
                                  onClose: () => setState(() => _backendErrorMessage = null),
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
                                            const _WorkspaceFormHeader(),
                                            const SizedBox(height: 24),

                                            const _FieldLabel(label: 'Nombre de la organización'),
                                            const SizedBox(height: 6),
                                            _buildNameField(),
                                            const SizedBox(height: 18),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const _FieldLabel(label: 'Descripción o propósito'),
                                                Text(
                                                  '${descriptionController.text.length}/200',
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            _buildDescriptionField(),
                                            const SizedBox(height: 20),

                                            const _FieldLabel(label: 'Tipo de organización (Opcional)'),
                                            const SizedBox(height: 6),
                                            const _FutureOrganizationTypeSelector(),
                                            const SizedBox(height: 28),

                                            _buildSubmitButton(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (constraints.maxWidth > 800) ...[
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 45,
                                      child: _LiveWorkspacePreviewCard(
                                        name: nameController.text,
                                        description: descriptionController.text,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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

class _SuccessWorkspaceView extends StatelessWidget {
  final String organizationName;
  final String invitationCode;
  final VoidCallback onContinue;

  const _SuccessWorkspaceView({
    required this.organizationName,
    required this.invitationCode,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.premiumShadow(),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('¡Espacio corporativo listo!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('La organización "$organizationName" se ha estructurado con éxito en el backend global.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CÓDIGO DE INVITACIÓN REAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                child: const Text('ACTIVO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  invitationCode,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 2.0),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.textSecondary),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: invitationCode));
                                  HapticFeedback.lightImpact();
                                },
                                tooltip: 'Copiar código',
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Comparte este código con tu equipo de trabajo para permitirles unirse de manera directa.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const _WorkspaceNextStepsChecklist(),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Acceder al Dashboard Principal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveWorkspacePreviewCard extends StatelessWidget {
  final String name;
  final String description;

  const _LiveWorkspacePreviewCard({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.slateDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('VISTA PREVIA EN TIEMPO REAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 36),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name.isEmpty ? 'Nombre de tu Organización' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: name.isEmpty ? Colors.white.withOpacity(0.2) : Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'Sin descripción configurada aún. Comienza a escribir en el panel de control izquierdo para rellenar este espectro informativo.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(description.isEmpty ? 0.25 : 0.6), height: 1.5),
          ),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          _buildPreviewMetaRow(Icons.shield_outlined, 'Rol asignado', 'Administrador Principal (Tú)'),
          const SizedBox(height: 12),
          _buildPreviewMetaRow(Icons.people_alt_outlined, 'Miembros iniciales', '1 miembro operativo'),
          const SizedBox(height: 12),
          _buildPreviewMetaRow(Icons.layers_outlined, 'Módulos base', 'Espera de aprovisionamiento'),
        ],
      ),
    );
  }

  Widget _buildPreviewMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 16),
        const SizedBox(width: 12),
        Text('$label:', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _LeftIdentityWorkspacePanel extends StatelessWidget {
  const _LeftIdentityWorkspacePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slateDark,
      child: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.02, child: CustomPaint(painter: _GridPainter()))),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('SUMKEYA OS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Crea tu primera organización.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text('Las organizaciones actúan como espacios aislados e independientes (multi-tenant) donde podrás gestionar flujos de trabajo, asignar roles e integrar módulos de control.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5)),
                    const SizedBox(height: 32),
                    _buildFeatureRow('Administración centralizada avanzada'),
                    _buildFeatureRow('Miembros con granularidad de roles jerárquicos'),
                    _buildFeatureRow('Aprovisionamiento de módulos bajo demanda'),
                    _buildFeatureRow('Aislamiento lógico estricto de bases de datos'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¿Qué sucede al crear una organización?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildStepSequenceLine('1', 'Estructuración lógica del Tenant en la nube.'),
                      _buildStepSequenceLine('2', 'Auto-asignación de tu perfil como Administrador.'),
                      _buildStepSequenceLine('3', 'Generación automatizada de llaves de invitación compartidas.'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStepSequenceLine(String number, String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(step, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11))),
        ],
      ),
    );
  }
}

class _WorkspaceFormHeader extends StatelessWidget {
  const _WorkspaceFormHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.add_box_outlined, color: AppColors.primary, size: 22),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border)),
              child: const Text('Paso 1 de 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text('Configurar nueva organización', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Configura el perímetro operativo inicial de tu entorno de control.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _WorkspaceNextStepsChecklist extends StatelessWidget {
  const _WorkspaceNextStepsChecklist();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('HOJA DE RUTA OPERATIVA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _buildCheckItem(true, 'Organización aprovisionada en base de datos central.'),
        _buildCheckItem(false, 'Completar parametrización y configuración regional.'),
        _buildCheckItem(false, 'Invitar miembros de confianza vía código hash.'),
        _buildCheckItem(false, 'Encender módulos funcionales y pasarelas de control.'),
      ],
    );
  }

  Widget _buildCheckItem(bool checked, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: checked ? AppColors.primary : AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: checked ? FontWeight.bold : FontWeight.normal, color: checked ? AppColors.textPrimary : AppColors.textSecondary))),
        ],
      ),
    );
  }
}

class _FutureOrganizationTypeSelector extends StatelessWidget {
  const _FutureOrganizationTypeSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const Icon(Icons.layers_clear_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Seleccionar sector (Empresa, Educación, Fundación)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            child: const Text('Próximamente', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          )
        ],
      ),
    );
  }
}

class _BackendErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _BackendErrorCard({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 2.0), child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Excepción de aprovisionamiento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF991B1B)),
            style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }
}

class _MobileBrandHeader extends StatelessWidget {
  const _MobileBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.slateDark, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 14),
        ),
        const SizedBox(width: 8),
        const Text('SUMKEYA OS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.5)),
      ],
    );
  }
}

class _BackgroundAbstractDesign extends StatelessWidget {
  const _BackgroundAbstractDesign();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.02)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    double step = 54.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
