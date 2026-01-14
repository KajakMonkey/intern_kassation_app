// TODO: Add All product types used in the system
enum ProductType {
  unknown(code: 'UNKNOWN'),
  // Stenprodukter
  fokusCorian(code: 'CF'),
  corian(code: 'CO'),
  compactGranite(code: 'NC'),
  dekton(code: 'ND'),
  fokusGranit(code: 'NF'),
  kvikDekton(code: 'NT'),
  terrazzo(code: 'TE'),
  ceramics(code: 'ZA'),
  kvikKermik(code: 'ZC'),
  granit(code: 'NA')
  ;

  const ProductType({required this.code});

  final String code;

  static ProductType fromCode(String value) => switch (value.toUpperCase()) {
    // Stenprodukter
    'NA' => ProductType.granit,
    'CF' => ProductType.fokusCorian,
    'CO' => ProductType.corian,
    'NC' => ProductType.compactGranite,
    'ND' => ProductType.dekton,
    'NF' => ProductType.fokusGranit,
    'NT' => ProductType.kvikDekton,
    'TE' => ProductType.terrazzo,
    'ZA' => ProductType.ceramics,
    'ZC' => ProductType.kvikKermik,
    _ => ProductType.unknown,
  };

  bool get isStoneProduct => switch (this) {
    ProductType.fokusCorian ||
    ProductType.corian ||
    ProductType.compactGranite ||
    ProductType.dekton ||
    ProductType.fokusGranit ||
    ProductType.kvikDekton ||
    ProductType.terrazzo ||
    ProductType.ceramics ||
    ProductType.granit => true,
    _ => false,
  };
}
