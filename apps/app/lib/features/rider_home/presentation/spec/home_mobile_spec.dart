import 'package:flutter/material.dart';

class HomeMobileSpec {
  const HomeMobileSpec._();

  static const Size designSize = Size(390, 844);
  static const double designWidth = 390;
  static const double designHeight = 844;

  static const double maxContentWidth = 640;
  static const double compactViewportThreshold = 780;

  static const double safeTopMin = 16;
  static const double safeBottomMin = 24;

  static const double headerHeight = 56; // 3.5rem * 16 = 56
  static const double headerOuterPadding = 16;
  static const double headerInnerHorizontalMargin = 8;
  static const double headerVerticalGap =
      8; // var(--gap-safe) = 0.75rem? Wait HTML JS says gap=8.

  static const double sheetTopRadius = 32; // rounded-t-[2rem] => 32px
  static const double sheetHandleWidth = 48;
  static const double sheetHandleHeight = 6;

  // HTML: nav-h: 5.25rem = 84px.
  static const double bottomNavHeight = 84;
  static const double bottomNavPaddingHorizontal = 20;
  static const double bottomNavTopPadding = 2;

  static const double mainSheetMinHeight = 390; // Fallback
  // mapReserve logic updates needed in Metrics, but here are constraints
  static const double mapReserveRatio = 0.22; // HTML: vh * 0.22
  static const double mapReserveMin = 120;
  static const double mapReserveMax = 240;

  static const double markerSize = 44;
  static const double markerInnerSize = 32;

  // Components
  static const double destinationFieldHeight = 64; // h-16 = 4rem = 64px
  static const double destinationFieldRadius = 16; // rounded-2xl = 1rem = 16px?
  // Wait, HTML: radius 2xl = 1rem = 16px.
  // Actually destination input in HTML: "rounded-2xl".

  static const double scheduleButtonHeight = 64; // h-16 = 64
  static const double scheduleButtonMinWidth = 110; // min-w-[6.875rem] = 110px

  static const double primaryButtonHeight = 56;
  static const double cardMinHeight = 56;

  static const double mainSheetHorizontalPadding = 20;
  static const double mainSheetBottomPadding = 16;
  static const double infoRowFontSize = 12;

  // Offers
  static const double offersSectionHeight = 156;
  static const double offersCardWidthRatio = 0.66;
  static const double offersCardMinWidth = 220;
  static const double offersCardWidth = 270;
  static const double offersCardHeight = 92;

  // Font Sizes
  static const double tinyLabelSize = 10;
  static const double bodyLabelSize = 12;
  static const double headlineLabelSize = 14;

  // Colors (Source of Truth: HTML tailwind config)
  static const Color primary = Color(0xFF0056D2);
  static const Color primaryDark = Color(0xFF00419e);

  static const Color backgroundLight = Color(0xFFf6f7f8);
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color surfaceVariantLight = Color(
    0xFFf0f4f9,
  ); // from HTML line 33
  static const Color onSurfaceLight = Color(0xFF1f1f1f);
  static const Color onSurfaceVariantLight = Color(
    0xFF5F6368,
  ); // from HTML line 35
  static const Color outlineLight = Color(0xFFe5e7eb);

  static const Color backgroundDark = Color(0xFF0b0f14);
  static const Color surfaceDark = Color(0xFF111822);
  static const Color surfaceVariantDark = Color(0xFF17212d);
  static const Color onSurfaceDark = Color(0xFFe9eef5);
  static const Color onSurfaceVariantDark = Color(0xFFa9b4c0);
  static const Color outlineDark = Color(0xFF263241);

