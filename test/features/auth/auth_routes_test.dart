import 'package:RootOrg/core/routing/app_router.dart';
import 'package:RootOrg/core/routing/route_names.dart';
import 'package:RootOrg/core/design_system/themes/app_theme.dart';
import 'package:RootOrg/features/auth/domain/entities/app_user.dart';
import 'package:RootOrg/features/auth/domain/entities/auth_session.dart';
import 'package:RootOrg/features/auth/domain/repositories/auth_repository.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_password.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/register_user.dart';
import 'package:RootOrg/features/auth/domain/usecases/restore_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/sign_in.dart';
import 'package:RootOrg/features/auth/domain/usecases/verify_email.dart';
import 'package:RootOrg/features/auth/presentation/routes/auth_routes.dart';
import 'package:RootOrg/features/auth/presentation/state/auth_controller.dart';
import 'package:RootOrg/features/auth/presentation/widgets/auth_entry_layout.dart';
import 'package:RootOrg/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login route adapts to mobile and desktop widths', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(find.text('Verificar mi correo'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);
    expect(find.text('Próximamente'), findsOneWidget);
    final googleButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Próximamente'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(googleButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthFeedbackBanner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AuthFeedbackBanner),
        matching: find.text('Ingresa tu correo electrónico.'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(
      find.text('Credenciales incorrectas o correo sin verificar.'),
      findsOneWidget,
    );
    expect(find.byType(AuthFeedbackBanner), findsOneWidget);
    expect(
      tester
          .widgetList<InputDecorator>(find.byType(InputDecorator))
          .first
          .decoration
          .errorText,
      '',
    );
    expect(
      tester
          .widgetList<InputDecorator>(find.byType(InputDecorator))
          .last
          .decoration
          .errorText,
      '',
    );
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(768, 1024));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpAndSettle();
    expect(find.text('Gestiona tu operación con claridad.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.tap(find.byType(TextFormField).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
  });

  testWidgets('registration shows feedback and adapts to all screen sizes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/register');
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(
      find.text('Organiza tu negocio. Crece con claridad.'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);
    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    expect(find.text('Organiza tu negocio. Crece con claridad.'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthFeedbackBanner), findsOneWidget);
    expect(find.text('Ingresa tu nombre.'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(768, 1024));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration success appears before email verification', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/register');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Doe');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'alex@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'Password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'Password123');
    final createAccountButton = find.widgetWithText(
      FilledButton,
      'Crear cuenta',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.pumpAndSettle();
    await tester.tap(createAccountButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.text('Cuenta creada. Ahora confirma tu correo electrónico.'),
      findsOneWidget,
    );
    expect(find.byType(AuthFeedbackBanner), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      '/auth/email-verification',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unverified login is redirected to email verification', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: false,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      '/auth/email-verification',
    );
    expect(
      router
          .router
          .routerDelegate
          .currentConfiguration
          .uri
          .queryParameters['email'],
      'owner@example.com',
    );
    expect(find.text('Verifica tu correo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verified login proceeds to the authenticated route', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: true,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(router.router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(find.text('Inicio'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Existencias').last);
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      RouteNames.stocks,
    );
    expect(find.text('Existencias'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authenticated desktop shell opens sidebar destinations', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: true,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.restore();
    await controller.signIn(
      email: 'owner@example.com',
      password: 'Password123',
    );

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    expect(
      MediaQuery.sizeOf(tester.element(find.byType(MainShellScreen))).width,
      1280,
    );
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Existencias'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Organizaciones'), findsOneWidget);

    await tester.tap(find.text('Reservas'));
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      RouteNames.reservations,
    );
    expect(find.text('Reservas'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back from reservation returns to operations, then home', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: true,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.signIn(
      email: 'owner@example.com',
      password: 'Password123',
    );

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Operaciones').last);
    await tester.pumpAndSettle();
    expect(find.text('Conteos'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Reservas'));
    await tester.pumpAndSettle();
    expect(find.text('Reservas'), findsOneWidget);
    expect(router.router.canPop(), isTrue);

    router.router.pop();
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      RouteNames.operations,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      RouteNames.home,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('email verification uses six side-by-side digit fields', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();
    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/email-verification?email=owner%40example.com');
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(6));
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.controller!.text)
          .join(),
      '123456',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('resend button dispatches the verification request', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAuthRepository();
    final controller = _createController(repository);
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/email-verification?email=owner%40example.com');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Reenviar código'));
    await tester.tap(find.text('Reenviar código'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(repository.verificationRequestCount, 1);
    expect(repository.requestedVerificationEmail, 'owner@example.com');
    expect(find.text('Código enviado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verification back button signs out and returns to login', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: false,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.signIn(
      email: 'owner@example.com',
      password: 'Password123',
    );

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      AuthRoutes.emailVerification,
    );
    await tester.tap(find.text('Volver al inicio de sesión'));
    await tester.pumpAndSettle();

    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      AuthRoutes.signIn,
    );
    expect(controller.status, AuthStatus.unauthenticated);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verified signed-in user continues home from the result dialog', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = AuthSession(
      user: const AppUser(
        id: 42,
        email: 'owner@example.com',
        emailVerified: false,
        organizationUnitMemberships: [],
      ),
      hasOrganizationUnit: false,
      accessTokenExpiresAt: DateTime.utc(2027),
    );
    final controller = _createController(
      _FakeAuthRepository(loginSession: session),
    );
    addTearDown(controller.dispose);
    await controller.signIn(
      email: 'owner@example.com',
      password: 'Password123',
    );

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      '/auth/email-verification',
    );

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verificar correo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('¡Correo verificado!'), findsOneWidget);
    expect(find.text('Ir a la página principal'), findsOneWidget);
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      '/auth/email-verification',
    );

    await tester.tap(find.text('Ir a la página principal'));
    await tester.pumpAndSettle();

    expect(router.router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(find.text('Inicio'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verification errors appear in a result dialog', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController(
      _FakeAuthRepository(verificationError: StateError('invalid code')),
    );
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/email-verification?email=owner%40example.com');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verificar correo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No se pudo verificar el correo'), findsOneWidget);
    expect(
      find.text('No se pudo verificar el correo. Inténtalo nuevamente.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendido'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(TextField), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('newly registered user returns to sign in from success dialog', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
    router.router.go('/auth/email-verification?email=owner%40example.com');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verificar correo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Volver al inicio de sesión'), findsWidgets);
    await tester.tap(find.text('Volver al inicio de sesión').last);
    await tester.pumpAndSettle();

    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      '/auth/sign-in',
    );
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset-password deep link accepts and scrubs its token', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.router));
    await tester.pumpAndSettle();
    router.router.go('/auth/reset-password?resetToken=one-time-token');
    await tester.pumpAndSettle();

    expect(find.text('Nueva contraseña'), findsOneWidget);
    expect(
      router.router.routerDelegate.currentConfiguration.uri.queryParameters
          .containsKey('resetToken'),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}

AppRouter _createRouter(AuthController controller) {
  return AppRouter(
    routes: AuthRoutes.build(controller),
    refreshListenable: controller,
    redirect: controller.redirect,
  );
}

AuthController _createController([AuthRepository? repository]) {
  repository ??= _FakeAuthRepository();
  return AuthController(
    signIn: SignIn(repository),
    registerUser: RegisterUser(repository),
    sendEmailVerificationCode: SendEmailVerificationCode(repository),
    confirmEmailVerification: ConfirmEmailVerification(repository),
    restoreSession: RestoreSession(repository),
    refreshSession: RefreshSession(repository),
    ensureValidAccessToken: EnsureValidAccessToken(repository),
    signOut: SignOut(repository),
    clearLocalSession: ClearLocalSession(repository),
    requestPasswordReset: RequestPasswordReset(repository),
    resetPassword: ResetPassword(repository),
    changePassword: ChangePassword(repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginSession, this.verificationError});

  final AuthSession? loginSession;
  final Object? verificationError;
  int verificationRequestCount = 0;
  String? requestedVerificationEmail;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (loginSession != null) return loginSession!;
    final requestOptions = RequestOptions(path: '/api/v1/auth/login');
    throw DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String? phoneNumber,
    required String password,
  }) async {}

  @override
  Future<void> sendEmailVerificationCode(String email) async {
    verificationRequestCount++;
    requestedVerificationEmail = email;
  }

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    if (verificationError != null) throw verificationError!;
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<bool> refreshSession({String? accessTokenUsed}) async => true;

  @override
  Future<bool> ensureValidAccessToken() async => false;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {}

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {}
}
