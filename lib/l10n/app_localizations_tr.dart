// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'YearFlow';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldin!';

  @override
  String get continueYourJourney => 'Yolculuğuna Devam Et';

  @override
  String get startYourGrowthJourney => 'Gelişim Yolculuğuna Başla';

  @override
  String get email => 'E-posta';

  @override
  String get emailHint => 'E-posta adresinizi girin';

  @override
  String get emailRequired => 'E-posta adresi gereklidir';

  @override
  String get emailInvalid => 'Geçerli bir e-posta adresi girin';

  @override
  String get password => 'Şifre';

  @override
  String get passwordHint => 'Şifrenizi girin';

  @override
  String get passwordRequired => 'Şifre gereklidir';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalı';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get or => 'veya';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get googleAuthFailed =>
      'Google ile giriş / kayıt ol işlemi yapılamadı.';

  @override
  String get googleAuthCancelled => 'Google ile giriş iptal edildi.';

  @override
  String get noAccount => 'Hesabın yok mu? ';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get name => 'İsim';

  @override
  String get nameHint => 'Adınızı ve soyadınızı girin';

  @override
  String get nameRequired => 'İsim gereklidir';

  @override
  String get nameMinLength => 'İsim en az 2 karakter olmalıdır';

  @override
  String get createPassword => 'Şifrenizi oluşturun';

  @override
  String get welcome => 'Hoş geldiniz! 🎉';

  @override
  String get signInSuccess => 'Giriş başarılı! Hoş geldiniz 👋';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get goals => 'Hedefler';

  @override
  String get reports => 'Raporlar';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Hesap ve uygulama ayarları';

  @override
  String get user => 'Kullanıcı';

  @override
  String get skip => 'Atla';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get getStarted => 'Hemen Başla';

  @override
  String get later => 'Daha sonra';

  @override
  String get save => 'Kaydet';

  @override
  String get nameSaved => 'İsmin kaydedildi';

  @override
  String get setYourName => 'İsmini belirleyelim';

  @override
  String get setYourNameDescription =>
      'Sana ekranda adınla hitap edelim. İstemezsen bu adımı her zaman profilinden değiştirebilirsin.';

  @override
  String get yearlyPerformanceSummary => 'Yıllık performans özetin';

  @override
  String get downloadReport => 'Raporu indir';

  @override
  String get yourYearlyReport2025 => '2025 Yıllık Raporun';

  @override
  String get letsTakeOverview => 'Yolculuğuna genel bir bakış atalım';

  @override
  String get openReport => 'Raporu Aç';

  @override
  String get createReport => 'Rapor Oluştur';

  @override
  String get greatYear => 'Harika bir yıl geçirdin 🎉';

  @override
  String get goodProgress => 'İyi bir ilerleme kaydettin! 💪';

  @override
  String get continueJourney => 'Yolculuğuna devam et! 🌱';

  @override
  String errorLoadingData(String error) {
    return 'Veriler yüklenirken hata oluştu: $error';
  }

  @override
  String get overview => 'Genel Bakış';

  @override
  String get totalGoals => 'Toplam Hedef';

  @override
  String get completionRate => 'Tamamlanma Oranı';

  @override
  String get checkIn => 'Check-in';

  @override
  String get averageProgress => 'Ortalama İlerleme';

  @override
  String get yearlyProgress => 'Yıllık İlerleme';

  @override
  String get noCategoryData => 'Henüz kategori bazlı veri yok';

  @override
  String get categoryBasedDevelopment => 'Kategori Bazlı Gelişim';

  @override
  String get noAchievementData =>
      'Henüz başarı hikayesi oluşturacak kadar veri yok. Hedefler ekleyip check-in yaptıkça burada gelişimini göreceksin.';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'İngilizce';

  @override
  String yourYearlyReport(int year) {
    return '$year Yıllık Raporun';
  }

  @override
  String get achievements => 'Başarılar';

  @override
  String thisYearWorkedOnGoals(
      int totalGoals, int completedGoals, int completionRate) {
    return 'Bu yıl toplam $totalGoals hedef üzerinde çalıştın ve $completedGoals hedefi tamamladın (tamamlanma oranı yaklaşık %$completionRate).';
  }

  @override
  String averageProgressLevel(int progress) {
    return 'Tüm hedefler arasında ortalama ilerleme düzeyin %$progress civarında; bu, yıl boyunca istikrarlı bir şekilde adım attığını gösteriyor.';
  }

  @override
  String strongestProgressInCategory(String category, int value) {
    return '\"$category\" kategorisinde yaklaşık %$value ile en güçlü ilerlemeyi gösterdin';
  }

  @override
  String reachedLevelInCategory(int value, String category) {
    return ', \"$category\" kategorisinde ise yaklaşık %$value seviyesine ulaştın.';
  }

  @override
  String get aiSuggestions => 'AI Önerileri';

  @override
  String get aiSuggestionExample =>
      'Kişisel gelişim hedeflerindeki ilerlemen harika! Gelecek yıl, büyük kariyer hedeflerini daha küçük, yönetilebilir adımlara bölerek tamamlanma oranını artırabilirsin. Ayrıca, finansal okuryazarlık üzerine bir hedef eklemek genel başarını destekleyebilir.';

  @override
  String get loginRequired => 'Giriş yapmanız gerekiyor';

  @override
  String get reportExportedSuccessfully => 'Rapor başarıyla export edildi';

  @override
  String get exportReport => 'Raporu Dışa Aktar';

  @override
  String get selectFormat => 'Format seçin:';

  @override
  String get json => 'JSON';

  @override
  String get csv => 'CSV';

  @override
  String get atLeastOneGoalRequired =>
      'Rapor oluşturmak için en az bir hedef gerekli';

  @override
  String errorCreatingReport(String error) {
    return 'Rapor oluşturulurken hata: $error';
  }

  @override
  String get selectReportType => 'Rapor türünü seçin:';

  @override
  String get thisWeekSummary => 'Bu haftanın özeti';

  @override
  String get thisMonthSummary => 'Bu ayın özeti';

  @override
  String get thisYearSummary => 'Bu yılın özeti';

  @override
  String get challengesAndSolutions => 'Zorluklar ve çözümler:';

  @override
  String challengeLowProgress(String category, int value) {
    return 'Zorluk: \"$category\" kategorisinde ilerleme görece düşük (yaklaşık %$value).';
  }

  @override
  String get solutionAddActions =>
      'Çözüm: Bu alanda haftaya 1–2 küçük, net aksiyon ekleyip check-in sıklığını artırmayı deneyebilirsin.';

  @override
  String challengeFocusDifficulty(String category, int value) {
    return 'Zorluk: \"$category\" hedeflerine odaklanmakta zorlanıyor olabilirsin (yaklaşık %$value).';
  }

  @override
  String get solutionBreakDownGoals =>
      'Çözüm: Bu hedefleri daha küçük adımlara bölmek ve haftalık olarak gözden geçirmek odaklanmayı artırabilir.';

  @override
  String get generalStatusHealthy =>
      'Genel durum: Tüm kategorilerde sağlıklı bir ilerleme var.';

  @override
  String get solutionReviewPriorities =>
      'Çözüm: Yine de, motivasyonunu korumak için haftalık olarak önceliklerini gözden geçirmek iyi bir fikir olabilir.';

  @override
  String get goalAndCheckInDataNeeded =>
      'Hedef ve check-in verilerin oluştukça, zorlandığın alanlar ve iyileştirme önerileri burada görünecek.';

  @override
  String get january => 'Ocak';

  @override
  String get february => 'Şubat';

  @override
  String get march => 'Mart';

  @override
  String get april => 'Nisan';

  @override
  String get may => 'Mayıs';

  @override
  String get june => 'Haziran';

  @override
  String get july => 'Temmuz';

  @override
  String get august => 'Ağustos';

  @override
  String get september => 'Eylül';

  @override
  String get october => 'Ekim';

  @override
  String get november => 'Kasım';

  @override
  String get december => 'Aralık';

  @override
  String get active => 'Aktif';

  @override
  String get completed => 'Yapılanlar:';

  @override
  String get myGoals => 'Hedeflerim';

  @override
  String get yourSuccessJourney => 'Başarı yolculuğun';

  @override
  String get sort => 'Sırala';

  @override
  String get filter => 'Filtrele';

  @override
  String get newest => 'En Yeni';

  @override
  String get oldest => 'En Eski';

  @override
  String get progressHigh => 'İlerleme (Yüksek)';

  @override
  String get progressLow => 'İlerleme (Düşük)';

  @override
  String get titleAsc => 'Başlık (A-Z)';

  @override
  String get titleDesc => 'Başlık (Z-A)';

  @override
  String get all => 'Tümü';

  @override
  String get health => 'Sağlık';

  @override
  String get mentalHealth => 'Ruh Sağlığı';

  @override
  String get finance => 'Finans';

  @override
  String get career => 'Kariyer';

  @override
  String get relationships => 'İlişkiler';

  @override
  String get learning => 'Öğrenme';

  @override
  String get creativity => 'Yaratıcılık';

  @override
  String get hobby => 'Hobi';

  @override
  String get personalGrowth => 'Kişisel Gelişim';

  @override
  String get noCompletedGoals => 'Henüz tamamlanan hedef yok';

  @override
  String get completedGoalsWillAppear =>
      'Hedeflerini tamamladıkça burada gözükecekler';

  @override
  String get goalsLoadingError => 'Hedefler yüklenirken bir hata oluştu.';

  @override
  String get tryAgain => 'Yeniden Dene';

  @override
  String get reactivateGoal => 'Hedefi tekrar aktifleştir';

  @override
  String reactivateGoalDescription(String goalTitle) {
    return '\"$goalTitle\" hedefini tamamlananlardan çıkarıp tekrar aktif hedefler listesine almak istiyor musun?';
  }

  @override
  String get moveToActive => 'Aktiflere Taşı';

  @override
  String get cancel => 'İptal';

  @override
  String get moveToActiveTooltip => 'Aktif hedeflere geri al';

  @override
  String get mustSignInToPerformAction =>
      'Bu işlemi yapmak için giriş yapmalısın.';

  @override
  String get notificationsComingSoon => 'Bildirimler yakında eklenecek';

  @override
  String get yourGoals => 'Hedeflerin';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get hello => 'Merhaba';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get weeklySummary => 'Haftalık özet';

  @override
  String thisWeekCheckIns(int checkInCount, int goalsWithProgress) {
    return 'Bu hafta toplam $checkInCount check-in ile $goalsWithProgress farklı hedefte ilerleme kaydettin.';
  }

  @override
  String get weeklySummaryError =>
      'Bu haftanın özeti şu an yüklenemedi. Birazdan tekrar dene.';

  @override
  String get howIsTodayGoing => 'Bugün nasıl geçiyor?';

  @override
  String get targetDateNotSpecified => 'Hedef tarihi belirtilmemiş';

  @override
  String daysOverdue(int days) {
    return '$days gün gecikti';
  }

  @override
  String get oneDayOverdue => '1 gün gecikti';

  @override
  String get today => 'Bugün';

  @override
  String get oneDayLeft => '1 gün kaldı';

  @override
  String daysLeft(int days) {
    return '$days gün kaldı';
  }

  @override
  String inDays(int days) {
    return '$days gün sonra';
  }

  @override
  String reportsLoadingError(String error) {
    return 'Raporlar yüklenirken hata oluştu: $error';
  }

  @override
  String get noReportsYet => 'Henüz rapor oluşturulmamış';

  @override
  String get createFirstReport =>
      'Yukarıdaki \"Rapor Oluştur\" butonuna tıklayarak ilk raporunuzu oluşturabilirsiniz.';

  @override
  String get pastReports => 'Geçmiş Raporlar';

  @override
  String get goalMovedToActive => 'Hedef tekrar aktifler listesine taşındı.';

  @override
  String errorUpdatingGoal(String error) {
    return 'Hedef güncellenirken bir hata oluştu: $error';
  }

  @override
  String get noCheckInYet => 'Henüz Check-in yok';

  @override
  String get yesterday => 'Dün';

  @override
  String daysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String weeksAgo(int weeks) {
    return '$weeks hafta önce';
  }

  @override
  String get loading => 'Yükleniyor...';

  @override
  String lastCheckIn(String date) {
    return 'Son Check-in: $date';
  }

  @override
  String get noGoalsYet => 'Henüz hedef eklemedin';

  @override
  String get startJourneyWithGoal =>
      'Yeni bir hedef ekleyerek başarı yolculuğuna başla';

  @override
  String get addNewGoal => 'Yeni Hedef Ekle';

  @override
  String get noGoalCreatedYet => 'Henüz hedef oluşturmadın';

  @override
  String get createFirstGoal =>
      'İlk hedefini oluştur ve yılını daha planlı, odaklı ve anlamlı hale getir.';

  @override
  String get createGoal => 'Hedef Oluştur';

  @override
  String get doCheckIn => 'Check-in Yap';

  @override
  String tasksRemaining(int count) {
    return '$count görev kaldı';
  }

  @override
  String checkInCount(int count) {
    return '$count check-in';
  }

  @override
  String reportTypeLabel(String type, String period) {
    return '$type Rapor - $period';
  }

  @override
  String get onboardingSlide1Title => 'Bu yıl hedeflerini somutlaştır.';

  @override
  String get onboardingSlide1Description =>
      'YearFlow ile hayallerini gerçeğe dönüştür. Ulaşılabilir adımlarla büyük hedeflerine doğru ilerle.';

  @override
  String get onboardingSlide2Title =>
      'Düzenli ilerlemelerle yolculuğunu takip et.';

  @override
  String get onboardingSlide2Description =>
      'Aylık check-in\'lerle hedeflerindeki ilerlemeyi kaydet, motivasyonunu koru ve başarılarını kutla.';

  @override
  String get onboardingSlide3Title =>
      'Yıl sonunda kişisel gelişim raporunu al.';

  @override
  String get onboardingSlide3Description =>
      'AI destekli raporlarla yıl boyunca kaydettiğin ilerlemeyi gör, somut verilerle gelişimini anla ve yeni hedefler için ilham al.';

  @override
  String get onboardingWelcomeTitle => 'Hedeflerini gerçekleştir.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Hayallerini gerçeğe dönüştür, adım adım.';

  @override
  String get onboardingFeature1Title => 'Yolculuğunu takip et';

  @override
  String get onboardingFeature1Subtitle =>
      'Aylık check-in\'lerle ilerlemeni gör ve hedeflerine odaklan.';

  @override
  String get onboardingFeature2Title => 'Her başarıyı kutla';

  @override
  String get onboardingFeature2Subtitle =>
      'Görsel ilerleme ve kilometre taşları seni motive etmeye devam eder.';

  @override
  String get onboardingFeature3Title => 'AI destekli raporlarla büyümeni gör.';

  @override
  String get onboardingFeature3Subtitle =>
      'Yıllık özetler ve veri odaklı içgörüler.';

  @override
  String get onboardingEndTitle => 'Yolculuğuna başlamaya hazır mısın?';

  @override
  String get onboardingEndSubtitle => 'Hedeflerini başarılara dönüştürelim.';

  @override
  String get letsStart => 'Başlayalım';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabın var mı? ';

  @override
  String get continueWithGoogleRegister => 'Google ile kayıt ol / devam et';

  @override
  String get forgotPasswordTitle => 'Şifreni mi unuttun?';

  @override
  String get forgotPasswordDescription =>
      'Şifrenizi sıfırlamak için kayıtlı e-posta adresinizi girin.';

  @override
  String get emailAddress => 'E-posta Adresi';

  @override
  String get emailAddressHint => 'E-posta Adresiniz';

  @override
  String get resetPassword => 'Şifre Sıfırla';

  @override
  String get emailSent => 'E-posta gönderildi!';

  @override
  String resetLinkSent(String email) {
    return 'Şifre sıfırlama bağlantısı $email adresine gönderildi.';
  }

  @override
  String get newGoal => 'Yeni Hedef Ekle';

  @override
  String get editGoal => 'Hedefi Düzenle';

  @override
  String get goalCreatedSuccess => 'Hedef başarıyla oluşturuldu! 🎉';

  @override
  String get goalUpdatedSuccess => 'Hedef güncellendi! ✅';

  @override
  String get goalOptimizedSuccess => 'Hedef optimize edildi! ✨';

  @override
  String get optimizeWithAI => 'AI ile Optimize Et';

  @override
  String get update => 'Güncelle';

  @override
  String get goalNotFound => 'Hedef bulunamadı';

  @override
  String errorCreatingGoal(String error) {
    return 'Hedef oluşturulurken bir hata oluştu: $error';
  }

  @override
  String get pleaseFillAllFields => 'Lütfen formdaki tüm alanları doldurun';

  @override
  String get pleaseSelectCategory => 'Lütfen bir kategori seçin';

  @override
  String get pleaseSelectCompletionDate => 'Lütfen tamamlanma tarihi seçin';

  @override
  String get pleaseExplainWhy =>
      'Lütfen bu hedefi neden istediğinizi açıklayın';

  @override
  String get goalCreated => 'Hedef Oluşturuldu';

  @override
  String checkInCompleted(int score) {
    return 'Check-in Yapıldı: Skor $score/10';
  }

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get expired => 'Süresi doldu';

  @override
  String get tomorrow => 'Yarın';

  @override
  String errorLoadingGoal(String error) {
    return 'Hedef yüklenirken hata oluştu: $error';
  }

  @override
  String errorLoadingCheckIns(String error) {
    return 'Check-in\'ler yüklenirken hata: $error';
  }

  @override
  String get checkInSaved => 'Check-in kaydedildi! ✅';

  @override
  String get goalCompleted => 'Hedef tamamlandı! 🎉';

  @override
  String errorCompletingGoal(String error) {
    return 'Hedef tamamlanırken hata oluştu: $error';
  }

  @override
  String get completeGoal => 'Hedefi Tamamla';

  @override
  String get goalDeletedSuccess => 'Hedef başarıyla silindi';

  @override
  String errorDeletingGoal(String error) {
    return 'Hedef silinirken hata oluştu: $error';
  }

  @override
  String get deleteGoal => 'Hedefi Sil';

  @override
  String get goalCompletedTitle => 'Hedef Tamamlandı 🎉';

  @override
  String get progressRecorded => 'İlerleme Kaydedildi';

  @override
  String nextCheckIn(String date) {
    return 'Sonraki Check-in: $date';
  }

  @override
  String get timeline => 'Timeline';

  @override
  String get notes => 'Notlar';

  @override
  String get subTasks => 'Alt Görevler';

  @override
  String get creatingIndex => 'Index Oluşturuluyor';

  @override
  String get errorLoadingNotes => 'Notlar Yüklenirken Hata';

  @override
  String get firestoreIndexNotReady =>
      'Firestore index\'i henüz hazır değil. Lütfen birkaç dakika bekleyin ve tekrar deneyin.';

  @override
  String tasksLeft(int count) {
    return '$count görev kaldı';
  }

  @override
  String get todayCheckIn => 'Bugün';

  @override
  String get yesterdayCheckIn => 'Dün';

  @override
  String daysAgoCheckIn(int days) {
    return '$days gün önce';
  }

  @override
  String weeksAgoCheckIn(int weeks) {
    return '$weeks hafta önce';
  }

  @override
  String get reportSummaryThisWeek => 'Bu haftanın özeti';

  @override
  String get reportSummaryThisMonth => 'Bu ayın özeti';

  @override
  String get reportSummaryThisYear => 'Bu yılın özeti';

  @override
  String reportErrorLoading(String error) {
    return 'Raporlar yüklenirken hata oluştu: $error';
  }

  @override
  String get createYourFirstReport =>
      'Yukarıdaki \"Rapor Oluştur\" butonuna tıklayarak ilk raporunuzu oluşturabilirsiniz.';

  @override
  String get reportTypeWeekly => 'Haftalık Rapor';

  @override
  String get reportTypeMonthly => 'Aylık Rapor';

  @override
  String get reportTypeYearly => 'Yıllık Rapor';

  @override
  String get solutionIncreaseCheckIns =>
      'Çözüm: Bu alanda haftaya 1–2 küçük, net aksiyon ekleyip check-in sıklığını artırmayı deneyebilirsin.';

  @override
  String challengeDifficultyFocusing(String category, int value) {
    return 'Zorluk: \"$category\" hedeflerine odaklanmakta zorlanıyor olabilirsin (yaklaşık %$value).';
  }

  @override
  String get generalStatusHealthyProgress =>
      'Genel durum: Tüm kategorilerde sağlıklı bir ilerleme var.';

  @override
  String reportTitle(String reportType, String period) {
    return '$reportType Rapor - $period';
  }

  @override
  String get applicationSettings => 'Uygulama Ayarları';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get upcomingCheckIns => 'Yaklaşan Check-in\'ler';

  @override
  String get noUpcomingCheckIns => 'Bu hafta için yaklaşan check-in yok.';

  @override
  String get allGoalsCompleted => 'Tüm hedefler tamamlandı! 🎉';

  @override
  String get allGoalsCompletedDescription =>
      'Bu hafta için tüm hedeflerini tamamladın. Yeni hedefler belirleme veya ilerlemenin tadını çıkarma zamanı!';

  @override
  String get viewAllGoals => 'Tüm Hedefleri Görüntüle';

  @override
  String get weeklySummaryTitle => 'Haftalık Özet';

  @override
  String get weeklySummaryDescription => 'Bu haftaki ilerlemen';

  @override
  String get weeklySummaryNoData =>
      'Bu hafta için henüz veri yok. İlerlemeni görmek için hedefler eklemeye ve check-in yapmaya başla!';

  @override
  String get namePromptTitle => 'İsmini belirleyelim';

  @override
  String get namePromptDescription =>
      'Sana ekranda adınla hitap edelim. İstemezsen bu adımı her zaman profilinden değiştirebilirsin.';

  @override
  String get namePromptSave => 'Kaydet';

  @override
  String get namePromptLater => 'Daha sonra';

  @override
  String get namePromptNameSaved => 'İsmin kaydedildi';

  @override
  String get profile => 'Profil';

  @override
  String get annualReport => 'Yıllık Rapor';

  @override
  String get weeklyReportTitle => 'Haftalık Rapor';

  @override
  String get monthlyReportTitle => 'Aylık Rapor';

  @override
  String get yearlyReportTitle => 'Yıllık Rapor';

  @override
  String get accountInformation => 'Hesap Bilgileri';

  @override
  String get edit => 'Düzenle';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get upcomingCheckInsDescription =>
      '7 günden az kalmış hedeflerin check-in\'lerini yap';

  @override
  String get questionOfTheDay => 'GÜNÜN SORUSU';

  @override
  String get questionOfTheDayText =>
      'Bugün hedeflerine ulaşmak için seni motive eden en büyük şey neydi?';

  @override
  String get writeYourAnswer => 'Yanıtını Yaz';

  @override
  String get monthly => 'Aylık';

  @override
  String get weekly => 'Haftalık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get data => 'Veriler';

  @override
  String get downloadAllMyData => 'Tüm verilerimi indir';

  @override
  String get restoreFromBackup => 'Yedekten geri yükle';

  @override
  String get securityAndSupport => 'Güvenlik ve Destek';

  @override
  String get privacyAndSecurity => 'Gizlilik & Güvenlik';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get logOutTitle => 'Çıkış Yap';

  @override
  String get logOutConfirmation =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get restoreFromBackupTitle => 'Yedekten Geri Yükle';

  @override
  String get restoreFromBackupWarning =>
      'Seçtiğin yedek dosyası, şu anki tüm hedef ve rapor verilerini silecek ve yerlerine yedekteki verileri koyacaktır.\n\nBu işlem geri alınamaz. Devam etmek istediğine emin misin?';

  @override
  String get yesContinue => 'Evet, devam et';

  @override
  String get changePassword => 'Şifreyi Değiştir';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get newPasswordRepeat => 'Yeni Şifre (Tekrar)';

  @override
  String get passwordsDoNotMatch => 'Yeni şifreler eşleşmiyor';

  @override
  String get passwordChangedSuccess => 'Şifre başarıyla değiştirildi';

  @override
  String get wrongPassword => 'Mevcut şifre yanlış';

  @override
  String get exportAllData => 'Tüm Verileri Dışa Aktar';

  @override
  String get exportDataFormatQuestion =>
      'Verilerini hangi formatta kaydetmek istersin?';

  @override
  String get tableCsv => 'Tablo (CSV)';

  @override
  String get advancedJson => 'Gelişmiş (JSON)';

  @override
  String get enterCurrentPassword => 'Mevcut şifrenizi girin';

  @override
  String get enterNewPassword => 'Yeni şifrenizi girin';

  @override
  String get reEnterNewPassword => 'Yeni şifrenizi tekrar girin';

  @override
  String get passwordsMismatch => 'Şifreler eşleşmiyor';

  @override
  String get backupImportedSuccess =>
      'Yedek başarıyla içe aktarıldı. Hedefler ekranını yenileyerek kontrol edebilirsin.';

  @override
  String get exportCompleted =>
      'Yedekleme tamamlandı. Dosyalar > İndirilenler klasöründen ulaşabilirsin.';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get emailCannotBeChanged => 'E-posta adresi değiştirilemez';

  @override
  String get profileUpdatedSuccess => 'Profil bilgileri güncellendi';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirmation =>
      'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get accountDeletedSuccess => 'Hesabınız başarıyla silindi';

  @override
  String get errorDeletingAccount => 'Hesap silinirken hata oluştu';

  @override
  String get privacyTitle => 'Verilerin Senin Kontrolünde';

  @override
  String get privacyDescription =>
      'YearFlow, Hedef, Check-in ve Rapor verilerini KVKK ve ilgili veri koruma mevzuatına uygun şekilde işler. Kişisel verilerin reklam amaçlı üçüncü kişilerle paylaşılmaz; yalnızca uygulama deneyimini geliştirmek, kişiselleştirilmiş içerik üretmek ve ürün analitiği yapmak için kullanılır. Dilediğin zaman verilerini indirip inceleyebilir veya hesap silme sürecini kullanarak verilerinin sistemden kaldırılmasını talep edebilirsin.';

  @override
  String get dataProcessingSecurity => 'Veri İşleme ve Güvenlik';

  @override
  String get gdprDataProtection => 'KVKK ve Veri Koruma';

  @override
  String get privacyBullet1 =>
      'YearFlow\'da tuttuğun tüm Hedef, Check-in ve Rapor verileri KVKK ve ilgili mevzuata uygun şekilde işlenir.';

  @override
  String get privacyBullet2 =>
      'Verilerin; uygulama deneyimini iyileştirmek, kişiselleştirilmiş içerikler sunmak ve ürün analitiği yapmak dışında başka bir amaçla kullanılmaz.';

  @override
  String get privacyBullet3 =>
      'Kişisel verilerin reklam, pazarlama veya profilleme amaçlı üçüncü taraflarla paylaşılmaz.';

  @override
  String get privacyBullet4 =>
      'Hesabını sildiğinde, kimliğini doğrudan belirleyen kişisel verilerin makul bir süre içinde sistemden silinmesi hedeflenir.';

  @override
  String get privacyBullet5 =>
      'Yasal yükümlülükler gereği tutulması zorunlu olan kayıtlar, yalnızca mevzuata uygun süre boyunca saklanır ve süresi dolduğunda güvenli biçimde imha edilir.';

  @override
  String get security => 'Güvenlik';

  @override
  String get securityBullet1 =>
      'Verilerin, endüstri standartlarına uygun biçimde yetkisiz erişime, kayba veya kötüye kullanıma karşı korunur.';

  @override
  String get securityBullet2 =>
      'Sistem içindeki tüm veri iletimi şifrelenmiş bağlantılar üzerinden gerçekleşir.';

  @override
  String get securityBullet3 =>
      'Güvenlik uygulamaları belirli aralıklarla gözden geçirilir ve iyileştirilir.';

  @override
  String get goalTitle => 'Hedef Başlığı';

  @override
  String get goalTitleHint => 'Yeni bir dil öğrenmek';

  @override
  String get goalTitleRequired => 'Lütfen hedef başlığı girin';

  @override
  String get goalTitleMinLength => 'Hedef başlığı en az 3 karakter olmalıdır';

  @override
  String get selectCategory => 'Kategori Seç';

  @override
  String get categoryRequired => 'Lütfen bir kategori seçin';

  @override
  String get whyThisGoal => 'Bu hedefi neden istiyorsun?';

  @override
  String get motivationHint => 'Motivasyonunu ve amacını yaz...';

  @override
  String get motivationRequired =>
      'Lütfen bu hedefi neden istediğinizi açıklayın';

  @override
  String get completionDate => 'Tamamlanma Tarihi';

  @override
  String get selectDate => 'Tarih seçin';

  @override
  String get dateRequired => 'Lütfen tamamlanma tarihi seçin';

  @override
  String get categoryExample => 'örn: Kariyer, Sağlık';

  @override
  String get noteDeleted => 'Not silindi';

  @override
  String get noteAdded => 'Not eklendi';

  @override
  String get pleaseEnterNoteContent => 'Lütfen not içeriği girin';

  @override
  String errorDeletingNote(String error) {
    return 'Not silinirken hata oluştu: $error';
  }

  @override
  String errorAddingNote(String error) {
    return 'Not eklenirken hata oluştu: $error';
  }

  @override
  String get addNote => 'Yeni Not Ekle';

  @override
  String get editNote => 'Notu Düzenle';

  @override
  String get noteContent => 'Not İçeriği';

  @override
  String get noteContentHint => 'Notunuzu buraya yazın...';

  @override
  String get monthlyCheckIn => 'Aylık Check-in';

  @override
  String get takeAMomentToReflect => 'Kısa bir yansıma molası ver';

  @override
  String get howDoYouEvaluateThisMonth =>
      'Bu ayki ilerlemeni nasıl değerlendirirsin?';

  @override
  String get scoreDescription =>
      '1 çok düşük ilerleme, 10 mükemmel ilerleme anlamına gelir.';

  @override
  String score(int score) {
    return 'Skor: $score / 10';
  }

  @override
  String get saveCheckIn => 'Check-in\'i Kaydet';

  @override
  String errorSavingCheckIn(String error) {
    return 'Check-in kaydedilirken bir hata oluştu: $error';
  }

  @override
  String get whatDidYouDoThisMonth => 'Bu ay bu hedef için ne yaptın?';

  @override
  String get smallStepsCount =>
      'Küçük adımlar da sayılır. Kısa yazman yeterli.';

  @override
  String get progressExample =>
      'Örn: Haftada 3 kez çalıştım, iki bölüm okudum, kelime pratiği yaptım…';

  @override
  String get whatChallengedYouMost =>
      'Bu süreçte seni en çok ne zorladı? Bununla nasıl başa çıktın?';

  @override
  String get youCanWriteOnlyChallenges =>
      'İstersen sadece zorlandığın kısmı da yazabilirsin.';

  @override
  String get challengeExample =>
      'Örn: İş yükü rutinimi bozdu; tekrar toparlanmak için haftalık plan yapmaya başladım…';

  @override
  String get leaveNoteForFutureSelf =>
      'Gelecekteki kendine küçük bir not bırakmak ister misin?';

  @override
  String get noteExample =>
      'Örn: Harika gidiyorsun. Tutarlı kal ve sürece güven.';

  @override
  String get optional => 'Opsiyonel';

  @override
  String get note => 'Not:';

  @override
  String get whichGoalForCheckIn =>
      'Hangi hedef için check-in yapmak istersin?';

  @override
  String get selectGoalFromBelow =>
      'Aşağıdan bir hedef seç; seni doğrudan check-in ekranına götürelim.';

  @override
  String get goalsLoading => 'Hedefler yükleniyor...';

  @override
  String errorLoadingGoals(String error) {
    return 'Hedefler alınırken bir hata oluştu: $error';
  }

  @override
  String get noGoalsYetCreateFirst =>
      'Henüz hiç hedefin yok. Önce bir hedef oluşturmalısın.';

  @override
  String get delete => 'Sil';

  @override
  String get complete => 'Tamamla';

  @override
  String get deleteSubtask => 'Alt görevi sil';

  @override
  String get deleteSubtaskConfirmation =>
      'Bu alt görevi silmek istediğine emin misin?';

  @override
  String get deleteReport => 'Raporu sil';

  @override
  String get reportDeleted => 'Rapor silindi';

  @override
  String reportDeleteError(String error) {
    return 'Rapor silinirken bir hata oluştu: $error';
  }

  @override
  String pageNotFound(String path) {
    return 'Sayfa bulunamadı: $path';
  }

  @override
  String get optimizationResultNotFound => 'Optimizasyon sonucu bulunamadı';

  @override
  String get createFirstReportInstruction =>
      'Yukarıdaki \"Rapor Oluştur\" butonuna tıklayarak ilk raporunuzu oluşturabilirsiniz.';

  @override
  String get remove => 'Çıkar';

  @override
  String get close => 'Kapat';

  @override
  String get errorEmailAlreadyInUse =>
      'Bu e-posta adresi başka bir hesap tarafından kullanılıyor.';

  @override
  String get errorWeakPassword =>
      'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';

  @override
  String get errorInvalidEmail =>
      'E-posta adresi geçersiz. Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get errorUserNotFound =>
      'Bu e-posta adresi ile kayıtlı hesap bulunamadı. Lütfen e-posta adresinizi kontrol edin veya kayıt olun.';

  @override
  String get errorWrongPassword => 'Şifre hatalı. Lütfen tekrar deneyin.';

  @override
  String get errorInvalidCredential =>
      'E-posta veya şifre hatalı. Lütfen tekrar deneyin.';

  @override
  String get errorWrongCurrentPassword =>
      'Mevcut şifre yanlış. Lütfen tekrar deneyin.';

  @override
  String get errorUserDisabled =>
      'Bu hesap devre dışı bırakılmış. Lütfen destek ile iletişime geçin.';

  @override
  String get errorTooManyRequests =>
      'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorOperationNotAllowed =>
      'Bu giriş yöntemi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorNetworkRequestFailed => 'İnternet bağlantınızı kontrol edin.';

  @override
  String get errorRequiresRecentLogin =>
      'Güvenlik nedeniyle lütfen tekrar giriş yapın.';

  @override
  String get errorSignInFailed =>
      'Giriş yapılamadı. E-posta veya şifre hatalı olabilir, lütfen tekrar deneyin.';

  @override
  String get errorSignUpFailed =>
      'Kayıt işlemi tamamlanamadı. Lütfen tekrar deneyin.';

  @override
  String get errorPasswordResetFailed =>
      'Şifre sıfırlama sırasında hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorUnexpectedAuth =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get accountDeletedSuccessfully => 'Hesabınız başarıyla silindi';

  @override
  String accountDeleteError(String error) {
    return 'Hesap silinirken hata oluştu: $error';
  }

  @override
  String get aiOptimization => 'AI Optimizasyonu';

  @override
  String get aiOptimizationSubtitle => 'Hedefiniz SMART formatına çevrildi';

  @override
  String get optimizationFailed => 'Optimizasyon başarısız';

  @override
  String get optimizedGoal => 'Optimize Edilmiş Hedef';

  @override
  String get optimizedGoalHint => 'Kısa bir hedef adı yazın…';

  @override
  String get explanation => 'Açıklama';

  @override
  String get suggestedSubTasks => 'Önerilen Alt Görevler';

  @override
  String get apply => 'Uygula';

  @override
  String get jsonCsv => 'JSON / CSV';

  @override
  String get noInternetConnection =>
      'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';

  @override
  String get requiresConnection => 'Bu özellik internet bağlantısı gerektirir.';

  @override
  String get unexpectedError =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get addGoal => 'Hedef ekle';

  @override
  String get sortBy => 'Sırala';

  @override
  String get filterBy => 'Filtrele';

  @override
  String get sortNewest => 'En yeni';

  @override
  String get sortOldest => 'En eski';

  @override
  String get sortProgressHigh => 'İlerleme: yüksekten düşüğe';

  @override
  String get sortProgressLow => 'İlerleme: düşükten yükseğe';

  @override
  String get sortTitleAsc => 'Başlık A–Z';

  @override
  String get sortTitleDesc => 'Başlık Z–A';

  @override
  String get confirm => 'Onayla';

  @override
  String get uncompleteGoalTitle => 'Hedefi tekrar aktifleştir';

  @override
  String get uncompleteGoalMessage =>
      'Bu hedefi tekrar aktif hale getirmek istediğine emin misin?';

  @override
  String get noGoalsYetSubtitle =>
      'Hedef ekleyerek ilerlemeye başlayabilirsin.';

  @override
  String get noCompletedGoalsYet => 'Henüz tamamlanan hedef yok';

  @override
  String get noCompletedGoalsYetSubtitle =>
      'Hedeflerini tamamladığında burada göreceksin.';

  @override
  String get privacySecurityTitle => 'Gizlilik & Güvenlik';

  @override
  String get yourDataInYourControl => 'Verilerin Senin Kontrolünde';

  @override
  String get privacyIntroText =>
      'YearFlow, Hedef, Check-in ve Rapor verilerini KVKK ve ilgili veri koruma mevzuatına uygun şekilde işler. Kişisel verilerin reklam amaçlı üçüncü kişilerle paylaşılmaz; yalnızca uygulama deneyimini geliştirmek, kişiselleştirilmiş içerik üretmek ve ürün analitiği yapmak için kullanılır. Dilediğin zaman verilerini indirip inceleyebilir veya hesap silme sürecini kullanarak verilerinin sistemden kaldırılmasını talep edebilirsin.';

  @override
  String get dataProcessingAndSecurity => 'Veri İşleme ve Güvenlik';

  @override
  String get gdprAndDataProtection => 'KVKK ve Veri Koruma';

  @override
  String get gdprBullet1 =>
      'YearFlow\'da tuttuğun tüm Hedef, Check-in ve Rapor verileri KVKK ve ilgili mevzuata uygun şekilde işlenir.';

  @override
  String get gdprBullet2 =>
      'Verilerin; uygulama deneyimini iyileştirmek, kişiselleştirilmiş içerikler sunmak ve ürün analitiği yapmak dışında başka bir amaçla kullanılmaz.';

  @override
  String get gdprBullet3 =>
      'Kişisel verilerin reklam, pazarlama veya profilleme amaçlı üçüncü taraflarla paylaşılmaz.';

  @override
  String get gdprBullet4 =>
      'Hesabını sildiğinde, kimliğini doğrudan belirleyen kişisel verilerin makul bir süre içinde sistemden silinmesi hedeflenir.';

  @override
  String get gdprBullet5 =>
      'Yasal yükümlülükler gereği tutulması zorunlu olan kayıtlar, yalnızca mevzuata uygun süre boyunca saklanır ve süresi dolduğunda güvenli biçimde imha edilir.';
}
