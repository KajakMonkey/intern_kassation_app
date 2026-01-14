sealed class Parameters {}

class DiscardRouteParams extends Parameters {
  static const salesId = 'salesId';
  static const worktop = 'worktop';
  static const productType = 'productType';
  static const produktionsOrder = 'produktionsOrder';

  static const id = 'id';
}

class AccountRouteParams extends Parameters {
  static const redirectToUrl = 'redirectToUrl';
}
