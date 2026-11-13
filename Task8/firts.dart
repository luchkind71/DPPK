import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:meta/meta.dart';

class Thermostat {
  double _temperatureCelsius;

  Thermostat({double temperatureCelsius = 0})
      : _temperatureCelsius = temperatureCelsius.clamp(-50, 100).toDouble();

  double get temperatureCelsius => _temperatureCelsius;
  double get temperatureFahrenheit => _temperatureCelsius * 9 / 5 + 32;

  set temperatureCelsius(double value) {
    if (value < -50 || value > 100) {
      throw ArgumentError('Температура должна быть в диапазоне -50..+100 °C');
    }
    _temperatureCelsius = value;
  }

  set temperatureFahrenheit(double value) =>
      temperatureCelsius = (value - 32) * 5 / 9;
}

class Pedometer {
  int _steps = 0;
  int get steps => _steps;

  void addSteps(int count) {
    if (count <= 0) throw ArgumentError('count должен быть > 0');
    _steps += count;
  }
}

class Book {
  final String title;
  final int pages;

  Book({required this.title, required this.pages}) {
    if (pages < 0) throw ArgumentError('pages >= 0');
  }

  double get estimatedReadingHours => pages * 2 / 60;
}

class UserCredentials {
  String _passwordHash = '';

  set password(String rawPassword) {
    if (rawPassword.length < 8) {
      throw ArgumentError('Пароль должен содержать не менее 8 символов');
    }
    _passwordHash = _pseudoHash(rawPassword);
  }

  String get passwordHash => _passwordHash;

  String _pseudoHash(String input) {
    var h = 0;
    for (var i = 0; i < input.length; i++) {
      h = (h * 31 + input.codeUnitAt(i)) & 0x7fffffff;
    }
    return h.toRadixString(16);
  }
}

class DeviceSession {
  static int activeSessionsCount = 0;
  final String id;

  DeviceSession({required this.id}) {
    activeSessionsCount++;
  }

  void close() {
    if (activeSessionsCount > 0) activeSessionsCount--;
  }
}

class AppColor {
  final int red, green, blue;
  final double opacity;

  const AppColor._(this.red, this.green, this.blue, this.opacity);

  factory AppColor.fromHex(String hex) {
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'ff$h';
    if (h.length != 8) throw FormatException('Ожидался формат #RRGGBB или #AARRGGBB');
    final a = int.parse(h.substring(0, 2), radix: 16);
    final r = int.parse(h.substring(2, 4), radix: 16);
    final g = int.parse(h.substring(4, 6), radix: 16);
    final b = int.parse(h.substring(6, 8), radix: 16);
    return AppColor._(r, g, b, a / 255);
  }

  factory AppColor.fromRGBO(int r, int g, int b, double o) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      throw RangeError('RGB должны быть в 0..255');
    }
    if (o < 0 || o > 1) throw RangeError('opacity должна быть в 0..1');
    return AppColor._(r, g, b, o);
  }

  String toHex() =>
      '#'
      '${(opacity * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class Point2D {
  final double x, y;
  const Point2D(this.x, this.y);
}

class Rectangle {
  final double width, height;

  Rectangle({required this.width, required this.height})
      : assert(width > 0, 'width > 0'),
        assert(height > 0, 'height > 0');

  double get area => width * height;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  ApiClient._internal();
  factory ApiClient() => _instance;

  String? baseUrl;
}

class Circle {
  final double radius;

  Circle(this.radius) {
    if (radius < 0) throw ArgumentError('radius >= 0');
  }

  Circle.unit() : this(1.0);

  double get area => pi * radius * radius;
  double get circumference => 2 * pi * radius;
}


abstract class Card {
  final String number;
  Card({required this.number});
  double get availableFunds;
  bool pay(double amount) => amount > 0 && amount <= availableFunds;
}

class DebitCard extends Card {
  double _balance;
  DebitCard({required super.number, double balance = 0}) : _balance = balance;
  double get balance => _balance;
  @override
  double get availableFunds => _balance;
  @override
  bool pay(double amount) {
    if (!super.pay(amount)) return false;
    _balance -= amount;
    return true;
  }
}

class CreditCard extends Card {
  double _balance;
  final double _overdraftLimit;
  CreditCard({
    required super.number,
    double balance = 0,
    required double overdraftLimit,
  })  : _balance = balance,
        _overdraftLimit = overdraftLimit;

