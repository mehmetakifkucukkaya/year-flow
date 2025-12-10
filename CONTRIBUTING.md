# 🚀 YearFlow – Contribution Guide

Bu doküman, katkı sürecini kısa ve uygulanabilir adımlarla özetler.

---

## 📌 Branch Stratejisi (Basit Git Flow)

- **Ana branch’ler**

  - `main`: Production/Store’a giden tek branch
  - `develop`: Tüm geliştirme işleri

- **Branch adlandırma**

  - Feature: `feature/<scope>-<kısa-aciklama>`
  - Bugfix: `bugfix/<issueId>-<kısa-aciklama>`
  - Hotfix: `hotfix/<version>-<kısa-aciklama>`

- **Örnekler**

  - `feature/auth-google-signin`
  - `feature/reports-pdf-export`
  - `bugfix/12-google-signin-copy`
  - `bugfix/7-profile-update-navigation`
  - `hotfix/1.0.1-profile-crash`

- **Hotfix akışı**
  1. `main`’e merge
  2. Ardından `develop`’a merge

---

## 🧩 Pull Request Kuralları

- **Başlık**: `Fix #<issueId> – Kısa açıklama`
  - Örnek: `Fix #14 – Incorrect Google Sign-in error message`
- **Açıklama** içermeli:
  - _Closes #<issueId>_
  - Yapılan değişikliklerin özeti
  - Test senaryoları / sonuçları
  - UI değiştiyse ekran görüntüsü
- **Kalite**
  - En az 1 onay şart
  - Commit’ler küçük ve anlamlı olmalı
  - Log/build çıktısı eklenmez

---

## 🧪 Code Review Beklentileri

- Küçük, odaklı değişiklik setleri
- Tasarım değişikliklerinde ekran görüntüsü zorunlu
- Performans/risk notları PR açıklamasına eklenmeli

---

## 📦 Versiyonlama

- Format: `major.minor.patch`
- Örnekler:
  - `1.0.0` → İlk stabil sürüm
  - `1.0.1` → Hata düzeltmesi
  - `1.1.0` → Yeni özellik

---

## ✅ Hızlı Kontrol Listesi

- [ ] Doğru branch adı (feature/…, bugfix/…, hotfix/…)
- [ ] PR başlığı formatı: `Fix #<id> – ...`
- [ ] Açıklamada _Closes #<id>_, özet, testler, gerekiyorsa ekran görüntüsü
- [ ] Log/build dosyası eklenmedi
- [ ] En az 1 review onayı alındı
