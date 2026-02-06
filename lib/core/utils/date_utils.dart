int calculateAge(DateTime birthDate) {
  final today = DateTime.now();

  int age = today.year - birthDate.year;

  final hasHadBirthdayThisYear =
      today.month > birthDate.month ||
      (today.month == birthDate.month && today.day >= birthDate.day);

  if (!hasHadBirthdayThisYear) {
    age--;
  }

  return age;
}