  double get balance => _balance;
  double get overdraftLimit => _overdraftLimit;
  @override
  double get availableFunds => _balance + _overdraftLimit;
  @override
  bool pay(double amount) {
    if (!super.pay(amount)) return false;
    _balance -= amount;
    return true;
  }
}

abstract class BaseScreen {
  final String routeName;
  final bool requiresAuth;
  BaseScreen({required this.routeName, this.requiresAuth = false});
  void onInit() {}
  String render();
}

class SettingsScreen extends BaseScreen {
  final bool isDarkModeEnabled;
  SettingsScreen({required this.isDarkModeEnabled})
      : super(routeName: '/settings', requiresAuth: true);
  @override
  void onInit() => super.onInit();
  @override
  String render() => 'Settings(isDark=$isDarkModeEnabled)';
}

class HomeScreen extends BaseScreen {
  HomeScreen() : super(routeName: '/home');
  @override
  String render() => 'Home';
}

// Полиморфный список
List<String> renderAll(List<BaseScreen> screens) =>
    screens.map((s) => s.render()).toList();

// super-параметры
class BaseModel {
  final int id;
  final String title;
  BaseModel({required this.id, required this.title});
}

class DerivedModel extends BaseModel {
  final String extra;
  DerivedModel({required super.id, super.title = 'default', required this.extra});
}

// covariant
class Animal {
  void interact(Animal other) {}
}

class Dog extends Animal {
  @override
  void interact(covariant Dog other) {}
}

// @nonVirtual
class LicenseValidator {
  @nonVirtual
  bool verifyLicense(String key) => key.length == 32;
}


abstract class StorageService {
  void save(String key, String value);
  String? read(String key);
  void delete(String key);
}

class MemoryStorageService implements StorageService {
  final Map<String, String> _store = {};
  @override
  void save(String key, String value) => _store[key] = value;
  @override
  String? read(String key) => _store[key];
  @override
  void delete(String key) => _store.remove(key);
}

abstract class Displayable {
  void showContent(String content);
  bool get isDisplayOn;
}

abstract class NetworkConnectable {
  void connect(String ssid);
  bool get isConnected;
}

class SmartTv implements Displayable, NetworkConnectable {
  bool _on = false;
  bool _connected = false;
  String _currentContent = '';

  @override
  bool get isDisplayOn => _on;
  @override
  void showContent(String content) {
    if (!_on) return;
    _currentContent = content;
  }

  @override
  bool get isConnected => _connected;
  @override
  void connect(String ssid) => _connected = true;

  String get currentContent => _currentContent;
}

sealed class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticating extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  Authenticated(this.userId);
}

class AuthFailed extends AuthState {
  final String reason;
  AuthFailed(this.reason);
}

String describeAuth(AuthState state) => switch (state) {
      Unauthenticated() => 'unauthenticated',
      Authenticating() => 'authenticating',
      Authenticated(:final userId) => 'authenticated:$userId',
      AuthFailed(:final reason) => 'failed:$reason',
    };

base class Engine {
  final String type;
  Engine({required this.type});
  String start() => 'Engine $type started';
}

abstract interface class PaymentTerminal {
  void pay(double amount);
  void refund(double amount);
}

class ConcretePaymentTerminal implements PaymentTerminal {
  double _paid = 0;
  double get paid => _paid;
  @override
  void pay(double amount) => _paid += amount;
  @override
  void refund(double amount) => _paid -= amount;
}

mixin JsonPrintable {
  Map<String, Object?> toJson();
  String printAsJson() => jsonEncode(toJson());
}

abstract class FormElement {
  String get tag;
}

mixin ValidationMixin on FormElement {
  bool validateNotNull(dynamic value) => value != null;
}

mixin LoggingMixin {
  final List<String> logs = [];
  void logAction(String action) => logs.add(action);
}

class EmailInput extends FormElement with LoggingMixin, ValidationMixin {
  @override
  String get tag => 'EmailField';

  void onUserSubmitted(String? email) {
    logAction('submit');
    if (validateNotNull(email)) logAction('valid: $email');
  }
}

abstract class ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;
  void dispose() => _disposed = true;
  void notifyListeners() {
    if (_disposed) throw StateError('ChangeNotifier уже освобождён');
  }
}

mixin AutoDisposer on ChangeNotifier {
  void safeNotify() {
    if (!isDisposed) notifyListeners();
  }
}

class MyNotifier extends ChangeNotifier with AutoDisposer {
  int _counter = 0;
  int get counter => _counter;
  void inc() {
    _counter++;
    safeNotify();
  }
}

