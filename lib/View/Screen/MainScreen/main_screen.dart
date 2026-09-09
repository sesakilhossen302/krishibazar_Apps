import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/CustomAppBar/custom_app_bar.dart';
import '../../Widgegt/navBar/nav_bar.dart';
import '../BuyerScreen/buyer_demands_screen.dart';
import '../BuyerScreen/buyer_home_screen.dart';
import '../BuyerScreen/buyer_orders_screen.dart';
import '../BuyerScreen/buyer_profile_screen.dart';
import '../BuyerScreen/buyer_search_screen.dart';
import '../Dialogs/add_demand_dialog.dart';
import '../Dialogs/add_product_dialog/add_product_dialog.dart';
import '../Dialogs/buyer_offer_management_dialog.dart';
import '../Dialogs/demand_detail_dialog/demand_detail_dialog.dart';
import '../Dialogs/dispute_report_dialog.dart';
import '../Dialogs/farmer_send_offer_dialog.dart';
import '../Dialogs/notifications_dialog.dart';
import '../Dialogs/order_chat_dialog.dart';
import '../Dialogs/order_detail_dialog.dart';
import '../Dialogs/role_switcher_dialog.dart';
import '../Dialogs/weight_verification_dialog.dart';
import '../FarmerScreen/farmer_demands_screen.dart';
import '../FarmerScreen/farmer_home_screen.dart';
import '../FarmerScreen/farmer_orders_screen.dart';
import '../FarmerScreen/farmer_products_screen.dart';
import '../FarmerScreen/farmer_profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();

    Widget bodyWidget;
    List<CustomNavBarItem> navItems = [];
    int selectedIndex = 0;

    switch (controller.currentRole) {
      case UserRole.farmer:
        selectedIndex = controller.farmerTabIndex;
        navItems = [
          CustomNavBarItem(icon: Icons.home, label: 'হোম'),
          CustomNavBarItem(icon: Icons.inventory_2, label: 'আমার ফসল'),
          CustomNavBarItem(icon: Icons.campaign, label: 'চাহিদা'),
          CustomNavBarItem(icon: Icons.local_shipping, label: 'অর্ডার'),
          CustomNavBarItem(icon: Icons.person, label: 'প্রোফাইল'),
        ];
        switch (controller.farmerTabIndex) {
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
        selectedIndex = controller.buyerTabIndex;
        navItems = [
          CustomNavBarItem(icon: Icons.home, label: 'হোম'),
          CustomNavBarItem(icon: Icons.search, label: 'ফসল খুঁজুন'),
          CustomNavBarItem(icon: Icons.assignment, label: 'আমার চাহিদা'),
          CustomNavBarItem(icon: Icons.shopping_cart, label: 'ক্রয় অর্ডার'),
          CustomNavBarItem(icon: Icons.business, label: 'প্রোফাইল'),
        ];
        switch (controller.buyerTabIndex) {
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
        currentRole: controller.currentRole,
        unreadNotifications: controller.notifications.where((n) => !n.isRead).length,
        onNotificationsClick: () => controller.openNotifications(),
      ),
      body: Stack(
        children: [
          bodyWidget,

          // Active Overlay Dialogs
          if (controller.showAddProductDialog) const AddProductDialog(),
          if (controller.showAddDemandDialog) const AddDemandDialog(),
          if (controller.activeDemandForOffer != null)
            FarmerSendOfferDialog(demand: controller.activeDemandForOffer!),
          if (controller.activeDemandForOfferManagement != null)
            BuyerOfferManagementDialog(demand: controller.activeDemandForOfferManagement!),
          if (controller.activeDemandForDetail != null)
            DemandDetailDialog(demand: controller.activeDemandForDetail!),
          if (controller.activeOrderForDetail != null)
            OrderDetailDialog(order: controller.activeOrderForDetail!),
          if (controller.activeOrderForChat != null)
            OrderChatDialog(order: controller.activeOrderForChat!),
          if (controller.activeOrderForDispute != null)
            DisputeReportDialog(order: controller.activeOrderForDispute!),
          if (controller.activeOrderForVerification != null)
            WeightVerificationDialog(order: controller.activeOrderForVerification!),
          if (controller.showNotificationsSheet) const NotificationsDialog(),
          if (controller.showRoleSwitcherDialog) const RoleSwitcherDialog(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: selectedIndex,
        items: navItems,
        onItemSelected: (index) {
          switch (controller.currentRole) {
            case UserRole.farmer:
              controller.setFarmerTab(index);
              break;
            case UserRole.buyer:
              controller.setBuyerTab(index);
              break;
          }
        },
      ),
    );
  }
}