  // Shadows (Exact multi-shadows)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.30),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 3,
    ),
  ];

  static const List<BoxShadow> elevationPrimary = [
    BoxShadow(
      color: Color.fromRGBO(0, 86, 210, 0.16),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const Curve fastEase = Curves.easeOut;
  static const Curve standardEase = Cubic(0.2, 0.9, 0.2, 1);

  static const Duration overlayDuration = Duration(milliseconds: 180);
  static const Duration panelDuration = Duration(milliseconds: 220);
  static const Duration shortDuration = Duration(milliseconds: 140);
}

class HomeLayoutMetrics {
  const HomeLayoutMetrics({
    required this.viewportWidth,
    required this.viewportHeight,
    required this.safeTop,
    required this.safeBottom,
    required this.isCompact,
    required this.mainSheetHeight,
    required this.mainSheetTop,
    required this.mainSheetBottom,
    required this.mainSheetGap,
    required this.mainSheetTopPadding,
    required this.headerTop,
    required this.headerHorizontalMargin,
    required this.navHeightWithSafeArea,
    required this.markerTop,
    required this.safeBottomPadding,
    required this.uiScale,
  });

  final double viewportWidth;
  final double viewportHeight;
  final double safeTop;
  final double safeBottom;
  final bool isCompact;
  final double mainSheetHeight;
  final double mainSheetTop;
  final double mainSheetBottom;
  final double mainSheetGap;
  final double mainSheetTopPadding;
  final double headerTop;
  final double headerHorizontalMargin;
  final double navHeightWithSafeArea;
  final double markerTop;
  final double safeBottomPadding;
  final double uiScale;

  static HomeLayoutMetrics fromViewport({
    required Size size,
    required EdgeInsets safeArea,
  }) {
    // 1. Calculate UI Scale
    // baseScale = (viewportW - 16) / 390
    // clamps [0.55, 1.0]
    double uiScale = (size.width - 16) / HomeMobileSpec.designWidth;
    uiScale = uiScale.clamp(0.55, 1.00);

    // 2. Convert Vertical Dimensions to Design Space
    // All calculations below must use these design-space values.
    final designHeight = size.height / uiScale;
    final designSafeTop = safeArea.top / uiScale;
    final designSafeBottom = safeArea.bottom / uiScale;

    // HTML: .safe-bottom { padding-bottom: max(1.5rem, env(safe-area-inset-bottom)); }
    // 1.5rem = 24px (This constant is already in design pixels)
    final safeBottomPadding = designSafeBottom < HomeMobileSpec.safeBottomMin
        ? HomeMobileSpec.safeBottomMin
        : designSafeBottom;

    // --nav-h: 5.25rem = 84px
    final navHeightWithSafeArea =
        HomeMobileSpec.bottomNavHeight + safeBottomPadding;

    final isCompact = designHeight < HomeMobileSpec.compactViewportThreshold;

    // HTML: .safe-top { padding-top: max(1rem, env(safe-area-inset-top)); }
    // 1rem = 16px
    final headerTop = designSafeTop < HomeMobileSpec.safeTopMin
        ? HomeMobileSpec.safeTopMin
        : designSafeTop;

    // gap = 8
    final headerBottom =
        headerTop +
        HomeMobileSpec.headerHeight +
        HomeMobileSpec.headerVerticalGap;

    // #mainSheet { bottom: calc(var(--nav-h) - 2px); ... }
    final mainSheetBottom = navHeightWithSafeArea - 2;

    // const maxWithoutMap = Math.max(0, Math.floor(vh - navH - headerBottom - gap));
    // headerBottom already includes gap.
    final maxWithoutMap = designHeight - navHeightWithSafeArea - headerBottom;

    // const reserveMap = Math.round(clamp(vh * 0.22, 120, 240));
    final reserveMap = (designHeight * HomeMobileSpec.mapReserveRatio).clamp(
      HomeMobileSpec.mapReserveMin,
      HomeMobileSpec.mapReserveMax,
    );

    var sheetHeight = maxWithoutMap - reserveMap;

    // min-height: 360
    if (sheetHeight < 360) {
      sheetHeight = maxWithoutMap;
    }

    final mainSheetHeight = sheetHeight;
    final mainSheetTop = designHeight - mainSheetBottom - mainSheetHeight;

    // Marker positioning
    final markerMidPoint = (headerBottom + mainSheetTop) / 2;
    final markerMin = headerBottom + 10;

    final markerTop = (markerMidPoint - (HomeMobileSpec.markerSize / 2));
    final effectiveMarkerTop = markerTop < markerMin ? markerMin : markerTop;

    return HomeLayoutMetrics(
      viewportWidth: HomeMobileSpec.designWidth, // Effective width is 390
      viewportHeight: designHeight,
      safeTop: designSafeTop,
      safeBottom: designSafeBottom,
      isCompact: isCompact,
      mainSheetHeight: mainSheetHeight,
      mainSheetTop: mainSheetTop,
      mainSheetBottom: mainSheetBottom,
      mainSheetGap: isCompact ? 16 : 20,
      mainSheetTopPadding: isCompact ? 2 : 4,
      headerTop: headerTop,
      headerHorizontalMargin: HomeMobileSpec.headerInnerHorizontalMargin,
      navHeightWithSafeArea: navHeightWithSafeArea,
      markerTop: effectiveMarkerTop,
      safeBottomPadding: safeBottomPadding,
      uiScale: uiScale,
    );
  }
}

class TripOfferSpec {
  const TripOfferSpec({
    required this.id,
    required this.productCode,
    required this.title,
    required this.etaText,
    required this.seats,
    required this.priceIqd,
    required this.imageUrl,
  });

  final String id;
  final String productCode;
  final String title;
  final String etaText;
  final int seats;
  final int priceIqd;
  final String imageUrl;
}

const List<TripOfferSpec> kTripOffers = <TripOfferSpec>[
  TripOfferSpec(
    id: 'economy',
    productCode: 'standard',
    title: 'اقتصادي',
    etaText: '٤ د',
    seats: 4,
    priceIqd: 5000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCIDLB5HlUvglbC5GX4K_ypjsNeIqXL_fNOFr4Z5kzL99zPkzwc3Nu8alDuIvPowOviuVt6lrzVxh6rSGTN3s924XhSoEPgBej6Tstmo8pO3oxO010OmqCjUNvg31Yk1UgQ09-YCmKbXPH413ddL6Qt9GlrmzRnOkvoK1iXGDQnujRLl6XxaZ8Pv2KMhno7-FzII4zoTRm3abQXWgkjYGmL5YVLu9XW1CfrG5aCivDyBNx7DF-TrcqLhB_odLyiwFegP30YEwrpHA8',
  ),
  TripOfferSpec(
    id: 'comfort',
    productCode: 'comfort',
    title: 'مريح',
    etaText: '٦ د',
    seats: 4,
    priceIqd: 8000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBX2Ol-cZPEl3Rhl5OvBQFBVO0DdphWGwi9V_DnjykmbYEwHG3jWJY9I1V06Zz9gmCEDo8r3a-rUddhoSMpkJz4ZPjjRWaW8r4NwfbfLBL3TW8EP6IslFT-9GVQSuYtJodZ7dxgfQkzXqxo1A0HFbmLYdtvK_fXBMtpXA6QUWvm9rPcH_pNlSFYmxU-goBf1p_CavF2HDB-VYK7dLEUTMsSRr8Eu0UG-o14Uu8yZiEBYThTv768tv3q56PFNG7zwRk0oMRj-cFLSVM',
  ),
  TripOfferSpec(
    id: 'xl',
    productCode: 'xl',
    title: 'XL',
    etaText: '١٠ د',
    seats: 6,
    priceIqd: 12000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD_voF24aL_2i339jLIB3NAJXPDjnrA7ovWk6zfWCk38qo01a0pjESVqYZgt70Za_NMrAA0s9x3RpZtLKrx4IN1KfqTg56nue832R_8Wd70ar975n3pKEy6L3dPBRwlty2711cIrNZ_qTp1ZFk2jlLueAHklps1WGWxb9uPZNxwSVcwutYIwdfRn5HTPlj_WrrjJ1FEKGHdTjxp6gpolRDPqRPAua_eWTDuV83McrIlN4XG1wLdZOm1xZ0Fql-r3n1efZiXSoZeveI',
  ),
];

class HomeOfferMedia {
  const HomeOfferMedia({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
}

const List<HomeOfferMedia> kHomeOffers = <HomeOfferMedia>[
  HomeOfferMedia(
    title: 'توصيل غداء',
    subtitle: 'أسرع طلب خلال ٣٠ دقيقة',
    badge: 'خصم %10',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDa1OpvziRdgaDhV6v6hl0PbA9QZjYRdiBfNiULWAE8ilF-58F94YX1_waUERsBmvzi6ooDXv7qKLLhCZgKWzwyNw5dWY1GuIi5j5C-l9tpYoB4n5_1FXWlL-XF54rCZ02mZ5AeEpBD1l0li-Ljis7F1cfJLrlX9QXWXJxbJxrq_PlR8lyaNe4kwhaW7IqEEfLavMnki_tuWQzgPJyXHLA23LPU0oH5-bZckmK9PhpFB3m7vYk-j9l1YvW9zkm24sn-DWHs0NjcNdk',
  ),
  HomeOfferMedia(
    title: 'صيدلية',
    subtitle: 'أدوية واحتياجات طبية',
    badge: 'جديد',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCez7zU7CN_6b3I9y1Hes53z05RlJmpgQb0IFFwrdckKvtPod4a1VLGOcGHiOEJTRGWP6sx-IEpOdFnyzerfOvKabu_EfaHNhiK0eKI3dcJdTLsuMShW3DdwfilM-At0ufFVNa9R_qxDiuwfb7bFmVttYsBoiRPHeFvlZICk6c1FY4E5zDad_ItdbV4RjJLph7Pt92-oqOIDASLQ6huq4YRspLSQCvt0s3q6_KkxfOEZF_HSTCUWc0sXHeTf26bOVEGOWJpEcJTWBk',
  ),
];

const List<String> kDestinationSuggestionSeed = <String>[
  'المنزل',
  'العمل',
  'مول المنصور',
  'فندق بابل',
  'شارع المتنبي',
  'مطار بغداد الدولي',
  'ساحة التحرير',
  'جامعة القادسية',
];

const String kSampleAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA5t2RvnYHftI8CFO5at6edAac13ONigOguvdDdG7fNKRjyaOkm4AcQd3Q3oyWOLuLiNjM2dGHB2DuKs_LSb0FSI4ib1WkJuPKjBDxyqvnTunZIKw7-uH7XjiHUvCX1DDstNrYWP6Aq-S97IxS_r6gvfgUMG0TzjMbaNIDMzw_BipVLG7UwNl-t3eS0DQq-9PeQuV94P9ltfeIiUF2akWjk4EstA5dMKdyRQotHeLueEhnfEjwNkPuC2nIM9QgKsY4qGPlP-5ZJIvY';
