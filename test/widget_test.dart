import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veyra/app.dart';
import 'package:veyra/features/search/search_screen.dart';
import 'package:veyra/core/widgets/shared_widgets.dart';
import 'package:veyra/features/profile/widgets/profile_sheets.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('VeyraApp smoke test and explore header rendering', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeyraApp());
    await tester.pump();

    expect(find.byType(VeyraApp), findsOneWidget);
    expect(find.text('Veyra'), findsOneWidget);
    expect(find.text('Discover Your'), findsOneWidget);
    expect(find.text('Featured Stays'), findsOneWidget);
  });

  testWidgets('Navigating to SearchScreen resolves AppScope and avoids infinite loading', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeyraApp());
    await tester.pump();

    // Tap the Search button in the bottom navigation bar
    final searchNavDestination = find.byIcon(Icons.search_outlined);
    expect(searchNavDestination, findsOneWidget);
    await tester.tap(searchNavDestination);
    await tester.pump();

    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byType(LoadingState), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('SearchScreen toggles between List View and Map View with dynamic price markers', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeyraApp());
    await tester.pump();

    // Navigate to Search
    final searchNavDestination = find.byIcon(Icons.search_outlined);
    await tester.tap(searchNavDestination);
    await tester.pumpAndSettle();

    // Verify Map View toggle pill button is visible
    final mapViewPill = find.text('Map View');
    expect(mapViewPill, findsOneWidget);

    // Tap Map View
    await tester.tap(mapViewPill);
    await tester.pumpAndSettle();

    // Should now see 'List View' toggle button
    expect(find.text('List View'), findsOneWidget);

    // Should see dynamic price markers like $580
    expect(find.text('\$580'), findsWidgets);

    // Tap the $580 marker
    await tester.tap(find.text('\$580').first);
    await tester.pumpAndSettle();

    // Floating preview card should be displayed
    expect(find.text('Pearl Overwater Bungalow'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    // Toggle back to List View
    await tester.tap(find.text('List View'));
    await tester.pumpAndSettle();

    expect(find.text('Map View'), findsOneWidget);
  });

  testWidgets('Shimmer skeleton widgets render cleanly without pixel overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 328,
                height: 292,
                child: StayCardSkeleton(),
              ),
              FeaturedStayCardSkeleton(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StayCardSkeleton), findsOneWidget);
    expect(find.byType(FeaturedStayCardSkeleton), findsOneWidget);
  });

  testWidgets('LanguageSelectorSheet renders without pixel overflow at 360x640 and updates language', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final profileCtrl = UserProfileController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => LanguageSelectorSheet(profileCtrl: profileCtrl),
                );
              },
              child: const Text('Open Languages'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Open sheet
    await tester.tap(find.text('Open Languages'));
    await tester.pumpAndSettle();

    // Verify sheet title and languages are present without overflow
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('English (US)'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);

    // Tap Français
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(profileCtrl.language, 'Français');
  });

  testWidgets('PaymentMethodsSheet renders cards with DEFAULT badge without horizontal overflow at 360x640', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final profileCtrl = UserProfileController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => PaymentMethodsSheet(profileCtrl: profileCtrl),
                );
              },
              child: const Text('Open Payments'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open Payments'));
    await tester.pumpAndSettle();

    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('DEFAULT'), findsOneWidget);
    expect(find.text('Add Another Card'), findsOneWidget);

    // Tap the second card to set as default
    final secondCardFinder = find.textContaining('9012');
    expect(secondCardFinder, findsOneWidget);
    await tester.tap(secondCardFinder);
    await tester.pumpAndSettle();

    expect(profileCtrl.defaultCard?.last4, '9012');
  });

  testWidgets('NotificationsHubSheet renders VIP quiet hours toggle and controls at 360x640', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final profileCtrl = UserProfileController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => NotificationsHubSheet(profileCtrl: profileCtrl),
                );
              },
              child: const Text('Open Notifications'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.textContaining('VIP Quiet Hours'), findsOneWidget);

    // Toggle Quiet Hours
    final quietHoursSwitch = find.byType(Switch).first;
    await tester.tap(quietHoursSwitch);
    await tester.pumpAndSettle();

    expect(profileCtrl.quietHoursEnabled, true);
  });

  testWidgets('CurrencySelectorSheet filters currencies dynamically via search bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final currencyCtrl = CurrencyController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => CurrencySelectorSheet(currencyCtrl: currencyCtrl),
                );
              },
              child: const Text('Open Currency'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open Currency'));
    await tester.pumpAndSettle();

    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.textContaining('Euro'), findsOneWidget);

    // Enter search text 'JPY'
    await tester.enterText(find.byType(TextField), 'JPY');
    await tester.pumpAndSettle();

    expect(find.textContaining('Japanese Yen'), findsOneWidget);
    expect(find.textContaining('Euro'), findsNothing);

    // Tap Japanese Yen
    await tester.tap(find.textContaining('Japanese Yen'));
    await tester.pumpAndSettle();

    expect(currencyCtrl.current.code, 'JPY');
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  static final Uint8List _transparentPng = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