mixin AnalyticsTracker {
  final List<MapEntry<String, Map<String, Object?>>> events = [];
  void trackEvent(String eventName, [Map<String, Object?> params = const {}]) {
    events.add(MapEntry(eventName, params));
  }
}

class CustomButton with AnalyticsTracker {
  final String label;
  CustomButton(this.label);
  void onClick() => trackEvent('button_click', {'label': label});
}

// Порядок линеаризации: правый миксин переопределяет левый
mixin M1 { String execute() => 'M1'; }
mixin M2 { String execute() => 'M2'; }
class MixOrder with M1, M2 {}

mixin MemoizationMixin {
  final Map<String, num> _cache = {};
  num memoCompute(String key, num Function() compute) {
    if (_cache.containsKey(key)) return _cache[key]!;
    final v = compute();
    _cache[key] = v;
    return v;
  }
}

class MathCalculator with MemoizationMixin {
  num factorial(int n) => memoCompute('fact($n)', () {
        num r = 1;
        for (var i = 2; i <= n; i++) {
          r *= i;
        }
        return r;
      });
}


class Product {
  final String id;
  final String name;
  final double price;
  final double discount;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.discount = 0,
  })  : assert(price >= 0, 'price >= 0'),
        assert(discount >= 0 && discount < 1);

  double get finalPrice => price * (1 - discount);
}

class UserProfile {
  final int id;
  final String name;
  final String? avatarUrl;
  final int age;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.age = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? 'Unknown',
        avatarUrl: json['avatarUrl'] as String?,
        age: (json['age'] as num?)?.toInt() ?? 0,
      );
}

class AppLocale {
  final String languageCode;
  static final Map<String, AppLocale> _cache = {};

  AppLocale._(this.languageCode);

  factory AppLocale(String code) =>
      _cache.putIfAbsent(code, () => AppLocale._(code));
}

class GeoPoint {
  final double lat, lon;
  const GeoPoint(this.lat, this.lon);

  factory GeoPoint.fromString(String source) {
    final parts = source.split(',');
    if (parts.length != 2) throw FormatException('lat, lon expected');
    return GeoPoint(
      double.parse(parts[0].trim()),
      double.parse(parts[1].trim()),
    );
  }
}

class ContactCard {
  final int id;
  final String fullName;
  final String? phone;
  final String? email;

  ContactCard({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
  });

  factory ContactCard.fromDatabaseRecord(Map<String, Object?> row) {
    return ContactCard(
      id: (row['id'] as num).toInt(),
      fullName: '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim(),
      phone: row['phone'] as String?,
      email: row['email'] as String?,
    );
  }
}

class UserModel2 {
  final int id;
  final String name;
  final String? avatarUrl;

  const UserModel2({required this.id, required this.name, this.avatarUrl});

  UserModel2 copyWith({int? id, String? name, String? avatarUrl}) => UserModel2(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

class DateRange {
  final DateTime start, end;
  DateRange(this.start, this.end) : assert(!end.isBefore(start), 'end >= start');
  Duration get length => end.difference(start);
}

class TransactionDto {
  final String id;
  final String type;
  final double amount;
  final DateTime timestamp;

  TransactionDto._({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
  });

  factory TransactionDto.deposit({
    required String id,
    required double amount,
    required DateTime timestamp,
  }) =>
      TransactionDto._(
        id: id,
        type: 'deposit',
        amount: amount,
        timestamp: timestamp,
      );

  factory TransactionDto.withdrawal({
    required String id,
    required double amount,
    required DateTime timestamp,
  }) {
    if (amount < 0) throw ArgumentError('amount >= 0');
    return TransactionDto._(
      id: id,
      type: 'withdrawal',
      amount: amount,
      timestamp: timestamp,
    );
  }

  factory TransactionDto.transfer({
    required String id,
    required double amount,
    required DateTime timestamp,
    required String to,
  }) =>
      TransactionDto._(
        id: id,
        type: 'transfer:$to',
        amount: amount,
        timestamp: timestamp,
      );
}

class EnvConfig {
  final String baseUrl;
  final bool isProduction;

  const EnvConfig._({required this.baseUrl, required this.isProduction});

  factory EnvConfig.fromEnvironment() {
    const url = String.fromEnvironment('API_URL', defaultValue: 'https://dev.local');
    const prod = bool.fromEnvironment('PROD', defaultValue: false);
    return EnvConfig._(baseUrl: url, isProduction: prod);
  }
}

class CartItem {
  final String productId;
  final String selectedSize;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.selectedSize,
    this.quantity = 1,
  });

