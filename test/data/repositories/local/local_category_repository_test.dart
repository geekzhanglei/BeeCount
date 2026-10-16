// 分类「跨类型同名」判重契约测试。
//
// 锁死:分类按 (name, kind) 联合唯一 —— 同 kind 内禁止重名,跨 kind 允许同名。

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beecount/data/db.dart';
import 'package:beecount/data/repositories/local/local_repository.dart';
import 'package:beecount/data/repositories/exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BeeDatabase db;
  late LocalRepository repo;

  setUp(() async {
    db = BeeDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('分类跨类型同名 (name, kind)', () {
    test('跨 kind 同名分类可共存(收入红包 + 支出红包)', () async {
      final inc = await repo.createCategory(name: '红包', kind: 'income');
      final exp = await repo.createCategory(name: '红包', kind: 'expense');
      expect(inc, isNot(exp));
    });

    test('同 kind 重名抛 DuplicateNameException', () async {
      await repo.createCategory(name: '红包', kind: 'expense');
      expect(
        () => repo.createCategory(name: '红包', kind: 'expense'),
        throwsA(isA<DuplicateNameException>()),
      );
    });

    test('isCategoryNameDuplicate 按 (name, kind) 判定', () async {
      await repo.createCategory(name: '红包', kind: 'expense');
      expect(
        await repo.isCategoryNameDuplicate(name: '红包', kind: 'expense'),
        isTrue,
      );
      expect(
        await repo.isCategoryNameDuplicate(name: '红包', kind: 'income'),
        isFalse,
      );
    });

    test('upsertCategory 跨 kind 不误复用、同 kind 复用', () async {
      final a = await repo.upsertCategory(name: '红包', kind: 'income');
      final b = await repo.upsertCategory(name: '红包', kind: 'expense');
      expect(a, isNot(b)); // 跨 kind → 建两个独立分类
      final aAgain = await repo.upsertCategory(name: '红包', kind: 'income');
      expect(aAgain, a); // 同 kind → 复用
    });

    test('createSubCategory 跨 kind 同名子分类可共存', () async {
      final pInc = await repo.createCategory(name: '工资', kind: 'income');
      final pExp = await repo.createCategory(name: '餐饮', kind: 'expense');
      final subInc =
          await repo.createSubCategory(parentId: pInc, name: '红包', kind: 'income');
      final subExp =
          await repo.createSubCategory(parentId: pExp, name: '红包', kind: 'expense');
      expect(subInc, isNot(subExp));
    });

    test('createSubCategory 同 kind 重名抛 DuplicateNameException(二级也按 name+kind 全局唯一)',
        () async {
      final p = await repo.createCategory(name: '餐饮', kind: 'expense');
      await repo.createSubCategory(parentId: p, name: '午餐', kind: 'expense');
      expect(
        () => repo.createSubCategory(parentId: p, name: '午餐', kind: 'expense'),
        throwsA(isA<DuplicateNameException>()),
      );
    });
  });

  test('管理页与记账选择器共享一级分类顺序和转账项', () async {
    final firstId = await repo.createCategory(
      name: '餐饮',
      kind: 'expense',
      sortOrder: 0,
    );
    final secondId = await repo.createCategory(
      name: '交通',
      kind: 'expense',
      sortOrder: 0,
    );
    await repo.createCategory(
      name: '转账',
      kind: 'transfer',
      sortOrder: -1,
    );

    final topLevel = await repo.getTopLevelCategories('expense');
    expect(topLevel.map((category) => category.id), [firstId, secondId]);

    final managed = await repo.watchCategoriesWithCount().first;
    expect(managed.any((item) => item.category.kind == 'transfer'), isTrue);
  });
}
