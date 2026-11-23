import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

// ОБЩИЕ УТИЛИТЫ

// Тяжелая функция для изолятов
int heavyCalculation(int n) {
  var s = 0;
  for (var i = 0; i < n; i++) {
    s += i % 3;
  }
  return s;
}

// ТЕМА 1. FUTURE, async/await

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

Future<bool> t1Login(String user, String pass) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  if (pass == '1234') return true;
  throw AuthException('Неверный пароль для $user');
}

Future<Map<String, String>> t1ReadConfigsParallel() async {
  Future<String> read(String name) => Future.delayed(
        Duration(milliseconds: 300 + name.length * 10),
        () => '$name:value',
      );

  final results = await Future.wait([read('db'), read('api'), read('ui')]);
  return {'db': results[0], 'api': results[1], 'ui': results[2]};
}

Future<String> t1FastestMirror() {
  Future<String> mirror(String name, int ms) =>
      Future.delayed(Duration(milliseconds: ms), () => '$name OK');
  return Future.any([mirror('mirror1', 800), mirror('mirror2', 1200)]);
}

Future<T> t1Retry<T>(
  Future<T> Function() task, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await task();
    } catch (_) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      await Future.delayed(delay);
    }
  }
}

Future<bool> t1LoginThen(String user, String pass) {
  return Future.delayed(const Duration(milliseconds: 1500)).then((_) {
    if (pass == '1234') return true;
    throw AuthException('Неверный пароль для $user');
  }).catchError((Object e) {
    print('login error: $e');
    return false;
  }).whenComplete(() {
    print('login complete');
  });
}

// ТЕМА 2. STREAM, async*

Stream<int> t2StopWatch() async* {
  var i = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield i++;
  }
}

Stream<(double, double)> t2GpsStream() async* {
  double lat = 55.75, lon = 37.61;
  final r = Random();
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500));
    lat += (r.nextDouble() - 0.5) * 0.001;
    lon += (r.nextDouble() - 0.5) * 0.001;
    yield (lat, lon);
  }
}

Stream<double> t2QuotesSingle() async* {
  final r = Random();
  for (var i = 0; i < 20; i++) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield 60000 + r.nextDouble() * 5000;
  }
}

Future<int> t2SumStream(Stream<int> s) => s.fold(0, (a, b) => a + b);

Stream<int> t2TenNumbers() async* {
  for (var i = 1; i <= 10; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
    yield i;
  }
}

Stream<int> t2Concat(Stream<int> a, Stream<int> b) async* {
  yield* a;
  yield* b;
}

// ТЕМА 3. STREAMCONTROLLER, STREAMTRANSFORMER

StreamTransformer<String, String> t3UpperCaseTransformer() =>
    StreamTransformer.fromHandlers(
      handleData: (data, sink) => sink.add(data.toUpperCase()),
    );

class T3SearchControllerWrapper {
  final _in = StreamController<String>();
  late final Stream<String> out = _in.stream.map((s) => s.trim());

  Sink<String> get sink => _in.sink;
  Stream<String> get stream => out;

  void dispose() => _in.close();
}

Future<void> t3ErrorDemo() async {
  final c = StreamController<int>();
  final sub = c.stream.listen(
    (v) => print(v),
    onError: (e) => print('onError: $e'),
  );
  c.add(1);
  c.addError(Exception('Сбой датчика'));
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  await c.close();
}

void t3SafeAdd(StreamController<int> c, int v) {
  if (!c.isClosed) {
    c.add(v);
  } else {
    print('controller closed');
  }
}

StreamController<int> t3TrackedController() {
  var active = 0;
  return StreamController<int>(
    onListen: () {
      active++;
      print('listen, active=$active');
    },
    onCancel: () {
      active--;
      print('cancel, active=$active');
    },
  );
}

// ТЕМА 4. ISOLATES

Future<List<Map<String, dynamic>>> t4ParseJsonInIsolate(String jsonStr) =>
    Isolate.run(() {
      final data = jsonDecode(jsonStr) as List;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    });

String t4MakeJson(int n) => jsonEncode(
      List.generate(n, (i) => {'id': i, 'name': 'item$i', 'value': i * 2}),
    );