  @override
  bool operator ==(Object other) =>
      other is CartItem &&
      other.productId == productId &&
      other.selectedSize == selectedSize;

  @override
  int get hashCode => Object.hash(productId, selectedSize);
}


enum NotificationKind { success, warning, critical }

abstract class InAppNotification {
  final String title;
  final Duration timeout;
  const InAppNotification({required this.title, required this.timeout});
  NotificationKind get kind;
  String get iconName;
  int get colorValue;
}

class SuccessNotification extends InAppNotification {
  const SuccessNotification({
    required super.title,
    super.timeout = const Duration(seconds: 3),
  });
  @override
  NotificationKind get kind => NotificationKind.success;
  @override
  String get iconName => 'check';
  @override
  int get colorValue => 0xFF4CAF50;
}

class WarningNotification extends InAppNotification {
  const WarningNotification({
    required super.title,
    super.timeout = const Duration(seconds: 5),
  });
  @override
  NotificationKind get kind => NotificationKind.warning;
  @override
  String get iconName => 'warning';
  @override
  int get colorValue => 0xFFFFC107;
}

class CriticalAlertNotification extends InAppNotification {
  const CriticalAlertNotification({
    required super.title,
    super.timeout = const Duration(seconds: 10),
  });
  @override
  NotificationKind get kind => NotificationKind.critical;
  @override
  String get iconName => 'error';
  @override
  int get colorValue => 0xFFF44336;
}

abstract class BaseDialog {
  final String title;
  const BaseDialog({required this.title});

  String buildHeader() => '=== $title ===';
  String buildFooter() => '---';
  String buildContent();

  String build() => '${buildHeader()}\n${buildContent()}\n${buildFooter()}';
}

class ConfirmActionDialog extends BaseDialog {
  final String message;
  ConfirmActionDialog({required super.title, required this.message});
  @override
  String buildContent() => '$message\n[Confirm] [Cancel]';
}

abstract class MediaPlayer {
  bool _playing = false;
  Duration _position = Duration.zero;

  bool get isPlaying => _playing;
  Duration get position => _position;

  void play() => _playing = true;
  void pause() => _playing = false;
  void seek(Duration pos) => _position = pos;
  void stop() {
    _playing = false;
    _position = Duration.zero;
  }
}

class AudioPlayer extends MediaPlayer {
  double volume = 1.0;
}

class HlsVideoPlayer extends MediaPlayer {
  String quality = 'auto';
}

abstract class HardwareSensor {
  bool _active = false;
  bool get isActive => _active;
  void start() => _active = true;
  void stop() => _active = false;
}

class AccelerometerSensor extends HardwareSensor {
  double x = 0, y = 0, z = 0;
  void update(double nx, double ny, double nz) {
    if (!isActive) return;
    x = nx;
    y = ny;
    z = nz;
  }
}

class BarometerSensor extends HardwareSensor {
  double pressureHpa = 0;
  void update(double p) {
    if (!isActive) return;
    pressureHpa = p;
  }
}

abstract class SubscriptionPlan {
  final String name;
  const SubscriptionPlan({required this.name});
  double get monthlyPrice;
}

class MonthlyPlan extends SubscriptionPlan {
  final double price;
  const MonthlyPlan({required this.price}) : super(name: 'Monthly');
  @override
  double get monthlyPrice => price;
}

class AnnualDiscountPlan extends SubscriptionPlan {
  final double monthlyBase;
  const AnnualDiscountPlan({required this.monthlyBase}) : super(name: 'Annual');
  @override
  double get monthlyPrice => monthlyBase * 0.8;
}

class FamilyPlan extends SubscriptionPlan {
  final double pricePerMember;
  final int members;
  const FamilyPlan({required this.pricePerMember, required this.members})
      : super(name: 'Family');
  @override
  double get monthlyPrice => pricePerMember * members;
}

abstract class CanvasLayer {
  final int zIndex;
  double opacity;
  bool visible;

  CanvasLayer({required this.zIndex, this.opacity = 1.0, this.visible = true});

  String describeType();
}

class VectorLayer extends CanvasLayer {
  final List<Map<String, double>> paths = [];
  VectorLayer({required super.zIndex, super.opacity, super.visible});
  @override
  String describeType() => 'vector';
}

