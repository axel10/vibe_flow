import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/player/pro/app_channel.dart';
import 'package:vynody/player/pro/pro_license_service.dart';

/// Product ID configured in App Store Connect.
const String kProLifetimeProductId = 'com.vynody.pro_lifetime';

/// State of In-App Purchase.
class IapState {
  const IapState({
    this.isAvailable = false,
    this.isLoadingProduct = false,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.proProduct,
    this.errorMessage,
  });

  final bool isAvailable;
  final bool isLoadingProduct;
  final bool isPurchasing;
  final bool isRestoring;
  final ProductDetails? proProduct;
  final String? errorMessage;

  IapState copyWith({
    bool? isAvailable,
    bool? isLoadingProduct,
    bool? isPurchasing,
    bool? isRestoring,
    ProductDetails? proProduct,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IapState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      proProduct: proProduct ?? this.proProduct,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Service managing In-App Purchases for Store releases.
class IapService extends ChangeNotifier {
  IapService(this._ref) {
    _init();
  }

  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  IapState _state = const IapState();
  IapState get state => _state;

  void _updateState(IapState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _init() async {
    // If GitHub release, Pro is always permanently unlocked, no need for IAP stream.
    if (AppChannel.isGitHubRelease) return;

    // Listen to purchase events stream
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (dynamic error) {
        debugPrint('[IAP] Purchase stream error: $error');
        _updateState(_state.copyWith(
          isPurchasing: false,
          isRestoring: false,
          errorMessage: error.toString(),
        ));
      },
    );

    await loadProducts();
  }

  /// Query product details from App Store.
  Future<void> loadProducts() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('[IAP] Store is not available on this device');
        _updateState(_state.copyWith(isAvailable: false));
        return;
      }

      _updateState(_state.copyWith(isAvailable: true, isLoadingProduct: true));

      final ProductDetailsResponse response =
          await _iap.queryProductDetails({kProLifetimeProductId});

      if (response.error != null) {
        debugPrint('[IAP] Query products error: ${response.error?.message}');
        _updateState(_state.copyWith(
          isLoadingProduct: false,
          errorMessage: response.error?.message,
        ));
        return;
      }

      ProductDetails? matchedProduct;
      for (final product in response.productDetails) {
        if (product.id == kProLifetimeProductId) {
          matchedProduct = product;
          break;
        }
      }

      _updateState(_state.copyWith(
        isLoadingProduct: false,
        proProduct: matchedProduct,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('[IAP] Failed to load products: $e');
      _updateState(_state.copyWith(
        isLoadingProduct: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Trigger buying the lifetime Pro product.
  Future<bool> buyPro() async {
    if (_state.isPurchasing) return false;

    // Ensure product details are loaded
    ProductDetails? product = _state.proProduct;
    if (product == null) {
      await loadProducts();
      product = _state.proProduct;
    }

    if (product == null) {
      showToast('无法连接应用商店获取商品信息，请检查网络后重试');
      return false;
    }

    _updateState(_state.copyWith(isPurchasing: true, clearError: true));

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _updateState(_state.copyWith(isPurchasing: false));
      }
      return success;
    } catch (e) {
      debugPrint('[IAP] buyPro exception: $e');
      _updateState(_state.copyWith(
        isPurchasing: false,
        errorMessage: e.toString(),
      ));
      showToast('发起购买失败: $e');
      return false;
    }
  }

  /// Restore previously purchased items.
  Future<void> restorePurchases() async {
    if (_state.isRestoring) return;

    _updateState(_state.copyWith(isRestoring: true, clearError: true));

    try {
      await _iap.restorePurchases();
      // Note: restorePurchases triggers purchaseStream, where items are handled.
    } catch (e) {
      debugPrint('[IAP] restorePurchases exception: $e');
      _updateState(_state.copyWith(
        isRestoring: false,
        errorMessage: e.toString(),
      ));
      showToast('恢复购买失败: $e');
    } finally {
      // Allow a brief delay for transactions to propagate before clearing restoring status
      Future.delayed(const Duration(seconds: 2), () {
        if (_state.isRestoring) {
          _updateState(_state.copyWith(isRestoring: false));
        }
      });
    }
  }

  /// Handle incoming purchase details from the stream.
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint('[IAP] Purchase update: ${purchaseDetails.productID} -> ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _updateState(_state.copyWith(isPurchasing: true));
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchaseDetails.productID == kProLifetimeProductId) {
            // Unlock Pro license
            await _ref.read(proLicenseServiceProvider).setPurchased(true);
            showToast(purchaseDetails.status == PurchaseStatus.restored
                ? '已成功恢复 Vynody Pro 购买记录！'
                : '恭喜！已成功解锁 Vynody Pro 永久会员！');
          }

          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }

          _updateState(_state.copyWith(
            isPurchasing: false,
            isRestoring: false,
            clearError: true,
          ));
          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] Purchase error: ${purchaseDetails.error?.message}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          _updateState(_state.copyWith(
            isPurchasing: false,
            isRestoring: false,
            errorMessage: purchaseDetails.error?.message,
          ));
          if (purchaseDetails.error?.message != null) {
            showToast('购买未完成: ${purchaseDetails.error?.message}');
          }
          break;

        case PurchaseStatus.canceled:
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          _updateState(_state.copyWith(
            isPurchasing: false,
            isRestoring: false,
          ));
          break;
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [IapService].
final iapServiceProvider = ChangeNotifierProvider<IapService>((ref) {
  return IapService(ref);
});

/// Riverpod provider for [IapState].
final iapStateProvider = Provider<IapState>((ref) {
  final service = ref.watch(iapServiceProvider);
  return service.state;
});
