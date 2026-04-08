enum PerkType {
  freeExam,
  discountedTreatment,
  priorityAccess,
  freeConsultation,
  labDiscount,
  other;

  String get label {
    switch (this) {
      case freeExam:
        return 'Free Medical Exam';
      case discountedTreatment:
        return 'Discounted Treatment';
      case priorityAccess:
        return 'Priority Access';
      case freeConsultation:
        return 'Free Consultation';
      case labDiscount:
        return 'Lab Test Discount';
      case other:
        return 'Other Benefit';
    }
  }

  String get icon {
    // Maps to HugeIcons constant name — agent resolves actual icon in widget layer
    switch (this) {
      case freeExam:
        return 'stethoscope';
      case discountedTreatment:
        return 'medicine_02';
      case priorityAccess:
        return 'star';
      case freeConsultation:
        return 'doctor_01';
      case labDiscount:
        return 'test_tube';
      case other:
        return 'gift';
    }
  }
}
