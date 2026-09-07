import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/CustomAppBar/custom_app_bar.dart';
import '../../../Widgegt/navBar/nav_bar.dart';
import '../../BuyerScreen/buyer_demands_screen/buyer_demands_screen.dart';
import '../../BuyerScreen/buyer_home_screen/buyer_home_screen.dart';
import '../../BuyerScreen/buyer_orders_screen/buyer_orders_screen.dart';
import '../../BuyerScreen/buyer_profile_screen/buyer_profile_screen.dart';
import '../../BuyerScreen/buyer_search_screen/buyer_search_screen.dart';
import '../../Dialogs/add_demand_dialog/add_demand_dialog.dart';
import '../../Dialogs/add_product_dialog/add_product_dialog.dart';
import '../../Dialogs/buyer_offer_management_dialog/buyer_offer_management_dialog.dart';
import '../../Dialogs/dispute_report_dialog/dispute_report_dialog.dart';
import '../../Dialogs/farmer_send_offer_dialog/farmer_send_offer_dialog.dart';
import '../../Dialogs/notifications_dialog/notifications_dialog.dart';
import '../../Dialogs/order_chat_dialog/order_chat_dialog.dart';
import '../../Dialogs/order_detail_dialog/order_detail_dialog.dart';
import '../../Dialogs/product_detail_dialog/product_detail_dialog.dart';
import '../../Dialogs/rating_review_dialog/rating_review_dialog.dart';
import '../../Dialogs/role_switcher_dialog/role_switcher_dialog.dart';
import '../../Dialogs/weight_verification_dialog/weight_verification_dialog.dart';
import '../../FarmerScreen/farmer_demands_screen/farmer_demands_screen.dart';
import '../../FarmerScreen/farmer_home_screen/farmer_home_screen.dart';
import '../../FarmerScreen/farmer_orders_screen/farmer_orders_screen.dart';
import '../../FarmerScreen/farmer_products_screen/farmer_products_screen.dart';
import '../../FarmerScreen/farmer_profile_screen/farmer_profile_screen.dart';
import 'main_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = MainController(repo);

    Widget bodyWidget;
    List<CustomNavBarItem> navItems = [];
    int selectedIndex = 0;

    switch (repo.currentRole) {
      case UserRole.farmer:
        selectedIndex = repo.farmerTabIndex;
        navItems = [
          CustomNavBarItem(icon: Icons.home, label: 'হোম'),
          CustomNavBarItem(icon: Icons.inventory_2, label: 'আমার পণ্য'),
          CustomNavBarItem(icon: Icons.campaign, label: 'ক্রেতার চাহিদা'),
          CustomNavBarItem(icon: Icons.local_shipping, label: 'চলমান অর্ডার'),
          CustomNavBarItem(icon: Icons.person, label: 'প্রোফাইল'),
        ];
        switch (repo.farmerTabIndex) {
          case 0:
            bodyWidget = const FarmerHomeScreen();
            break;
          case 1:
            bodyWidget = const FarmerProductsScreen();
            break;
          case 2:
            bodyWidget = const FarmerDemandsScreen();
            break;
          case 3:
            bodyWidget = const FarmerOrdersScreen();
            break;
          case 4:
            bodyWidget = const FarmerProfileScreen();
            break;
          default:
            bodyWidget = const FarmerHomeScreen();
        }
        break;

      case UserRole.buyer:
        selectedIndex = repo.buyerTabIndex;
        navItems = [
          CustomNavBarItem(icon: Icons.home, label: 'হোম'),
          CustomNavBarItem(icon: Icons.search, label: 'ফসল খুঁজুন'),
          CustomNavBarItem(icon: Icons.assignment, label: 'আমার চাহিদা'),
          CustomNavBarItem(icon: Icons.shopping_cart, label: 'ক্রয় অর্ডার'),
          CustomNavBarItem(icon: Icons.business, label: 'প্রোফাইল'),
        ];
        switch (repo.buyerTabIndex) {
          case 0:
            bodyWidget = const BuyerHomeScreen();
            break;
          case 1:
            bodyWidget = const BuyerSearchScreen();
            break;
          case 2:
            bodyWidget = const BuyerDemandsScreen();
            break;
          case 3:
            bodyWidget = const BuyerOrdersScreen();
            break;
          case 4:
            bodyWidget = const BuyerProfileScreen();
            break;
          default:
            bodyWidget = const BuyerHomeScreen();
        }
        break;
    }

    return Scaffold(
      appBar: CustomAppBar(
        currentRole: repo.currentRole,
        unreadNotifications: repo.notifications.where((n) => !n.isRead).length,
        onNotificationsClick: repo.openNotifications,
      ),
      body: Stack(
        children: [
          bodyWidget,
          if (repo.showAddProductDialog) const AddProductDialog(),
          if (repo.showAddDemandDialog) const AddDemandDialog(),
          if (repo.activeDemandForOffer != null)
            FarmerSendOfferDialog(demand: repo.activeDemandForOffer!),
          if (repo.activeDemandForOfferManagement != null)
            BuyerOfferManagementDialog(demand: repo.activeDemandForOfferManagement!),
          if (repo.activeProductForDetail != null)
            ProductDetailDialog(product: repo.activeProductForDetail!),
          if (repo.activeOrderForDetail != null)
            OrderDetailDialog(order: repo.activeOrderForDetail!),
          if (repo.activeOrderForChat != null)
            OrderChatDialog(order: repo.activeOrderForChat!),
          if (repo.activeOrderForDispute != null)
            DisputeReportDialog(order: repo.activeOrderForDispute!),
          if (repo.activeOrderForRating != null)
            RatingReviewDialog(order: repo.activeOrderForRating!),
          if (repo.activeOrderForVerification != null)
            WeightVerificationDialog(order: repo.activeOrderForVerification!),
          if (repo.showNotificationsSheet) const NotificationsDialog(),
          if (repo.showRoleSwitcherDialog) const RoleSwitcherDialog(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: selectedIndex,
        items: navItems,
        onItemSelected: controller.onTabSelected,
      ),
    );
  }
}
