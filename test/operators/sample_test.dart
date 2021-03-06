library rx.test.operators.sample;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() => new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(5);
Stream _getSampleStream() => new Stream<int>.periodic(const Duration(milliseconds: 35), (int count) => count).take(5);

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(100 / 0); // throw!!!
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.sample', () async {
    const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
    int count = 0;

    rx.observable(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .sample(_getSampleStream());

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.sample.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getErroneousStream())
        .sample(_getSampleStream());

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}