enum ReportReason {
  inappropriateContent('inappropriate_content'),
  spam('spam'),
  copyright('copyright'),
  incorrectInfo('incorrect_info'),
  other('other');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromString(String value) {
    switch (value) {
      case 'inappropriate_content':
        return ReportReason.inappropriateContent;
      case 'spam':
        return ReportReason.spam;
      case 'copyright':
        return ReportReason.copyright;
      case 'incorrect_info':
        return ReportReason.incorrectInfo;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

enum ReportStatus {
  pending('pending'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}