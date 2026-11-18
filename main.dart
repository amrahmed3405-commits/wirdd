import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ================= الأذكار =================
class Dhikr {
  final String count;
  final String source;
  final String? morning;
  final String? evening;
  const Dhikr(this.count, this.source, this.morning, this.evening);
}

const List<Dhikr> kAdhkar = [
  Dhikr(r'''مرة''', r'''سورة البقرة ٢٥٥''', r'''اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ''', null),
  Dhikr(r'''مرة''', r'''رواه مسلم''', r'''أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ''', r'''أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ'''),
  Dhikr(r'''مرة''', r'''رواه الترمذي''', r'''اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ''', r'''اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ'''),
  Dhikr(r'''مرة''', r'''رواه البخاري (سيد الاستغفار)''', r'''اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ''', null),
  Dhikr(r'''٤ مرات''', r'''رواه أبو داود''', r'''اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ''', r'''اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ'''),
  Dhikr(r'''مرة''', r'''رواه أبو داود''', r'''اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ''', r'''اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ'''),
  Dhikr(r'''٣ مرات''', r'''رواه أبو داود''', r'''اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ''', null),
  Dhikr(r'''٧ مرات''', r'''رواه أبو داود''', r'''حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ''', null),
  Dhikr(r'''مرة''', r'''أبو داود وابن ماجه''', r'''اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي''', null),
  Dhikr(r'''مرة''', r'''الترمذي وأبو داود''', r'''اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا''', null),
  Dhikr(r'''مرة''', r'''الحاكم''', r'''يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ''', null),
  Dhikr(r'''مرة''', r'''رواه أحمد''', r'''أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ''', r'''أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ'''),
  Dhikr(r'''١٠٠ مرة''', r'''رواه مسلم''', r'''سُبْحَانَ اللَّهِ وَبِحَمْدِهِ''', null),
  Dhikr(r'''١٠ مرات''', r'''النسائي وأحمد''', r'''لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ''', null),
  Dhikr(r'''٣ مرات''', r'''رواه مسلم''', r'''سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ''', null),
  Dhikr(r'''مرة''', r'''رواه أبو داود''', r'''اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ''', null),
  Dhikr(r'''٣ مرات (مساءً)''', r'''رواه مسلم''', null, r'''أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ'''),
  Dhikr(r'''١٠ مرات''', r'''رواه الطبراني''', r'''اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ''', null),
];


// ================= الإشعارات =================
class Notifier {
  static final FlutterLocalNotificationsPlugin _p = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _p.initialize(const InitializationSettings(android: android));
      final impl = _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await impl?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      _ready = false;
    }
  }

  static NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'wird_channel',
        'تذكير الأوراد',
        channelDescription: 'تذكيرات الأوراد اليومية',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  static tz.TZDateTime _next(int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    if (t.isBefore(now)) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  static Future<void> schedule(int id, String title, String body, int h, int m) async {
    if (!_ready) return;
    try {
      await _p.zonedSchedule(
        id,
        title,
        body,
        _next(h, m),
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // تجاهل
    }
  }

  static Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _p.cancelAll();
    } catch (e) {
      // تجاهل
    }
  }

  static Future<void> showNow(String title, String body) async {
    if (!_ready) return;
    try {
      await _p.show(99, title, body, _details());
    } catch (e) {
      // تجاهل
    }
  }
}

// ================= ثوابت =================
const List<String> kUnits = ['دقيقة', 'آيات', 'صفحات', 'أجزاء', 'أوجه', 'ربع', 'مرة', 'ركعات', 'يوم'];
const List<String> kDayNames = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const List<String> kMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const Color kGold = Color(0xFFB0852E);

String ar(Object n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final chars = n.toString().split('');
  final out = StringBuffer();
  for (final c in chars) {
    final i = int.tryParse(c);
    out.write(i == null ? c : d[i]);
  }
  return out.toString();
}

String two(int n) => n.toString().padLeft(2, '0');

