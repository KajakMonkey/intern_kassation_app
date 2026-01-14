import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';

part 'order_details.mapper.dart';

@MappableClass()
class OrderDetails with OrderDetailsMappable {
  final String salesId;
  final String worktop;
  final ProductType productType;
  final String productionOrder;

  OrderDetails({
    required this.salesId,
    required this.worktop,
    required this.productType,
    required this.productionOrder,
  });
}
