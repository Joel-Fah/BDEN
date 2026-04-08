enum DonorCardStatus {
  inactive, // no qualifying donation yet at this hospital
  active, // 1–4 qualifying donations
  elite; // 5+ qualifying donations

  String get label {
    switch (this) {
      case inactive:
        return 'Inactive';
      case active:
        return 'Active Donor';
      case elite:
        return 'Elite Donor';
    }
  }

  static DonorCardStatus fromDonationCount(int count) {
    if (count >= 5) return elite;
    if (count >= 1) return active;
    return inactive;
  }
}
