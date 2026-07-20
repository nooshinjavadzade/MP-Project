enum WatchStatus {
  planToWatch,
  watching,
  completed,
  onHold,
  dropped,
  loved
}

extension WatchStatusExtension on WatchStatus {
  String get value {
    switch (this) {
      case WatchStatus.planToWatch:
        return 'plan_to_watch';
      case WatchStatus.watching:
        return 'watching';
      case WatchStatus.completed:
        return 'completed';
      case WatchStatus.onHold:
        return 'on_hold';
      case WatchStatus.dropped:
        return 'dropped';
      case WatchStatus.loved:
        return 'loved';
    }
  }

  static WatchStatus fromString(String value) {
    switch (value) {
      case 'plan_to_watch':
        return WatchStatus.planToWatch;
      case 'watching':
        return WatchStatus.watching;
      case 'completed':
        return WatchStatus.completed;
      case 'on_hold':
        return WatchStatus.onHold;
      case 'dropped':
        return WatchStatus.dropped;
      case 'loved':
        return WatchStatus.loved;
      default:
        return WatchStatus.planToWatch;
    }
  }
}