List<int> t4FindPrimes(int limit) {
  final res = <int>[];
  for (var n = 2; n <= limit; n++) {
    var prime = true;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) {
        prime = false;
        break;
      }
    }
    if (prime) res.add(n);
  }
  return res;
}

void t4CalculatorEntry(SendPort send) {
  final rp = ReceivePort();
  send.send(rp.sendPort);
  rp.listen((msg) {
    if (msg is Map) {
      final a = msg['a'] as num;
      final b = msg['b'] as num;
      final op = msg['op'] as String;
      final reply = msg['reply'] as SendPort;
      final num res = switch (op) {
        '+' => a + b,
        '-' => a - b,
        '*' => a * b,
        '/' => a / b,
        _ => throw ArgumentError('unknown op'),
      };
      reply.send(res);
    }
  });
}

Future<SendPort> t4StartCalculator() async {
  final rp = ReceivePort();
  await Isolate.spawn(t4CalculatorEntry, rp.sendPort);
  return await rp.first as SendPort;
}

Future<num> t4Calc(SendPort port, num a, num b, String op) async {
  final rp = ReceivePort();
  port.send({'a': a, 'b': b, 'op': op, 'reply': rp.sendPort});
  final res = await rp.first;
  rp.close();
  return res as num;
}

void t4InfiniteEntry(SendPort sp) {
  while (true) {}
}

// БЛОК 1. СЕТЬ, ТАЙМЕРЫ, FUTURE

Future<Map<String, dynamic>> b1FetchData(String url) async {
  await Future.delayed(const Duration(milliseconds: 1200));
  if (url.contains('404')) return {'status': 404, 'error': 'Not Found'};
  if (url.contains('500')) return {'status': 500, 'error': 'Server Error'};
  return {'status': 200, 'data': {'url': url}};
}

Future<T> b1Backoff<T>(Future<T> Function() request, {int maxAttempts = 5}) async {
  var delay = 1;
  for (var i = 1; i <= maxAttempts; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxAttempts || e is! SocketException) rethrow;
      await Future.delayed(Duration(seconds: delay));
      delay *= 2;
    }
  }
  throw StateError('unreachable');
}

class B1Semaphore {
  int _available;
  final Queue<Completer<void>> _waiters = Queue();

  B1Semaphore(this._available);

  Future<void> acquire() async {
    if (_available > 0) {
      _available--;
      return;
    }
    final c = Completer<void>();
    _waiters.add(c);
    return c.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      _available++;
    }
  }
}

Future<List<String>> b1DownloadMetadata(List<String> urls, {int limit = 2}) async {
  final sem = B1Semaphore(limit);
  return Future.wait(urls.map((u) async {
    await sem.acquire();
    try {
      await Future.delayed(Duration(milliseconds: 200 + u.length * 10));
      return 'meta:$u';
    } finally {
      sem.release();
    }
  }));
}

Future<String> b1PingFastest(List<String> mirrors) {
  Future<String> ping(String url) => Future.delayed(
        Duration(milliseconds: 300 + Random().nextInt(900)),
        () => url,
      );
  return Future.any(mirrors.map(ping));
}

class B1AsyncQueue {
  Future<void> _tail = Future.value();

  Future<T> add<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

Future<int> b1Benchmark(Future<void> Function() task) async {
  final sw = Stopwatch()..start();
  await task();
  sw.stop();
  return sw.elapsedMilliseconds;
}

class B1AppConfig {
  static Future<B1AppConfig>? _future;
  final Map<String, String> data;
  B1AppConfig._(this.data);

  static Future<B1AppConfig> getInstance() {
    return _future ??= Future.delayed(
      const Duration(milliseconds: 500),
      () => B1AppConfig._({'api': 'https://api.example.com'}),
    );
  }
}

class B1Debouncer {
  final Duration delay;
  Timer? _timer;
  B1Debouncer(this.delay);

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  void dispose() => _timer?.cancel();
}

// БЛОК 2. STREAM, ДАТЧИКИ

Stream<int> b2DownloadProgress() async* {
  for (var p = 0; p <= 100; p += 10) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield p;
  }
}

class B2NavEvent {
  final String type;
  final dynamic value;
  B2NavEvent(this.type, this.value);
}

