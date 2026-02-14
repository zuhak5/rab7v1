/// Backend contracts:
/// - ride_request_status: requested | matched | accepted | cancelled | no_driver | expired
/// - ride_status: assigned | arrived | in_progress | completed | canceled
class RideStatusPresentation {
  const RideStatusPresentation({
    required this.stage,
    required this.helperText,
    required this.isTerminal,
    required this.displayStatus,
  });

  /// 1: request sent, 2: searching, 3: accepted/ongoing
  final int stage;
  final String helperText;
  final bool isTerminal;
  final String displayStatus;
}

RideStatusPresentation mapRideStatusPresentation(String rawStatus) {
  final status = rawStatus.trim().toLowerCase();
  switch (status) {
    case 'requested':
      return const RideStatusPresentation(
        stage: 2,
        helperText: 'تم إرسال الطلب وجارٍ البحث عن سائق قريب.',
        isTerminal: false,
        displayStatus: 'جارٍ البحث',
      );
    case 'matched':
      return const RideStatusPresentation(
        stage: 2,
        helperText: 'تمت مطابقة الطلب. ننتظر تأكيد السائق.',
        isTerminal: false,
        displayStatus: 'تمت المطابقة',
      );
    case 'accepted':
    case 'assigned':
      return const RideStatusPresentation(
        stage: 3,
        helperText: 'تم تأكيد السائق وهو في الطريق إليك.',
        isTerminal: false,
        displayStatus: 'تم قبول الرحلة',
      );
    case 'arrived':
      return const RideStatusPresentation(
        stage: 3,
        helperText: 'وصل السائق إلى نقطة الالتقاط.',
        isTerminal: false,
        displayStatus: 'السائق وصل',
      );
    case 'in_progress':
      return const RideStatusPresentation(
        stage: 3,
        helperText: 'الرحلة قيد التنفيذ.',
        isTerminal: false,
        displayStatus: 'الرحلة جارية',
      );
    case 'cancelled':
    case 'canceled':
      return const RideStatusPresentation(
        stage: 1,
        helperText: 'تم إلغاء الطلب.',
        isTerminal: true,
        displayStatus: 'ملغي',
      );
    case 'completed':
      return const RideStatusPresentation(
        stage: 3,
        helperText: 'اكتملت الرحلة بنجاح.',
        isTerminal: true,
        displayStatus: 'مكتمل',
      );
    case 'no_driver':
      return const RideStatusPresentation(
        stage: 2,
        helperText: 'لا يوجد سائق متاح حاليًا. حاول مرة أخرى بعد قليل.',
        isTerminal: true,
        displayStatus: 'لا يوجد سائق',
      );
    case 'expired':
      return const RideStatusPresentation(
        stage: 2,
        helperText: 'انتهت مهلة الطلب. أعد إنشاء طلب جديد.',
        isTerminal: true,
        displayStatus: 'منتهي الصلاحية',
      );
    default:
      return const RideStatusPresentation(
        stage: 2,
        helperText: 'جارٍ مزامنة حالة الطلب...',
        isTerminal: false,
        displayStatus: 'قيد التحديث',
      );
  }
}
