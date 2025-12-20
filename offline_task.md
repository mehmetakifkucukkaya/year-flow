# Offline Mode İyileştirme Task'ları

## 🎯 Amaç

Firestore'un native offline özelliğini kullanarak kullanıcı deneyimini iyileştirmek.

## ✅ Mevcut Durum

- Firestore offline persistence **AKTIF** (`main.dart`)
- Tüm CRUD işlemleri zaten offline çalışıyor
- Sadece AI özellikleri internet gerektiriyor

## 🚀 Yapılacaklar

### Task 1: Connectivity Package Kurulumu

**Dosya:** `pubspec.yaml`  
**Süre:** 5 dakika  
**Açıklama:** Network durumu takibi için connectivity_plus paketi ekle

```yaml
dependencies:
  connectivity_plus: ^5.0.2
```

**Komut:**

```bash
flutter pub add connectivity_plus
flutter pub get
```

---

### Task 2: Network Status Banner Widget'ı

**Yeni Dosya:** `lib/core/widgets/network_status_banner.dart`  
**Süre:** 10 dakika  
**Açıklama:** Kullanıcıya offline modda olduğunu bildiren banner widget'ı

**Özellikler:**

- StreamBuilder ile real-time network durumu takibi
- Offline olduğunda turuncu banner göster
- Online olduğunda gizle
- Localization desteği (TR/EN)
- Smooth animations