Stream<B2NavEvent> b2MergeNavigation(
    Stream<(double, double)> geo, Stream<double> compass) {
  final c = StreamController<B2NavEvent>();
  final s1 = geo.listen((p) => c.add(B2NavEvent('geo', p)));
  final s2 = compass.listen((h) => c.add(B2NavEvent('compass', h)));
  c.onCancel = () {
    s1.cancel();
    s2.cancel();
  };
  return c.stream;
}

Stream<T> b2Throttle<T>(Stream<T> source, Duration window) {
  DateTime? last;
  return source.where((_) {
    final now = DateTime.now();
    if (last == null || now.difference(last!) >= window) {
      last = now;
      return true;
    }
    return false;
  });
}

Stream<List<T>> b2Buffer<T>(
  Stream<T> source, {
  int size = 5,
  Duration time = const Duration(seconds: 3),
}) {
  late StreamController<List<T>> c;
  final buf = <T>[];
  Timer? timer;

  void flush() {
    if (buf.isNotEmpty) {
      c.add(List.of(buf));
      buf.clear();
    }
    timer?.cancel();
    timer = null;
  }

  c = StreamController<List<T>>(
    onListen: () {
      final sub = source.listen(
        (e) {
          buf.add(e);
          if (buf.length >= size) {
            flush();
          } else {
            timer ??= Timer(time, flush);
          }
        },
        onError: c.addError,
        onDone: () {
          flush();
          c.close();
        },
      );
      c.onCancel = () {
        timer?.cancel();
        sub.cancel();
      };
    },
  );
  return c.stream;
}

Stream<double> b2MovingAverage(Stream<num> source, {int window = 5}) async* {
  final q = Queue<num>();
  await for (final v in source) {
    q.addLast(v);
    if (q.length > window) q.removeFirst();
    yield q.reduce((a, b) => a + b) / q.length;
  }
}

// БЛОК 3. РЕАКТИВНЫЕ ШИНЫ, STREAMCONTROLLER

class B3EventBus {
  B3EventBus._();
  static final instance = B3EventBus._();
  final _c = StreamController<dynamic>.broadcast();

  // ИСПРАВЛЕНО ЗДЕСЬ
  Stream<T> on<T>() => _c.stream.where((event) => event is T).cast<T>();
  
  void fire(Object event) => _c.add(event);
  Future<void> dispose() => _c.close();
}

class B3CartStore {
  int _count = 0;
  int _total = 0;
  final _c = StreamController<({int count, int total})>.broadcast();

  Stream<({int count, int total})> get stream => _c.stream;

  void add(int price) {
    _count++;
    _total += price;
    _c.add((count: _count, total: _total));
  }

  void remove(int price) {
    if (_count > 0) {
      _count--;
      _total -= price;
      _c.add((count: _count, total: _total));
    }
  }
  void dispose() => _c.close();
}

sealed class B3PlayerState {}
class B3Stopped extends B3PlayerState {}
class B3Playing extends B3PlayerState {
  final String track;
  B3Playing(this.track);
}
class B3Paused extends B3PlayerState {}

class B3AudioPlayerBloc {
  final _c = StreamController<B3PlayerState>.broadcast();
  Stream<B3PlayerState> get stream => _c.stream;

  void play(String track) => _c.add(B3Playing(track));
  void pause() => _c.add(B3Paused());
  void stop() => _c.add(B3Stopped());
  void dispose() => _c.close();
}

enum B3ThemeMode { light, dark }
class B3ThemeManager {
  final _c = StreamController<B3ThemeMode>.broadcast();
  var _mode = B3ThemeMode.light;
  Stream<B3ThemeMode> get stream => _c.stream;

  void toggle() {
    _mode = _mode == B3ThemeMode.light ? B3ThemeMode.dark : B3ThemeMode.light;
    _c.add(_mode);
  }
  void dispose() => _c.close();
}

Stream<bool> b3IsSubmitEnabled(Stream<String> email, Stream<String> password) {
  final c = StreamController<bool>.broadcast();
  String? e, p;
  late StreamSubscription<String> s1, s2;

  void calc() {
    final ok = (e ?? '').contains('@') && (p ?? '').length >= 6;
    c.add(ok);
  }

  s1 = email.listen((v) { e = v; calc(); });
  s2 = password.listen((v) { p = v; calc(); });

  c.onCancel = () {
    s1.cancel();
    s2.cancel();
  };
  return c.stream;
}

