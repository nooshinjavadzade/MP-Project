enum ReportReason {
  inappropriateContent('Inappropriate Content'),
  spam('Spam'),
  copyright('Copyright'),
  incorrectInfo('Incorrect Information'),
  other('Other');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromString(String value) {
    switch (value) {
      case 'Inappropriate Content':
        return ReportReason.inappropriateContent;
      case 'Spam':
        return ReportReason.spam;
      case 'Copyright':
        return ReportReason.copyright;
      case 'Incorrect Information':
        return ReportReason.incorrectInfo;
      case 'Other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

enum ReportStatus {
  pending('Pending'),
  resolved('Resolved'),
  dismissed('Dismissed');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'Pending':
        return ReportStatus.pending;
      case 'Resolved':
        return ReportStatus.resolved;
      case 'Dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}