class RasterBitmapLayer extends CanvasLayer {
  String bitmapId = '';
  RasterBitmapLayer({required super.zIndex, super.opacity, super.visible});
  @override
  String describeType() => 'raster';
}

class TextLayer extends CanvasLayer {
  String text = '';
  TextLayer({required super.zIndex, super.opacity, super.visible});
  @override
  String describeType() => 'text';
}

abstract class PaymentGateway {
  final String name;
  final List<String> auditLog = [];

  PaymentGateway({required this.name});

  void _log(String msg) => auditLog.add('[$name] $msg');
  bool pay(double amount) {
    _log('pay $amount');
    return _doPay(amount);
  }

  bool _doPay(double amount);
}

class SbpGateway extends PaymentGateway {
  SbpGateway() : super(name: 'SBP');
  @override
  bool _doPay(double amount) => amount > 0;
}

class BankCardGateway extends PaymentGateway {
  BankCardGateway() : super(name: 'BankCard');
  @override
  bool _doPay(double amount) => amount > 0 && amount <= 100000;
}

class OnboardingStep {
  final String title;
  final String illustrationId;
  bool _skipped = false;

  OnboardingStep({required this.title, required this.illustrationId});
  void skip() => _skipped = true;
  bool get isSkipped => _skipped;
}

abstract class WidgetButton {
  final String label;
  bool _enabled = true;

  WidgetButton({required this.label});
  bool get isEnabled => _enabled;
  void setEnabled(bool v) => _enabled = v;

  String build();
}

class AsyncLoadingButton extends WidgetButton {
  bool _loading = false;
  AsyncLoadingButton({required super.label});
  bool get isLoading => _loading;

  Future<void> runAsync(Future<void> Function() action) async {
    if (_loading || !isEnabled) return;
    _loading = true;
    try {
      await action();
    } finally {
      _loading = false;
    }
  }

  @override
  String build() => _loading ? '[...] $label' : '[$label]';
}

abstract class AppLogger {
  final List<String> _entries = [];
  List<String> get entries => List.unmodifiable(_entries);

  void _record(String level, String message) {
    _entries.add('$level: $message');
    output('$level: $message');
  }

  void info(String m) => _record('INFO', m);
  void error(String m) => _record('ERROR', m);

  void output(String formatted);
}

class ConsoleLogger extends AppLogger {
  final List<String> _buffer = [];
  List<String> get buffer => List.unmodifiable(_buffer);

  @override
  void output(String formatted) => _buffer.add(formatted);
}

class FileCrashLogger extends AppLogger {
  final List<String> _fileContents = [];
  List<String> get fileContents => List.unmodifiable(_fileContents);

  @override
  void output(String formatted) {
    if (formatted.startsWith('ERROR')) _fileContents.add(formatted);
  }
}

class ProductRepoModel {
  final int id;
  final String name;
  const ProductRepoModel({required this.id, required this.name});
}

abstract class ProductRepository {
  Future<List<ProductRepoModel>> getAll();
  Future<ProductRepoModel> getById(int id);
}

class NetworkProductRepository implements ProductRepository {
  final List<ProductRepoModel> _remote = [];
  void seed(List<ProductRepoModel> items) => _remote.addAll(items);
  @override
  Future<List<ProductRepoModel>> getAll() async => List.of(_remote);
  @override
  Future<ProductRepoModel> getById(int id) async =>
      _remote.firstWhere((p) => p.id == id);
}

class MockProductRepository implements ProductRepository {
  final List<ProductRepoModel> _items;
  MockProductRepository([List<ProductRepoModel>? items]) : _items = items ?? [];
  @override
  Future<List<ProductRepoModel>> getAll() async => List.of(_items);
  @override
  Future<ProductRepoModel> getById(int id) async =>
      _items.firstWhere((p) => p.id == id);
}

abstract class BiometricAuthService {
  Future<bool> canAuthenticate();
  Future<bool> authenticate();
}

class FakeBiometricAuthService implements BiometricAuthService {
  @override
  Future<bool> canAuthenticate() async => true;
  @override
  Future<bool> authenticate() async => true;
}

abstract class CryptoService {
  String encrypt(String plainText);
  String decrypt(String cipherText);
}

class AesCryptoService implements CryptoService {
  final int _key;
  AesCryptoService([this._key = 0x5A]);
  @override
  String encrypt(String plainText) => _xor(plainText);
  @override
  String decrypt(String cipherText) => _xor(cipherText);
  String _xor(String s) =>
      String.fromCharCodes(s.codeUnits.map((c) => c ^ _key));
}

