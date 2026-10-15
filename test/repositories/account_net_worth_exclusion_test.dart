import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beecount/data/db.dart';
import 'package:beecount/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BeeDatabase db;
  late LocalRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = BeeDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  test('custom account settings persist and excluded balance leaves net worth',
      () async {
    final ledgerId = await repo.createLedger(name: 'Assets');
    await repo.createAccount(
      ledgerId: ledgerId,
      name: 'Included',
      type: 'custom',
      initialBalance: 100,
      backgroundColor: '#6C63FF',
    );
    final excludedId = await repo.createAccount(
      ledgerId: ledgerId,
      name: 'Excluded',
      type: 'custom',
      initialBalance: 50,
      backgroundColor: '#2196F3',
      excludeFromNetWorth: true,
    );

    var total = await repo.getNetWorthBreakdown();
    expect(total.netWorth, 100);
    expect((await repo.getAccount(excludedId))!.backgroundColor, '#2196F3');
    expect((await repo.getAccount(excludedId))!.excludeFromNetWorth, isTrue);

    await repo.updateAccount(excludedId, excludeFromNetWorth: false);
    total = await repo.getNetWorthBreakdown();
    expect(total.netWorth, 150);
  });
}
