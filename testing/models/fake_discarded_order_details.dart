import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';

import 'fake_data_time.dart';

final kDiscardedOrderDetails = DiscardedOrderDetails(
  id: 1,
  prodId: 'PROD123',
  salesId: 'SAL456',
  discardedAtUtc: kDateTime,
  employeeId: 'EMP789',
  errorCode: 'E001',
  note: 'Sample discarded order',
  productType: 'TypeA',
  worktop: 'Worktop1',
  errorDescription: 'Defective item',
  machineName: 'MachineX',
);
