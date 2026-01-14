import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_order.dart';

final kDiscardOrder = DiscardOrder(
  productionOrder: 'PROD123',
  errorCode: 'ERR001',
  note: 'Defective item',
  employeeId: 'EMP456',
  reportDate: DateTime.now(),
  salesId: 'SAL789',
  worktop: 'WorktopA',
  productType: ProductType.granit,
  machine: 'MachineX',
);

final kDiscardOrderWithImages = DiscardOrder(
  productionOrder: 'PROD123',
  errorCode: 'ERR001',
  note: 'Defective item',
  employeeId: 'EMP456',
  reportDate: DateTime.now(),
  salesId: 'SAL789',
  worktop: 'WorktopA',
  productType: ProductType.granit,
  machine: 'MachineX',
  imagePaths: ['/path/to/image1.jpg', '/path/to/image2.png'],
);