class B3CrashLogger {
  final _c = StreamController<Object>.broadcast();
  Stream<Object> get stream => _c.stream;
  void log(Object error, StackTrace st) {
    _c.add({'error': error.toString(), 'stack': st.toString()});
  }
  void dispose() => _c.close();
}

void b3InstallCrashLogger(B3CrashLogger logger, void Function() appRunner) {
  runZonedGuarded(appRunner, (e, st) => logger.log(e, st));
}

// БЛОК 4. ИЗОЛЯТЫ И ТЯЖЕЛЫЕ ЗАДАЧИ

Future<Uint8List> b4GenerateThumbnail(Uint8List bytes) => Isolate.run(() {
      final half = bytes.sublist(0, (bytes.length / 2).floor());
      return Uint8List.fromList(half);
    });

Future<Uint8List> b4EncryptXor(Uint8List data, int key) => Isolate.run(
      () => Uint8List.fromList(data.map((b) => b ^ key).toList()),
    );

List<int> b4SearchDocs(List<String> docs, String q) {
  final ql = q.toLowerCase();
  final scored = <MapEntry<int, int>>[];
  for (var i = 0; i < docs.length; i++) {
    final count = docs[i].toLowerCase().split(ql).length - 1;
    if (count > 0) scored.add(MapEntry(i, count));
  }
  scored.sort((a, b) => b.value.compareTo(a.value));
  return scored.take(10).map((e) => e.key).toList();
}

Future<List<int>> b4SearchDocsIsolate(List<String> docs, String q) =>
    Isolate.run(() => b4SearchDocs(docs, q));

void b4WorkerEntry(SendPort send) {
  final rp = ReceivePort();
  send.send(rp.sendPort);
  rp.listen((msg) {
    if (msg is Map) {
      final n = msg['n'] as int;
      final reply = msg['reply'] as SendPort;
      reply.send({'result': heavyCalculation(n)});
    }
  });
}

class B4WorkerPool {
  final List<SendPort> _ports = [];
  var _next = 0;

  Future<void> init(int size) async {
    for (var i = 0; i < size; i++) {
      final rp = ReceivePort();
      await Isolate.spawn(b4WorkerEntry, rp.sendPort);
      _ports.add(await rp.first as SendPort);
    }
  }

  Future<int> run(int n) async {
    if (_ports.isEmpty) throw StateError('Пул не инициализирован');
    final p = _ports[_next++ % _ports.length];
    final reply = ReceivePort();
    p.send({'n': n, 'reply': reply.sendPort});
    final res = await reply.first as Map;
    reply.close();
    return res['result'] as int;
  }
}

Future<void> b4SortCompare() async {
  final arr = List.generate(1000000, (_) => Random().nextInt(1 << 31));
  var sw = Stopwatch()..start();
  List.of(arr)..sort();
  print('Синхронная сортировка: ${sw.elapsedMilliseconds} ms');

  sw = Stopwatch()..start();
  await Isolate.run(() => List.of(arr)..sort());
  print('Сортировка в изоляте: ${sw.elapsedMilliseconds} ms');
}

void b4TransferEntry(SendPort main) {
  final rp = ReceivePort();
  main.send(rp.sendPort);
  rp.listen((msg) {
    if (msg is TransferableTypedData) {
      final len = msg.materialize().asUint8List().length;
      main.send(len);
    }
  });
}

Future<int> b4TransferDemo(Uint8List bytes) async {
  final rp = ReceivePort();
  final iso = await Isolate.spawn(b4TransferEntry, rp.sendPort);
  final sp = await rp.first as SendPort;
  sp.send(TransferableTypedData.fromList([bytes]));
  final len = await rp.first as int;
  rp.close();
  iso.kill();
  return len;
}

// БЛОК 5. СЛОЖНЫЕ АРХИТЕКТУРЫ

class B5CancellationException implements Exception {
  final String message;
  B5CancellationException([this.message = 'Cancelled']);
  @override
  String toString() => message;
}

class B5CancelToken {
  bool _cancelled = false;
  final _completer = Completer<void>();

  bool get isCancelled => _cancelled;
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_cancelled) {
      _cancelled = true;
      _completer.complete();
    }
  }
}

