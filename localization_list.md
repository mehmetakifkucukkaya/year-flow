# Missing Localizations List

This document contains all the hardcoded Turkish/English strings found in the codebase that need to be properly localized.

## 1. Hardcoded Turkish Strings (need localization)

### Home Page
- **Location**: `lib/features/home/presentation/home_page.dart:86`
- **String**: `'Daha sonra'`
- **Suggested Key**: `later`
- **English Translation**: `Later`

- **Location**: `lib/features/home/presentation/home_page.dart:120`
- **String**: `'Kaydet'`
- **Suggested Key**: `save`
- **English Translation**: `Save`

### Error Messages
- **Location**: `lib/core/router/app_router.dart:367`
- **String**: `'Sayfa bulunamadı: ${state.uri.path}'`
- **Suggested Key**: `pageNotFound`
- **English Translation**: `Page not found: {path}`

### Goals Archive Page
- **Location**: `lib/features/goals/presentation/goals_archive_page.dart:63`
- **String**: `'Yeniden Dene'`
- **Suggested Key**: `tryAgain`
- **English Translation**: `Try Again`

- **Location**: `lib/features/goals/presentation/goals_archive_page.dart:537`
- **String**: `'İptal'`
- **Suggested Key**: `cancel`
- **English Translation**: `Cancel`

- **Location**: `lib/features/goals/presentation/goals_archive_page.dart:553`
- **String**: `'Çıkar'`
- **Suggested Key**: `remove`
- **English Translation**: `Remove`

### Goal Detail Page
- **Location**: `lib/features/goals/presentation/goal_detail_page.dart:2090`
- **String**: `'Alt görevi sil'`
- **Suggested Key**: `deleteSubtask`
- **English Translation**: `Delete Subtask`

- **Location**: `lib/features/goals/presentation/goal_detail_page.dart:2091`
- **String**: `'Bu alt görevi silmek istediğine emin misin?'`
- **Suggested Key**: `deleteSubtaskConfirmation`
- **English Translation**: `Are you sure you want to delete this subtask?`

- **Location**: `lib/features/goals/presentation/goal_detail_page.dart:2095`
- **String**: `'İptal'`
- **Suggested Key**: `cancel`
- **English Translation**: `Cancel` (already exists)

- **Location**: `lib/features/goals/presentation/goal_detail_page.dart:3091`
- **String**: `'İptal'`
- **Suggested Key**: `cancel`
- **English Translation**: `Cancel` (already exists)

- **Location**: `lib/features/goals/presentation/goal_detail_page.dart:3107`
- **String**: `'Tamamla'`
- **Suggested Key**: `complete`
- **English Translation**: `Complete`

### Report Detail Page
- **Location**: `lib/features/reports/presentation/report_detail_page.dart:92`
- **String**: `'Raporu sil'`
- **Suggested Key**: `deleteReport`
- **English Translation**: `Delete Report`

- **Location**: `lib/features/reports/presentation/report_detail_page.dart:99`
- **String**: `'Vazgeç'`
- **Suggested Key**: `giveUp` or `cancel`
- **English Translation**: `Cancel` or `Give Up`

- **Location**: `lib/features/reports/presentation/report_detail_page.dart:106`
- **String**: `'Sil'`
- **Suggested Key**: `delete`
- **English Translation**: `Delete`

### AI Optimize Bottom Sheet
- **Location**: `lib/features/goals/presentation/widgets/ai_optimize_bottom_sheet.dart:291`
- **String**: `'Kapat'`
- **Suggested Key**: `close`
- **English Translation**: `Close`

- **Location**: `lib/features/goals/presentation/widgets/ai_optimize_bottom_sheet.dart:307`
- **String**: `'Optimizasyon sonucu bulunamadı'`
- **Suggested Key**: `optimizationResultNotFound`
- **English Translation**: `Optimization result not found`

### Reports Page
- **Location**: `lib/features/reports/presentation/reports_page.dart:1933`
- **String**: `'Yukarıdaki "Rapor Oluştur" butonuna tıklayarak ilk raporunuzu oluşturabilirsiniz.'`
- **Suggested Key**: `createFirstReportInstruction`
- **English Translation**: `You can create your first report by clicking the "Create Report" button above.`

### Goals Page Comments
- **Location**: `lib/features/goals/presentation/goals_page.dart:928`
- **String**: `'Aktiflere taşı'` (in comment)
- **Suggested Key**: `moveToActive`
- **English Translation**: `Move to Active`

## 2. Additional Contextual Strings Found

### Subtasks/Milestones
Based on the code analysis, there are references to subtasks that might need localization:
- **Suggested Key**: `subtask` (English: `Subtask`)
- **Suggested Key**: `milestone` (English: `Milestone`)

### Actions and Verbs
- **Suggested Key**: `archive` (English: `Archive`)
- **Suggested Key**: `unarchive` (English: `Unarchive`)
- **Suggested Key**: `reactivate` (English: `Reactivate`)

## 3. Implementation Steps

1. **Add new keys to `app_en.arb`**:
   - Add all the English translations with proper descriptions
   - Follow the existing pattern with `@key` metadata for descriptions

2. **Add corresponding Turkish translations to `app_tr.arb`**:
   - Add the Turkish translations without descriptions (inherited from English)

3. **Regenerate localization files**:
   - Run `flutter gen-l10n` to update the auto-generated files

4. **Update the code**:
   - Replace hardcoded strings with `context.l10n.keyName` calls
   - Use the extension method in `extensions.dart` for easy access

## 4. Priority Order

### High Priority (User-facing strings)
1. `'Daha sonra'` → `context.l10n.later`
2. `'Kaydet'` → `context.l10n.save`
3. `'Yeniden Dene'` → `context.l10n.tryAgain`
4. `'İptal'` → `context.l10n.cancel`
5. `'Sil'` → `context.l10n.delete`
6. `'Tamamla'` → `context.l10n.complete`

### Medium Priority (Dialog messages)
1. `'Alt görevi sil'` → `context.l10n.deleteSubtask`
2. `'Bu alt görevi silmek istediğine emin misin?'` → `context.l10n.deleteSubtaskConfirmation`
3. `'Raporu sil'` → `context.l10n.deleteReport`

### Low Priority (Error messages and instructions)
1. `'Sayfa bulunamadı: ${state.uri.path}'` → `context.l10n.pageNotFound(state.uri.path)`
2. `'Optimizasyon sonucu bulunamadı'` → `context.l10n.optimizationResultNotFound`
3. `'Yukarıdaki "Rapor Oluştur" butonuna tıklayarak ilk raporunuzu oluşturabilirsiniz.'` → `context.l10n.createFirstReportInstruction`

## 5. Code Example

Before:
```dart
child: const Text('Daha sonra'),
```

After:
```dart
child: Text(context.l10n.later),
```

For parameterized strings:
Before:
```dart
Text('Sayfa bulunamadı: ${state.uri.path}'),
```

After:
```dart
Text(context.l10n.pageNotFound(state.uri.path)),
```

And in `app_en.arb`:
```json
"pageNotFound": "Page not found: {path}",
"@pageNotFound": {
  "description": "Error message shown when a page is not found"
}
```

## 6. Total Count

- **Unique strings to localize**: 15
- **Files to modify**: 7 files
- **New localization keys needed**: 12 unique keys (some strings are duplicates like 'İptal')

Generated on: 2025-12-07
Total hardcoded strings found: 15