String dayKey(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

Map<String, dynamic> _item(String i, String n, int t, {String? g, String? note}) {
  return <String, dynamic>{'i': i, 'n': n, 't': t, 'g': g, 'note': note};
}

Map<String, dynamic> baseState() {
  const fr = 'الفرائض في جماعة';
  const sn = 'السنن الرواتب';
  const pr = 'بعد الصلوات (مرة بعد كل فرض)';
  const sl = 'قبل النوم';
  const dy = 'على مدار اليوم';
  final m = <String, dynamic>{
    'order': ['salah', 'listen', 'memo', 'read', 'qiyam', 'adsm', 'adh', 'siyam'],
    'w': {
      'salah': {
        'n': 'ورد الصلاة',
        'kind': 'list',
        'items': [
          _item('f1', 'الفجر في جماعة', 1, g: fr),
          _item('f2', 'الظهر في جماعة', 1, g: fr),
          _item('f3', 'العصر في جماعة', 1, g: fr),
          _item('f4', 'المغرب في جماعة', 1, g: fr),
          _item('f5', 'العشاء في جماعة', 1, g: fr),
          _item('r1', 'ركعتان قبل الفجر', 1, g: sn),
          _item('r2', 'أربع ركعات قبل الظهر', 1, g: sn),
          _item('r3', 'ركعتان بعد الظهر', 1, g: sn),
          _item('r4', 'ركعتان بعد المغرب', 1, g: sn),
          _item('r5', 'ركعتان بعد العشاء', 1, g: sn),
        ],
      },
      'listen': {'n': 'ورد السماع', 'kind': 'count', 't': 20, 'u': 'دقيقة', 'stop': ''},
      'memo': {'n': 'ورد الحفظ', 'kind': 'count', 't': 5, 'u': 'آيات', 'stop': ''},
      'read': {'n': 'ورد القراءة', 'kind': 'count', 't': 5, 'u': 'صفحات', 'stop': ''},
      'qiyam': {'n': 'قيام الليل', 'kind': 'count', 't': 2, 'u': 'ركعات', 'stop': ''},
      'adsm': {
        'n': 'أذكار الصباح والمساء',
        'kind': 'list',
        'items': [
          _item('m', 'أذكار الصباح', 1, note: 'بعد الفجر'),
          _item('e', 'أذكار المساء', 1, note: 'بعد العصر'),
        ],
      },
      'adh': {
        'n': 'أذكار من السنة',
        'kind': 'list',
        'items': [
          _item('a1', 'التسبيح ٣٣ والتحميد ٣٣ والتكبير ٣٤', 5, g: pr, note: 'رواه مسلم'),
          _item('a2', 'آية الكرسي دبر الصلاة', 5, g: pr, note: 'رواه النسائي'),
          _item('a3', 'الإخلاص والفلق والناس دبر الصلاة', 5, g: pr, note: 'أبو داود والترمذي'),
          _item('s1', 'آية الكرسي', 1, g: sl, note: 'رواه البخاري'),
          _item('s2', 'آخر آيتين من سورة البقرة', 1, g: sl, note: 'رواه البخاري'),
          _item('s3', 'الإخلاص والفلق والناس (ثلاث مرات)', 1, g: sl, note: 'رواه البخاري'),
          _item('s4', 'باسمك اللهم أموت وأحيا', 1, g: sl, note: 'رواه البخاري'),
          _item('d1', 'سبحان الله وبحمده', 100, g: dy, note: 'متفق عليه'),
          _item('d2', 'الاستغفار', 100, g: dy, note: 'رواه مسلم'),
        ],
      },
      'siyam': {'n': 'صيام الاثنين والخميس', 'kind': 'count', 't': 1, 'u': 'يوم', 'days': [1, 4], 'stop': ''},
    },
    'log': {},
    'rem': {
      'm': {'on': true, 't': '05:30'},
      'e': {'on': true, 't': '15:30'},
      'q': {'on': true, 't': '19:00'},
    },
  };
  return jsonDecode(jsonEncode(m)) as Map<String, dynamic>;
}

// ================= التطبيق =================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.init();
  runApp(const WirdApp());
}