abstract class AnalyticsProvider {
  void logEvent(String name, Map<String, Object> params);
}

class CompositeAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsProvider> providers;
  CompositeAnalyticsProvider(this.providers);
  @override
  void logEvent(String name, Map<String, Object> params) {
    for (final p in providers) {
      p.logEvent(name, params);
    }
  }
}

abstract class Geolocator {
  Future<GeoPoint> getCurrentPosition();
  Stream<GeoPoint> get positionStream;
}

class FakeGeolocator implements Geolocator {
  final StreamController<GeoPoint> _controller =
      StreamController<GeoPoint>.broadcast();
  @override
  Future<GeoPoint> getCurrentPosition() async => const GeoPoint(0, 0);
  @override
  Stream<GeoPoint> get positionStream => _controller.stream;
  void emit(GeoPoint p) => _controller.add(p);
}

abstract class NotificationSender {
  Future<void> sendNow(String title, String body);
  Future<void> schedule(String title, String body, DateTime at);
}

class FakeNotificationSender implements NotificationSender {
  final List<Map<String, Object?>> sent = [];
  @override
  Future<void> sendNow(String title, String body) async {
    sent.add({'type': 'now', 'title': title, 'body': body});
  }

  @override
  Future<void> schedule(String title, String body, DateTime at) async {
    sent.add({
      'type': 'scheduled',
      'title': title,
      'body': body,
      'at': at.toIso8601String(),
    });
  }
}

abstract class DataSyncEngine {
  Future<void> fetchRemoteDelta();
  Future<void> applyLocalChanges();
  Future<void> sync() async {
    await fetchRemoteDelta();
    await applyLocalChanges();
  }
}

class LocalRemoteSyncEngine extends DataSyncEngine {
  final List<String> _log = [];
  List<String> get log => List.unmodifiable(_log);
  @override
  Future<void> fetchRemoteDelta() async => _log.add('fetch');
  @override
  Future<void> applyLocalChanges() async => _log.add('apply');
}

abstract class ConnectivityService {
  bool get isOnline;
  Stream<bool> get onStatusChanged;
}

class SimpleConnectivityService implements ConnectivityService {
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();
  bool _online = true;

  @override
  bool get isOnline => _online;
  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  void setOnline(bool v) {
    _online = v;
    _controller.add(v);
  }
}

abstract class KeyValueStorage {
  T? read<T>(String key);
  Future<void> write<T>(String key, T value);
}

class InMemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, Object?> _store = {};
  @override
  T? read<T>(String key) => _store[key] as T?;
  @override
  Future<void> write<T>(String key, T value) async => _store[key] = value;
}

abstract class ReportExporter {
  Future<List<int>> export(Map<String, Object?> data);
}

class PdfReportExporter implements ReportExporter {
  @override
  Future<List<int>> export(Map<String, Object?> data) async =>
      utf8.encode('PDF:${jsonEncode(data)}');
}

class ExcelReportExporter implements ReportExporter {
  @override
  Future<List<int>> export(Map<String, Object?> data) async =>
      utf8.encode('XLS:${jsonEncode(data)}');
}