Future<T> b5Cancellable<T>(Future<T> future, B5CancelToken token) {
  return Future.any([
    future,
    token.whenCancelled.then<T>((_) => throw B5CancellationException()),
  ]);
}

class B5CircuitBreaker {
  int _failures = 0;
  DateTime? _openUntil;
  final int threshold;
  final Duration cooldown;

  B5CircuitBreaker({this.threshold = 5, this.cooldown = const Duration(seconds: 30)});

  Future<T> call<T>(Future<T> Function() task) async {
    if (_openUntil != null && DateTime.now().isBefore(_openUntil!)) {
      throw StateError('Circuit open');
    }
    try {
      final r = await task();
      _failures = 0;
      return r;
    } catch (e) {
      _failures++;
      if (_failures >= threshold) {
        _openUntil = DateTime.now().add(cooldown);
        _failures = 0;
      }
      rethrow;
    }
  }
}

class B5LatestSearch {
  int _seq = 0;

  Future<void> search(String q, Future<String> Function(String) request, void Function(String) onResult) async {
    final id = ++_seq;
    final r = await request(q);
    if (id == _seq) onResult(r);
  }
}

sealed class B5SyncState {}
class B5Idle extends B5SyncState {}
class B5Syncing extends B5SyncState {
  final double progress;
  B5Syncing(this.progress);
}
class B5Success extends B5SyncState {}
class B5Error extends B5SyncState {
  final Object error;
  B5Error(this.error);
}

class B5SyncMachine {
  B5SyncState _state = B5Idle();
  final _c = StreamController<B5SyncState>.broadcast();
  Stream<B5SyncState> get stream => _c.stream;

  void _emit(B5SyncState s) {
    _state = s;
    _c.add(s);
  }

  Future<void> sync(Future<void> Function(void Function(double)) job) async {
    if (_state is B5Syncing) return;
    _emit(B5Syncing(0));
    try {
      await job((p) => _emit(B5Syncing(p)));
      _emit(B5Success());
    } catch (e) {
      _emit(B5Error(e));
    }
  }
  void dispose() => _c.close();
}

class B5Quote {
  final DateTime ts;
  final double price;
  B5Quote(this.ts, this.price);
}

Stream<B5Quote> b5WebSocketQuotes() async* {
  final r = Random();
  var p = 100.0;
  while (true) {
    await Future.delayed(const Duration(milliseconds: 16));
    p += (r.nextDouble() - 0.5) * 0.5;
    yield B5Quote(DateTime.now(), p);
  }
}

double b5Volatility(List<double> prices) {
  if (prices.length < 2) return 0;
  final mean = prices.reduce((a, b) => a + b) / prices.length;
  final variance = prices.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / prices.length;
  return sqrt(variance);
}

Stream<T> b5Throttle60fps<T>(Stream<T> src) {
  DateTime? last;
  return src.where((_) {
    final now = DateTime.now();
    if (last == null || now.difference(last!).inMilliseconds >= 16) {
      last = now;
      return true;
    }
    return false;
  });
}

class B5FinancialTerminal {
  final Stream<B5Quote> Function() _connect;
  final _c = StreamController<Map<String, Object>>.broadcast();
  final List<double> _prices = [];
  StreamSubscription<B5Quote>? _sub;
  Timer? _reconnect;
  bool _closed = false;

  B5FinancialTerminal(this._connect) {
    _listen();
  }

  void _listen() {
    _sub = _connect().listen(
      (q) async {
        _prices.add(q.price);
        if (_prices.length > 100) _prices.removeAt(0);
        final snapshot = List<double>.from(_prices);
        final vol = await Isolate.run(() => b5Volatility(snapshot));
        if (!_closed) {
          _c.add({'price': q.price, 'volatility': vol, 'ts': q.ts.toIso8601String()});
        }
      },
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
    );
  }

  void _scheduleReconnect() {
    if (_closed) return;
    _reconnect?.cancel();
    _reconnect = Timer(const Duration(seconds: 2), () {
      if (!_closed) {
        _sub?.cancel();
        _listen();
      }
    });
  }

  Stream<Map<String, Object>> get stream => b5Throttle60fps(_c.stream);

  Future<void> dispose() async {
    _closed = true;
    _reconnect?.cancel();
    await _sub?.cancel();
    await _c.close();
  }
}
