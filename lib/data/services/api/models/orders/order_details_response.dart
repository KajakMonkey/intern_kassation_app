import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/domain/models/order/order_details.dart';

part 'order_details_response.mapper.dart';

@MappableClass()
class OrderDetailsResponse with OrderDetailsResponseMappable {
  final String salesId;
  final String worktop;
  final String productType;
  @MappableField(key: 'produktionsOrder')
  final String productionOrder;

  OrderDetailsResponse({
    required this.salesId,
    required this.worktop,
    required this.productType,
    required this.productionOrder,
  });

  static const fromMap = OrderDetailsResponseMapper.fromMap;
  static const fromJson = OrderDetailsResponseMapper.fromJson;
}

extension OrderDetailsResponseX on OrderDetailsResponse {
  OrderDetails toDomain() {
    final productType = ProductType.fromCode(this.productType);
    return OrderDetails(
      salesId: salesId,
      worktop: worktop,
      productType: productType,
      productGroup: this.productType,
      productionOrder: productionOrder,
    );
  }
}