**İçerik:**

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      initialData: ConnectivityResult.wifi,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectivityResult.none;

        if (!isOffline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Çevrimdışı mod - Değişiklikler internet bağlantısı kurulunca senkronize edilecek',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

### Task 3: Main Layout'a Banner Ekle

**Dosya:** `lib/features/home/presentation/main_layout.dart` veya ana scaffold  
**Süre:** 5 dakika  
**Açıklama:** Network status banner'ı tüm sayfalarda göster

**Değişiklik:**

```dart
// Import ekle
import '../../../core/widgets/network_status_banner.dart';

// Scaffold body'ye ekle
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Network status banner (en üstte)
        const NetworkStatusBanner(),

        // Existing content
        Expanded(
          child: _pages[_currentIndex],
        ),
      ],
    ),
    bottomNavigationBar: _buildBottomNavigationBar(context),
  );
}
```

---

### Task 4: Connectivity Helper Oluştur

**Yeni Dosya:** `lib/core/utils/connectivity_helper.dart`  
**Süre:** 5 dakika  
**Açıklama:** Network durumu kontrol helper'ı

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  const ConnectivityHelper._();

  /// Check if device is online
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Get network status stream
  static Stream<bool> get onlineStatusStream {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

---

### Task 5: Goal Create - Offline Aware Feedback

**Dosya:** `lib/features/goals/presentation/goal_create_page.dart`  
**Süre:** 10 dakika  
**Açıklama:** Kaydetme sonrası online/offline duruma göre farklı mesaj göster

**Import ekle:**

```dart
import '../../../core/utils/connectivity_helper.dart';
```

**\_handleSave metodunu güncelle:**

```dart
Future<void> _handleSave() async {
  // ... existing validation ...

  setState(() => _isSaving = true);

  try {
    final repository = ref.read(goalRepositoryProvider);
    final goal = Goal(...); // existing goal creation

    await repository.createGoal(goal);

    if (mounted) {
      ref.invalidate(goalsStreamProvider);

      // Check if online
      final isOnline = await ConnectivityHelper.isOnline();

      // Show appropriate message
      FeedbackHelper.showSuccess(
        context,
        isOnline
          ? context.l10n.goalCreatedSuccess
          : 'Hedef kaydedildi. İnternet bağlantısı kurulunca senkronize edilecek.',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.pop();
      }
    }
  } catch (e, stackTrace) {
    // ... existing error handling ...
  }
}
```

---

### Task 6: Goal Edit - Offline Aware Feedback

**Dosya:** `lib/features/goals/presentation/goal_edit_page.dart`  
**Süre:** 10 dakika  
**Açıklama:** Güncelleme sonrası online/offline duruma göre farklı mesaj göster

**Aynı değişiklikleri uygula:**

- ConnectivityHelper import et
- \_handleSave metodunda online check yap
- Farklı mesaj göster

---

### Task 7: Localization - Offline Mesajları Ekle

**Dosyalar:**

- `lib/l10n/app_en.arb`
- `lib/l10n/app_tr.arb`

**Süre:** 5 dakika  
**Açıklama:** Offline mesajları için çeviri ekle

**app_tr.arb:**

```json
{
  "offlineModeActive": "Çevrimdışı mod aktif",
  "changesSyncWhenOnline": "Değişiklikler internet bağlantısı kurulunca senkronize edilecek",
  "goalSavedOffline": "Hedef kaydedildi. İnternet bağlantısı kurulunca senkronize edilecek."
}
```

**app_en.arb:**

```json
{
  "offlineModeActive": "Offline mode active",
  "changesSyncWhenOnline": "Changes will sync when online",
  "goalSavedOffline": "Goal saved. Will sync when internet connection is established."
}
```

---

### Task 8: AI Özelliklerinde İnternet Kontrolü

**Dosyalar:**

- `lib/features/goals/presentation/goal_create_page.dart` (\_handleAIOptimize)
- `lib/features/goals/presentation/goal_edit_page.dart` (\_handleAIOptimize)
- `lib/features/goals/presentation/goal_detail_page.dart` (\_suggestSubGoalsWithAI)

**Süre:** 15 dakika  
**Açıklama:** AI özelliklerini kullanmadan önce internet kontrolü yap

**Örnek (\_handleAIOptimize):**

```dart
Future<void> _handleAIOptimize() async {
  // Önce internet kontrolü
  final isOnline = await ConnectivityHelper.isOnline();

  if (!isOnline) {
    if (mounted) {
      FeedbackHelper.showWarning(
        context,
        'Bu özellik internet bağlantısı gerektirir. Lütfen bağlantınızı kontrol edin.',
      );
    }
    return;
  }

  // ... existing AI optimization logic ...
}
```

---

## 📊 Test Senaryoları

### Senaryo 1: Offline Hedef Oluşturma

1. Uçak modunu aç
2. Yeni hedef oluştur
3. ✅ Turuncu banner görünmeli
4. ✅ "Hedef kaydedildi. Senkronize edilecek" mesajı
5. ✅ Goals listesinde görünmeli
6. İnterneti aç
7. ✅ Banner kaybolmalı
8. ✅ Otomatik sync olmalı

### Senaryo 2: Online Hedef Oluşturma

1. İnternet açık
2. Yeni hedef oluştur
3. ✅ Banner görünmemeli
4. ✅ "Hedef başarıyla oluşturuldu" mesajı
5. ✅ Goals listesinde görünmeli

### Senaryo 3: Offline AI Özelliği

1. Uçak modunu aç
2. "AI ile Optimize Et" butonuna bas
3. ✅ "Bu özellik internet gerektirir" uyarısı
4. ✅ AI modal açılmamalı

### Senaryo 4: Network Geçişi

1. İnternet açık → Hedef oluştur (banner yok)
2. İnterneti kapat → Banner belirir
3. Hedef düzenle → Offline mesajı
4. İnterneti aç → Banner kaybolur
5. ✅ Smooth transitions

---

## 📝 Notlar

### Firestore Offline Nasıl Çalışır?

1. **Write**: Önce local cache → Kuyrukta tutar → İnternet gelince sync
2. **Read**: Önce cache → Sonra sunucu (fresh data)
3. **Conflict**: Google'ın CRDT algoritması otomatik çözer

### Avantajlar

- ✅ Sıfır kod - Zaten aktif
- ✅ Otomatik sync
- ✅ Battery friendly
- ✅ Production ready
- ✅ Google'ın 10 yıllık tecrübesi

### Dikkat Edilmesi Gerekenler

- AI özellikleri **mutlaka** online check yapmalı
- Feedback mesajları kullanıcıyı bilgilendirmeli
- Banner çok yer kaplamamalı (tek satır, küçük)
- Smooth animations olmalı

---

## 🎯 Öncelik Sırası

1. **P0 (Kritik):**

   - Task 1: Connectivity package ekle
   - Task 2: Network status banner
   - Task 3: Main layout'a banner ekle

2. **P1 (Yüksek):**

   - Task 4: Connectivity helper
   - Task 5-6: Offline aware feedback
   - Task 8: AI internet kontrolü

3. **P2 (Orta):**
   - Task 7: Localization

---

## ⏱️ Tahmini Süre

| Task                | Süre       |
| ------------------- | ---------- |
| Task 1-3 (Banner)   | 20 dk      |
| Task 4 (Helper)     | 5 dk       |
| Task 5-6 (Feedback) | 20 dk      |
| Task 7 (L10n)       | 5 dk       |
| Task 8 (AI Check)   | 15 dk      |
| **Toplam**          | **~65 dk** |

---

## ✅ Tamamlandığında

- [ ] Network banner çalışıyor
- [ ] Offline/Online mesajlar gösteriliyor
- [ ] AI özellikleri internet kontrolü yapıyor
- [ ] Tüm test senaryoları geçti
- [ ] Hem TR hem EN dil desteği var

---

**Son Güncelleme:** 20 Aralık 2025  
**Durum:** Hazır - Uygulamaya geçilebilir