class WirdApp extends StatelessWidget {
  const WirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F5A47);
    return MaterialApp(
      title: 'وردي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Map<String, dynamic> S = baseState();
  SharedPreferences? prefs;
  bool loaded = false;
  final TextEditingController nameC = TextEditingController();
  final TextEditingController tC = TextEditingController(text: '1');
  String newUnit = 'مرة';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameC.dispose();
    tC.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    prefs = await SharedPreferences.getInstance();
    final raw = prefs!.getString('wird_state');
    if (raw != null) {
      try {
        S = jsonDecode(raw) as Map<String, dynamic>;
      } catch (e) {
        S = baseState();
      }
    }
    if (S['rem'] == null) {
      S['rem'] = baseState()['rem'];
    }
    setState(() {
      loaded = true;
    });
    _resched();
  }

  void _save() {
    prefs?.setString('wird_state', jsonEncode(S));
  }

  Map<String, dynamic> get W => S['w'] as Map<String, dynamic>;
  List<dynamic> get order => S['order'] as List<dynamic>;
  Map<String, dynamic> get logs => S['log'] as Map<String, dynamic>;
  String get todayKey => dayKey(DateTime.now());

  Map<String, dynamic> dayLog(String k) {
    final x = logs.putIfAbsent(k, () => <String, dynamic>{});
    return x as Map<String, dynamic>;
  }

  int cnt(Map<String, dynamic> l, String key) {
    final v = l[key];
    return v is int ? v : 0;
  }

  List<int> prog(String id, Map<String, dynamic> l) {
    final w = W[id] as Map<String, dynamic>;
    if (w['kind'] == 'list') {
      final items = w['items'] as List<dynamic>;
      int d = 0;
      for (final raw in items) {
        final it = raw as Map<String, dynamic>;
        final iid = it['i'] as String;
        if (cnt(l, '$id.$iid') >= (it['t'] as int)) d++;
      }
      return [d, items.length];
    }
    final t = w['t'] as int;
    final c = cnt(l, id);
    return [c > t ? t : c, t];
  }

  List<String> active(String k) {
    final wd = DateTime.parse(k).weekday;
    final out = <String>[];
    for (final raw in order) {
      final id = raw as String;
      final w = W[id];
      if (w == null) continue;
      final days = (w as Map<String, dynamic>)['days'];
      if (days == null || (days as List<dynamic>).contains(wd)) {
        out.add(id);
      }
    }
    return out;
  }

  int doneCount(String k) {
    final l = (logs[k] ?? <String, dynamic>{}) as Map<String, dynamic>;
    int n = 0;
    for (final id in active(k)) {
      final p = prog(id, l);
      if (p[0] >= p[1]) n++;
    }
    return n;
  }

  bool full(String k) {
    final a = active(k).length;
    return a > 0 && doneCount(k) == a;
  }

  int streak() {
    int s = 0;
    var d = DateTime.now();
    if (!full(dayKey(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    while (full(dayKey(d))) {
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  int _step(String u, int t) {
    if (u == 'دقيقة') return 5;
    return t >= 100 ? 10 : 1;
  }

  void _add(String id, int d) {
    final l = dayLog(todayKey);
    final c = cnt(l, id) + d;
    l[id] = c < 0 ? 0 : c;
    _save();
    setState(() {});
  }

  void _complete(String id, int t) {
    final l = dayLog(todayKey);
    final c = cnt(l, id);
    l[id] = c > t ? c : t;
    _save();
    setState(() {});
  }

  void _setKey(String key, int v) {
    final l = dayLog(todayKey);
    l[key] = v;
    _save();
    setState(() {});
  }

  void _addKey(String key, int d, int t) {
    final l = dayLog(todayKey);
    int c = cnt(l, key) + d;
    if (c < 0) c = 0;
    if (c > t) c = t;
    l[key] = c;
    _save();
    setState(() {});
  }

  Future<void> _resched() async {
    await Notifier.cancelAll();
    final rem = S['rem'] as Map<String, dynamic>;
    final defs = <List<dynamic>>[
      ['m', 1, 'أذكار الصباح', 'حان وقت أذكار الصباح'],
      ['e', 2, 'أذكار المساء', 'حان وقت أذكار المساء'],
      ['q', 3, 'قيام الليل', 'تذكير بقيام الليل بعد العشاء'],
    ];
    for (final d in defs) {
      final r = rem[d[0] as String] as Map<String, dynamic>;
      if (r['on'] != true) continue;
      final p = (r['t'] as String).split(':');
      await Notifier.schedule(d[1] as int, d[2] as String, d[3] as String, int.parse(p[0]), int.parse(p[1]));
    }
  }

  Future<void> _pickTime(String key) async {
    final rem = S['rem'] as Map<String, dynamic>;
    final r = rem[key] as Map<String, dynamic>;
    final p = (r['t'] as String).split(':');
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])),
    );
    if (res == null) return;
    r['t'] = '${two(res.hour)}:${two(res.minute)}';
    _save();
    _resched();
    setState(() {});
  }

  // ---------- واجهة ----------
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final k = todayKey;
    final l = dayLog(k);
    final act = active(k);
    double sum = 0;
    for (final id in act) {
      final p = prog(id, l);
      sum += p[1] == 0 ? 0 : p[0] / p[1];
    }
    final pct = act.isEmpty ? 0.0 : sum / act.length;
    final cards = <Widget>[];
    for (final raw in order) {
      final id = raw as String;
      if (W[id] == null) continue;
      cards.add(_wirdCard(id, l, act.contains(id)));
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(pct),
            const SizedBox(height: 12),
            ...cards,
            _addButton(),
            _remindersCard(),
            _statsCard(),
          ],
        ),
      ),
    );
  }

  Widget _header(double pct) {
    final n = DateTime.now();
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: pct,
                strokeWidth: 9,
                color: kGold,
                backgroundColor: cs.surfaceContainerHighest,
              ),
              Center(child: Text('${ar((pct * 100).round())}٪', style: const TextStyle(fontSize: 18))),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('وردي اليومي', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text('${kDayNames[n.weekday]} ${ar(n.day)} ${kMonths[n.month - 1]}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wirdCard(String id, Map<String, dynamic> l, bool on) {
    final w = W[id] as Map<String, dynamic>;
    final cs = Theme.of(context).colorScheme;
    final name = w['n'] as String;
    final menu = PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') _editDialog(id);
        if (v == 'del') _delDialog(id);
      },
      itemBuilder: (c) => const [
        PopupMenuItem<String>(value: 'edit', child: Text('تعديل')),
        PopupMenuItem<String>(value: 'del', child: Text('حذف')),
      ],
    );
    if (!on) {
      final days = (w['days'] as List<dynamic>).map((d) => kDayNames[d as int]).join(' و ');
      return Card(
        child: ListTile(
          title: Text(name),
          subtitle: Text('مش مطلوب النهارده. أيام الورد: $days'),
          trailing: menu,
        ),
      );
    }
    final p = prog(id, l);
    final done = p[0] >= p[1];
    final Widget body = w['kind'] == 'list' ? _listBody(id, w, l) : _countBody(id, w, l);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? cs.primary : cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleLarge)),
                if (done) Text('تم بحمد الله', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                menu,
              ],
            ),
            LinearProgressIndicator(
              value: p[1] == 0 ? 0.0 : p[0] / p[1],
              minHeight: 8,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }

  Widget _countBody(String id, Map<String, dynamic> w, Map<String, dynamic> l) {
    final t = w['t'] as int;
    final u = w['u'] as String;
    final c = cnt(l, id);
    final shown = c > t ? t : c;
    final step = _step(u, t);
    return Column(
      children: [
        Row(
          children: [
            IconButton.outlined(onPressed: () => _add(id, -step), icon: const Icon(Icons.remove)),
            Expanded(
              child: Text(
                '${ar(shown)} من ${ar(t)} $u',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            IconButton.outlined(onPressed: () => _add(id, step), icon: const Icon(Icons.add)),
            const SizedBox(width: 8),
            FilledButton(onPressed: () => _complete(id, t), child: const Text('أتممت')),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('note-$id'),
          initialValue: (w['stop'] ?? '') as String,
          onChanged: (v) {
            w['stop'] = v;
            _save();
          },
          decoration: const InputDecoration(
            hintText: 'ملاحظة أو موضع التوقف',
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _listBody(String id, Map<String, dynamic> w, Map<String, dynamic> l) {
    final items = w['items'] as List<dynamic>;
    final rows = <Widget>[];
    String? lastG;
    for (final raw in items) {
      final it = raw as Map<String, dynamic>;
      final g = it['g'] as String?;
      if (g != null && g != lastG) {
        lastG = g;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(g, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          ),
        );
      }
      rows.add(_itemRow(id, it, l));
      final iid = it['i'] as String;
      if (id == 'adsm' && (iid == 'm' || iid == 'e')) {
        rows.add(_azTile(iid));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _itemRow(String id, Map<String, dynamic> it, Map<String, dynamic> l) {
    final iid = it['i'] as String;
    final key = '$id.$iid';
    final t = it['t'] as int;
    final c = cnt(l, key);
    final dn = c >= t;
    final note = it['note'] as String?;
    final primary = Theme.of(context).colorScheme.primary;
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(it['n'] as String, style: const TextStyle(fontSize: 16)),
        if (note != null && note.isNotEmpty) Text(note, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
    if (t == 1) {
      return InkWell(
        onTap: () => _setKey(key, dn ? 0 : 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(dn ? Icons.check_box : Icons.check_box_outline_blank, color: dn ? primary : null),
              const SizedBox(width: 10),
              Expanded(child: label),
            ],
          ),
        ),
      );
    }
    final st = t >= 100 ? 10 : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: label),
          IconButton(onPressed: () => _addKey(key, -st, t), icon: const Icon(Icons.remove_circle_outline)),
          Text('${ar(c)} / ${ar(t)}'),
          IconButton(onPressed: () => _addKey(key, st, t), icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  Widget _azTile(String r) {
    final list = kAdhkar.where((a) => r == 'm' ? a.morning != null : (a.evening ?? a.morning) != null).toList();
    final children = <Widget>[];
    for (final a in list) {
      final txt = r == 'm' ? a.morning! : (a.evening ?? a.morning)!;
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txt, style: const TextStyle(fontSize: 21, height: 2.0)),
              Text('${a.count} · ${a.source}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
            ],
          ),
        ),
      );
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('عرض الأذكار', style: TextStyle(fontWeight: FontWeight.bold)),
      children: children,
    );
  }

  Future<void> _editDialog(String id) async {
    final w = W[id] as Map<String, dynamic>;
    final isCount = w['kind'] == 'count';
    final nameCtl = TextEditingController(text: w['n'] as String);
    final tCtl = TextEditingController(text: isCount ? '${w['t']}' : '');
    String unit = isCount ? (w['u'] as String) : kUnits[0];
    if (!kUnits.contains(unit)) unit = kUnits[0];
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          title: const Text('تعديل الورد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الورد')),
              if (isCount)
                TextField(
                  controller: tCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
              if (isCount)
                DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setD(() {
                        unit = v;
                      });
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final n = nameCtl.text.trim();
                if (n.isNotEmpty) w['n'] = n;
                if (isCount) {
                  final t = int.tryParse(tCtl.text);
                  if (t != null && t > 0) w['t'] = t;
                  w['u'] = unit;
                }
                _save();
                Navigator.pop(ctx2);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _delDialog(String id) async {
    final w = W[id] as Map<String, dynamic>;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${w['n']}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      W.remove(id);
      S['order'] = order.where((x) => x != id).toList();
      _save();
      setState(() {});
    }
  }

  void _addWird() {
    final n = nameC.text.trim();
    if (n.isEmpty) return;
    final t = int.tryParse(tC.text) ?? 1;
    final id = 'w${DateTime.now().millisecondsSinceEpoch}';
    W[id] = <String, dynamic>{'n': n, 'kind': 'count', 't': t < 1 ? 1 : t, 'u': newUnit, 'stop': ''};
    order.add(id);
    nameC.clear();
    tC.text = '1';
    _save();
    setState(() {});
  }

  Widget _addCard() {
    const presets = <List<dynamic>>[
      ['الاستغفار', 100, 'مرة'],
      ['الصلاة على النبي', 100, 'مرة'],
      ['ضحى', 2, 'ركعات'],
      ['صدقة', 1, 'مرة'],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إضافة ورد جديد', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in presets)
                  ActionChip(
                    label: Text(p[0] as String),
                    onPressed: () {
                      setState(() {
                        nameC.text = p[0] as String;
                        tC.text = '${p[1]}';
                        newUnit = p[2] as String;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameC,
                    decoration: const InputDecoration(hintText: 'اسم الورد', isDense: true, border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: tC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: newUnit,
              isExpanded: true,
              items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    newUnit = v;
                  });
                }
              },
            ),
            FilledButton(onPressed: _addWird, child: const Text('إضافة الورد')),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FilledButton.icon(
        onPressed: _addDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة ورد جديد'),
      ),
    );
  }

  Future<void> _addDialog() async {
    final nCtl = TextEditingController();
    final cCtl = TextEditingController(text: '1');
    String unit = 'مرة';
    const presets = <List<dynamic>>[
      ['الاستغفار', 100, 'مرة'],
      ['الصلاة على النبي', 100, 'مرة'],
      ['ضحى', 2, 'ركعات'],
      ['صدقة', 1, 'مرة'],
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          title: const Text('إضافة ورد جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in presets)
                      ActionChip(
                        label: Text(p[0] as String),
                        onPressed: () {
                          setD(() {
                            nCtl.text = p[0] as String;
                            cCtl.text = '${p[1]}';
                            unit = p[2] as String;
                          });
                        },
                      ),
                  ],
                ),
                TextField(controller: nCtl, decoration: const InputDecoration(labelText: 'اسم الورد')),
                TextField(
                  controller: cCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'العدد'),
                ),
                DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setD(() {
                        unit = v;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final n = nCtl.text.trim();
                if (n.isEmpty) return;
                final t = int.tryParse(cCtl.text) ?? 1;
                final id = 'w${DateTime.now().millisecondsSinceEpoch}';
                W[id] = <String, dynamic>{'n': n, 'kind': 'count', 't': t < 1 ? 1 : t, 'u': unit, 'stop': ''};
                order.add(id);
                _save();
                Navigator.pop(ctx2);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  Widget _remindersCard() {
    final rem = S['rem'] as Map<String, dynamic>;
    const names = <String, String>{'m': 'أذكار الصباح', 'e': 'أذكار المساء', 'q': 'قيام الليل'};
    final tiles = <Widget>[];
    for (final key in ['m', 'e', 'q']) {
      final r = rem[key] as Map<String, dynamic>;
      tiles.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(names[key]!),
          subtitle: Text(ar(r['t'] as String)),
          onTap: () => _pickTime(key),
          trailing: Switch(
            value: r['on'] == true,
            onChanged: (v) {
              r['on'] = v;
              _save();
              _resched();
              setState(() {});
            },
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تذكير بالإشعارات', style: Theme.of(context).textTheme.titleLarge),
            const Text('دوس على أي ميعاد لتغييره. الإشعار بيتكرر كل يوم.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ...tiles,
            OutlinedButton(
              onPressed: () => Notifier.showNow('وردي', 'الإشعارات شغالة بحمد الله'),
              child: const Text('جرّب إشعار الآن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final cells = <Widget>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = dayKey(d);
      final n = doneCount(k);
      final f = full(k);
      cells.add(
        Expanded(
          child: Column(
            children: [
              Container(
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f ? cs.primary : (n > 0 ? kGold : cs.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: n > 0
                    ? Text(ar(n), style: TextStyle(color: f ? cs.onPrimary : Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(height: 4),
              Text(kDayNames[d.weekday], style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }
    final s = streak();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأسبوع', style: Theme.of(context).textTheme.titleLarge),
            Text(
              s > 0 ? '${ar(s)} يوم متواصل بإتمام كل أوراد اليوم' : 'أتمم كل أوراد اليوم لتبدأ سلسلتك',
              style: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(children: cells),
            TextButton(
              onPressed: () {
                logs[todayKey] = <String, dynamic>{};
                _save();
                setState(() {});
              },
              child: const Text('مسح بيانات اليوم'),
            ),
          ],
        ),
      ),
    );
  }
}