mixin DebounceMixin {
  final Map<String, DateTime> _lastCalled = {};

  bool canCall(String key, {Duration window = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    final last = _lastCalled[key];
    if (last != null && now.difference(last) < window) return false;
    _lastCalled[key] = now;
    return true;
  }
}

mixin RestorationMixin {
  final Map<String, String> _fieldValues = {};
  void saveField(String field, String value) => _fieldValues[field] = value;
  String? restoreField(String field) => _fieldValues[field];
  Map<String, String> get snapshot => Map.unmodifiable(_fieldValues);
}

mixin NetworkAwareMixin {
  bool get isOnline;
  Future<T> guarded<T>(Future<T> Function() action) async {
    if (!isOnline) throw StateError('Нет соединения');
    return action();
  }
}

mixin CurrencyFormatterMixin {
  String formatCurrency(num amount, {String symbol = '₽', int fraction = 2}) {
    final s = amount.toStringAsFixed(fraction);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    final frac = fraction > 0 ? ',${parts[1]}' : '';
    return '$buf$frac $symbol';
  }
}

mixin PeriodicRefreshMixin {
  Timer? _timer;
  bool _active = false;

  void startRefresh(Future<void> Function() task,
      {Duration interval = const Duration(seconds: 30)}) {
    stopRefresh();
    _active = true;
    _timer = Timer.periodic(interval, (_) {
      if (_active) task();
    });
  }

  void stopRefresh() {
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  bool get isRefreshing => _active;
}

mixin PassportValidationMixin {
  bool validateSeries(String s) => RegExp(r'^\d{4}$').hasMatch(s);
  bool validateNumber(String s) => RegExp(r'^\d{6}$').hasMatch(s);
  bool validateDepartmentCode(String s) =>
      RegExp(r'^\d{3}-\d{3}$').hasMatch(s);
  bool validateAll({
    required String series,
    required String number,
    required String department,
  }) =>
      validateSeries(series) &&
      validateNumber(number) &&
      validateDepartmentCode(department);
}

mixin FadeAnimationController {
  double _opacity = 0;
  double get opacity => _opacity;

  void fadeIn() => _opacity = 1;
  void fadeOut() => _opacity = 0;
  void setOpacity(double v) {
    if (v < 0 || v > 1) throw RangeError.range(v, 0, 1);
    _opacity = v;
  }
}

mixin ThemeSwitcherMixin {
  bool _dark = false;
  bool get isDark => _dark;
  int get backgroundColor => _dark ? 0xFF121212 : 0xFFFFFFFF;
  int get textColor => _dark ? 0xFFFFFFFF : 0xFF000000;
  void toggleTheme() => _dark = !_dark;
}

mixin DeepLinkHandlerMixin {
  final List<Uri> handledLinks = [];
  bool handleUri(Uri uri) {
    const known = {'app', 'https'};
    if (!known.contains(uri.scheme)) return false;
    handledLinks.add(uri);
    return true;
  }
}

mixin AdminAuditMixin {
  final List<Map<String, Object?>> auditEntries = [];
  void auditAction(String adminId, String action,
      {Map<String, Object?> extra = const {}}) {
    auditEntries.add({
      'adminId': adminId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...extra,
    });
  }
}

sealed class CartState {}

class CartEmpty extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;
  CartLoaded(this.items, this.total);
}

class CartCheckoutError extends CartState {
  final String error;
  CartCheckoutError(this.error);
}

String describeCart(CartState s) => switch (s) {
      CartEmpty() => 'empty',
      CartLoading() => 'loading',
      CartLoaded(:final items, :final total) =>
        '${items.length} items, total=$total',
      CartCheckoutError(:final error) => 'error: $error',
    };

sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final Exception exception;
  Failure(this.exception);
}

sealed class LoginEvent {}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
}

class LoginPasswordChanged extends LoginEvent {
  final String pass;
  LoginPasswordChanged(this.pass);
}

class LoginSubmitted extends LoginEvent {}

final class EncryptionKey {
  final List<int> bytes;
  EncryptionKey(this.bytes);
  String toBase64() => base64Encode(bytes);
}

sealed class AppRoute {}

class HomeRoute extends AppRoute {}

class ProfileRoute extends AppRoute {
  final int userId;
  ProfileRoute(this.userId);
}

class SettingsRoute extends AppRoute {}

class NotFoundRoute extends AppRoute {
  final String path;
  NotFoundRoute(this.path);
}

String routeToPath(AppRoute r) => switch (r) {
      HomeRoute() => '/home',
      ProfileRoute(:final userId) => '/profile/$userId',
      SettingsRoute() => '/settings',
      NotFoundRoute(:final path) => '/404?path=$path',
    };

abstract class Command {
  void execute();
  void undo();
}

class InsertTextCommand implements Command {
  final List<String> _buffer;
  final int position;
  final String text;
  bool _applied = false;

  InsertTextCommand(this._buffer, this.position, this.text);

  @override
  void execute() {
    if (_applied) return;
    _buffer.insert(position, text);
    _applied = true;
  }

  @override
  void undo() {
    if (!_applied) return;
    _buffer.removeAt(position);
    _applied = false;
  }
}

class NotificationBuilder {
  String _title = '';
  String _body = '';
  String? _icon;

  NotificationBuilder setTitle(String t) {
    _title = t;
    return this;
  }

  NotificationBuilder setBody(String b) {
    _body = b;
    return this;
  }

  NotificationBuilder setIcon(String i) {
    _icon = i;
    return this;
  }

  BuiltNotification build() {
    if (_title.isEmpty) throw StateError('title required');
    return BuiltNotification(_title, _body, _icon);
  }
}

class BuiltNotification {
  final String title, body;
  final String? icon;
  BuiltNotification(this.title, this.body, this.icon);
}

