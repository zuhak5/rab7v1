enum MapProviderCode { google, mapbox, here, thunderforest, ors }

extension MapProviderCodeValue on MapProviderCode {
  String get value {
    switch (this) {
      case MapProviderCode.google:
        return 'google';
      case MapProviderCode.mapbox:
        return 'mapbox';
      case MapProviderCode.here:
        return 'here';
      case MapProviderCode.thunderforest:
        return 'thunderforest';
      case MapProviderCode.ors:
        return 'ors';
    }
  }
}

MapProviderCode? mapProviderCodeFromValue(String raw) {
  switch (raw) {
    case 'google':
      return MapProviderCode.google;
    case 'mapbox':
      return MapProviderCode.mapbox;
    case 'here':
      return MapProviderCode.here;
    case 'thunderforest':
      return MapProviderCode.thunderforest;
    case 'ors':
      return MapProviderCode.ors;
    default:
      return null;
  }
}
