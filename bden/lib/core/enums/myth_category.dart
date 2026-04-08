enum MythCategory {
  health,
  eligibility,
  process,
  frequency,
  general;

  String get label {
    switch (this) {
      case health:
        return 'Health & Safety';
      case eligibility:
        return 'Who Can Donate';
      case process:
        return 'The Process';
      case frequency:
        return 'How Often';
      case general:
        return 'General';
    }
  }
}
