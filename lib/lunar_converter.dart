import 'dart:math';

List<int> convertSolar2Lunar(int dd, int mm, int yy, int timeZone) {
  int dayNumber = jdFromDate(dd, mm, yy);
  int k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
  int monthStart = getNewMoonDay(k + 1, timeZone);
  if (monthStart > dayNumber) {
    monthStart = getNewMoonDay(k, timeZone);
  }

  int a11 = getLunarMonth11(yy, timeZone);
  int b11 = a11;
  int lunarYear = yy;
  if (a11 >= monthStart) {
    a11 = getLunarMonth11(yy - 1, timeZone);
    lunarYear = yy - 1;
  } else {
    b11 = getLunarMonth11(yy + 1, timeZone);
  }

  int lunarDay = dayNumber - monthStart + 1;
  int diff = ((monthStart - a11) / 29).floor();
  int lunarLeap = 0;
  int lunarMonth = diff + 11;
  if (b11 - a11 > 365) {
    int leapMonthDiff = getLeapMonthOffset(a11, timeZone);
    if (diff >= leapMonthDiff) {
      lunarMonth = diff + 10;
      if (diff == leapMonthDiff) {
        lunarLeap = 1;
      }
    }
  }
  if (lunarMonth > 12) {
    lunarMonth -= 12;
  }
  if (lunarMonth >= 11 && diff < 4) {
    lunarYear += 1;
  }
  return [lunarDay, lunarMonth, lunarYear, lunarLeap];
}

int jdFromDate(int dd, int mm, int yy) {
  int a = ((14 - mm) / 12).floor();
  int y = yy + 4800 - a;
  int m = mm + 12 * a - 3;
  return dd + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
}

int getNewMoonDay(int k, int timeZone) {
  double T = k / 1236.85;
  double T2 = T * T;
  double T3 = T2 * T;
  double dr = pi / 180;
  double Jd1 = 2415020.75933 + 29.53058868 * k
    + 0.0001178 * T2 - 0.000000155 * T3;
  Jd1 += 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);

  double M = 359.2242 + 29.10535608 * k
    - 0.0000333 * T2 - 0.00000347 * T3;
  double Mpr = 306.0253 + 385.81691806 * k
    + 0.0107306 * T2 + 0.00001236 * T3;
  double F = 21.2964 + 390.67050646 * k
    - 0.0016528 * T2 - 0.00000239 * T3;
  double C1 = (0.1734 - 0.000393 * T) * sin(M * dr)
    + 0.0021 * sin(2 * dr * M)
    - 0.4068 * sin(Mpr * dr)
    + 0.0161 * sin(2 * dr * Mpr)
    - 0.0004 * sin(3 * dr * Mpr)
    + 0.0104 * sin(2 * dr * F)
    - 0.0051 * sin((M + Mpr) * dr)
    - 0.0074 * sin((M - Mpr) * dr)
    + 0.0004 * sin((2 * F + M) * dr)
    - 0.0004 * sin((2 * F - M) * dr)
    - 0.0006 * sin((2 * F + Mpr) * dr)
    + 0.0010 * sin((2 * F - Mpr) * dr)
    + 0.0005 * sin((2 * Mpr + M) * dr);
  double deltaT = T < -11
      ? 0.001 + 0.000839 * T + 0.0002261 * T2
        - 0.00000845 * T3 - 0.000000081 * T * T3
      : -0.000278 + 0.000265 * T + 0.000262 * T2;

  return (Jd1 + C1 - deltaT + 0.5 + timeZone / 24).floor();
}

int getLunarMonth11(int yy, int timeZone) {
  int off = jdFromDate(31, 12, yy) - 2415021;
  int k = (off / 29.530588853).floor();
  int nm = getNewMoonDay(k, timeZone);
  int sunLong = getSunLongitude(nm, timeZone);
  if (sunLong >= 9) {
    nm = getNewMoonDay(k - 1, timeZone);
  }
  return nm;
}

int getSunLongitude(int jdn, int timeZone) {
  double T = (jdn - 2451545.5 - timeZone / 24) / 36525;
  double T2 = T * T;
  double dr = pi / 180;
  double M = 357.52910 + 35999.05030 * T
    - 0.0001559 * T2 - 0.00000048 * T * T2;
  double L0 = 280.46645 + 36000.76983 * T
    + 0.0003032 * T2;
  double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M)
    + (0.019993 - 0.000101 * T) * sin(dr * 2 * M)
    + 0.000290 * sin(dr * 3 * M);
  double L = L0 + DL;
  L = L * dr;
  L = L - pi * 2 * (L / (pi * 2)).floor();
  return (L / pi * 6).floor(); // 0 = xuân phân
}

int getLeapMonthOffset(int a11, int timeZone) {
  int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
  int last = 0;
  int i = 1;
  int arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
  do {
    last = arc;
    i++;
    arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
  } while (arc != last && i < 14);
  return i - 1;
}