class EventBus {
  final Map<Type, List<void Function(Object)>> _listeners = {};

  void on<T>(void Function(T) handler) {
    _listeners.putIfAbsent(T, () => []).add((o) => handler(o as T));
  }

  void clear<T>() => _listeners.remove(T);

  void emit(Object event) {
    final list = _listeners[event.runtimeType];
    if (list == null) return;
    for (final h in List.of(list)) {
      h(event);
    }
  }
}

sealed class TaxiOrderState {}

class SearchingTaxi extends TaxiOrderState {}

class TaxiAssigned extends TaxiOrderState {
  final String driverId;
  TaxiAssigned(this.driverId);
}

class RideInProgress extends TaxiOrderState {
  final double distanceKm;
  RideInProgress(this.distanceKm);
}

class RideCompleted extends TaxiOrderState {
  final double fare;
  RideCompleted(this.fare);
}

class RideCancelled extends TaxiOrderState {
  final String reason;
  RideCancelled(this.reason);
}

enum TaxiTariff { economy, comfort, business }

class TaxiOrder {
  final String id;
  final TaxiTariff tariff;
  final GeoPoint from;
  final GeoPoint to;
  final DateTime createdAt;

  TaxiOrder._({
    required this.id,
    required this.tariff,
    required this.from,
    required this.to,
    required this.createdAt,
  });

  factory TaxiOrder.create({
    required String id,
    required TaxiTariff tariff,
    required GeoPoint from,
    required GeoPoint to,
  }) =>
      TaxiOrder._(
        id: id,
        tariff: tariff,
        from: from,
        to: to,
        createdAt: DateTime.now(),
      );

  factory TaxiOrder.fromJson(Map<String, dynamic> json) => TaxiOrder._(
        id: json['id'] as String,
        tariff: TaxiTariff.values.firstWhere(
          (t) => t.name == json['tariff'],
          orElse: () => TaxiTariff.economy,
        ),
        from: GeoPoint.fromString(json['from'] as String),
        to: GeoPoint.fromString(json['to'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

mixin LocationTrackingMixin {
  final List<GeoPoint> _track = [];
  List<GeoPoint> get track => List.unmodifiable(_track);

  void recordPosition(GeoPoint p) => _track.add(p);

  double get totalTrackDistanceKm {
    if (_track.length < 2) return 0;
    double d = 0;
    for (var i = 1; i < _track.length; i++) {
      final dx = _track[i].lat - _track[i - 1].lat;
      final dy = _track[i].lon - _track[i - 1].lon;
      d += sqrt(dx * dx + dy * dy) * 111.0;
    }
    return d;
  }
}

mixin FareCalculationMixin {
  double baseFare(TaxiTariff t) => switch (t) {
        TaxiTariff.economy => 100,
        TaxiTariff.comfort => 200,
        TaxiTariff.business => 400,
      };

  double perKmRate(TaxiTariff t) => switch (t) {
        TaxiTariff.economy => 20,
        TaxiTariff.comfort => 35,
        TaxiTariff.business => 60,
      };

  double calculate(TaxiTariff t, double distanceKm) =>
      baseFare(t) + distanceKm * perKmRate(t);
}

class TaxiRideController with LocationTrackingMixin, FareCalculationMixin {
  final TaxiOrder order;
  TaxiOrderState _state = SearchingTaxi();

  TaxiRideController(this.order);

  TaxiOrderState get state => _state;

  void assignDriver(String driverId) {
    if (_state is! SearchingTaxi) return;
    _state = TaxiAssigned(driverId);
  }

  void startRide() {
    if (_state is! TaxiAssigned) return;
    _state = RideInProgress(0);
  }

  void updateProgress(double distanceKm) {
    if (_state is! RideInProgress) return;
    _state = RideInProgress(distanceKm);
  }

  void complete() {
    if (_state is! RideInProgress) return;
    final fare = calculate(order.tariff, (_state as RideInProgress).distanceKm);
    _state = RideCompleted(fare);
  }

  void cancel(String reason) => _state = RideCancelled(reason);

  String describe() => switch (_state) {
        SearchingTaxi() => 'searching',
        TaxiAssigned(:final driverId) => 'driver:$driverId',
        RideInProgress(:final distanceKm) => 'ride:$distanceKm',
        RideCompleted(:final fare) => 'done:$fare',
        RideCancelled(:final reason) => 'cancelled:$reason',
      };
}