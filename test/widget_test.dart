import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:motoh_business/theme/app_colors.dart';
import 'package:motoh_business/theme/app_theme.dart';

void main() {
  testWidgets('Thème Material 3 Soleil d’Abidjan', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
  });
}
