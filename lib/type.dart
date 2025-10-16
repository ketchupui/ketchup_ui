// ignore_for_file: constant_identifier_names

enum PNGSize {
  size_quarter,
  size_half,
  size_standard_1x,
  size_large_2x,
  others
}

typedef PatchAsset = ({PNGSize pngSize, String asset});
