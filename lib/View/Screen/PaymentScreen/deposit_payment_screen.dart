import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../../service/api_client.dart';
import '../../Widgegt/image_picker_dialog/image_picker_dialog.dart';

class DepositPaymentScreen extends StatefulWidget {
  final MarketplaceOrder order;

  const DepositPaymentScreen({super.key, required this.order});

  @override
  State<DepositPaymentScreen> createState() => _DepositPaymentScreenState();
}

class _DepositPaymentScreenState extends State<DepositPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<PaymentSettingModel> _paymentMethods = [];
  bool _isLoadingMethods = true;
  String? _selectedMethodName;
  File? _screenshotFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    if (widget.order.depositSenderPhone.isNotEmpty) {
      _senderPhoneController.text = widget.order.depositSenderPhone;
    }
  }

  @override
  void dispose() {
    _senderPhoneController.dispose();
    _trxIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoadingMethods = true);
    try {
      final methods = await ApiClient.fetchPaymentMethods();
      if (mounted) {
        setState(() {
          // Only display methods that are active
          _paymentMethods = methods.where((m) => m.isActive).toList();
          if (_paymentMethods.isNotEmpty) {
            _selectedMethodName = _paymentMethods.first.name;
          }
          _isLoadingMethods = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMethods = false);
    }
  }

  Future<void> _pickScreenshot() async {
    final file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file != null) {
      setState(() {
        _screenshotFile = file;
      });
    }
  }

  void _copyToClipboard(String text, String methodLabel) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$methodLabel নম্বর ($text) কপি করা হয়েছে!'),
        backgroundColor: const Color(0xFF166534),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getMethodColor(String name) {
    switch (name.toLowerCase()) {
      case 'bkash':
        return const Color(0xFFD8226A);
      case 'nagad':
        return const Color(0xFFEA580C);
      case 'rocket':
        return const Color(0xFF8C3494);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getMethodIcon(String name) {
    switch (name.toLowerCase()) {
      case 'bkash':
      case 'nagad':
      case 'rocket':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment;
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMethodName == null || _selectedMethodName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে একটি পেমেন্ট মেথড নির্বাচন করুন।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final repo = Provider.of<KrishiRepository>(context, listen: false);
    final res = await repo.submitDepositPaymentProof(
      orderId: widget.order.id,
      paymentMethod: _selectedMethodName!,
      senderPhone: _senderPhoneController.text.trim(),
      transactionId: _trxIdController.text.trim(),
      screenshotFile: _screenshotFile,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF166534), size: 28),
              SizedBox(width: 10),
              Text(
                'পেমেন্ট জমা সম্পন্ন ✅',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
              ),
            ],
          ),
          content: const Text(
            'আপনার ডেলিভারি ও সার্ভিস চার্জের তথ্য ও প্রমাণাদি এডমিন শাখায় পাঠানো হয়েছে। এডমিন টাকা প্রাপ্তি যাচাই করে পণ্য পরিবহনের জন্য রওনা করাবেন।',
            style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close DepositPaymentScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'পেমেন্ট জমা দিতে সমস্যা হয়েছে।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final hasFeedback = order.depositAdminFeedback.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ডেলিভারি ও সার্ভিস চার্জ পরিশোধ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin discrepancy warning banner if resubmitting
              if (hasFeedback) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'এডমিন ফিডব্যাক (সংশোধন প্রয়োজন):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.depositAdminFeedback,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'দয়া করে সঠিক নম্বর, TrxID ও পেমেন্ট স্লিপের স্ক্রিনশট দিয়ে পুনরায় জমা দিন।',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFB91C1C), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'অর্ডার #${order.orderNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        Text(
                          'মোট পণ্য মূল্য: ৳${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.productTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ডেলিভারি চার্জ (চার্ট অনুযায়ী):', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        Text('৳ ${order.deliveryCharge.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('কৃষিবাজার সার্ভিস ফি (৫%):', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        Text('৳ ${(order.totalAmount * 0.05).toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),

                    // Advance Charges Highlight Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'মোট অগ্রিম প্রদেয় চার্জ',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '(ডেলিভারি চার্জ + প্ল্যাটফর্ম ফি)',
                                style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                          Text(
                            '৳ ${(order.advancePayableAmount > 0 ? order.advancePayableAmount : order.depositRequired).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Payment Methods Heading
              Row(
                children: const [
                  Icon(Icons.account_balance_outlined, color: Color(0xFF166534), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'পেমেন্ট মেথড ও একাউন্ট নম্বর',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'নিচের যেকোনো একটি সক্রিয় নম্বরে টাকা পাঠিয়ে তথ্য দিন:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // Payment Methods List
              if (_isLoadingMethods)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_paymentMethods.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'বর্তমানে কোনো পেমেন্ট গেটওয়ে সক্রিয় নেই। দয়া করে এডমিনের সাথে যোগাযোগ করুন।',
                    style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                  ),
                )
              else
                Column(
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedMethodName == method.name;
                    final brandColor = _getMethodColor(method.name);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMethodName = method.name;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? brandColor : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: brandColor.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? brandColor : const Color(0xFFCBD5E1),
                                      width: isSelected ? 6 : 2,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: brandColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getMethodIcon(method.name), color: brandColor, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.displayNameBn,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? brandColor : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          method.accountTypeBn,
                                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Account Number Box with Copy Button
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'অ্যাকাউন্ট নম্বর:',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          method.accountNumber.isNotEmpty
                                              ? method.accountNumber
                                              : 'নম্বর শীঘ্রই দেওয়া হবে',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (method.accountNumber.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () => _copyToClipboard(method.accountNumber, method.displayNameBn),
                                      icon: const Icon(Icons.copy, size: 14, color: Colors.white),
                                      label: const Text(
                                        'কপি করুন',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: brandColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            if (method.instructions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '📌 ${method.instructions}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 18),

              // Sender Payment Proof Inputs
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'আপনার প্রেরিত পেমেন্টের তথ্য দিন:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),

                    // Sender Mobile Number
                    const Text(
                      'প্রেরকের মোবাইল নম্বর *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _senderPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'যে নম্বর থেকে টাকা পাঠিয়েছেন (যেমন: 017xxxxxxxx)',
                        prefixIcon: const Icon(Icons.phone_android, size: 18, color: Color(0xFF166534)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'প্রেরকের মোবাইল নম্বর দেওয়া আবশ্যক';
                        }
                        if (val.trim().length < 11) {
                          return 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Transaction ID
                    const Text(
                      'ট্রানজেকশন আইডি (TrxID) *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _trxIdController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'পেমেন্টের পর প্রাপ্ত TrxID (যেমন: 9J83KSD91)',
                        prefixIcon: const Icon(Icons.receipt_long, size: 18, color: Color(0xFF166534)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'ট্রানজেকশন আইডি (TrxID) দেওয়া আবশ্যক';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Payment Screenshot Uploader
                    const Text(
                      'পেমেন্টের স্ক্রিনশট (প্রমাণ হিসেবে)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),

                    if (_screenshotFile == null)
                      InkWell(
                        onTap: _pickScreenshot,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.add_photo_alternate_outlined, size: 36, color: Color(0xFF166534)),
                              SizedBox(height: 8),
                              Text(
                                'স্ক্রিনশট আপলোড করতে ট্যাপ করুন',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'গ্যালারি বা ক্যামেরা থেকে পেমেন্ট স্লিপের ছবি যুক্ত করুন',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _screenshotFile!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'স্ক্রিনশট নির্বাচিত ✅',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _screenshotFile!.path.split(Platform.pathSeparator).last,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _pickScreenshot,
                              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                              tooltip: 'পরিবর্তন করুন',
                            ),
                            IconButton(
                              onPressed: () => setState(() => _screenshotFile = null),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'মুছে ফেলুন',
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Optional Notes
                    const Text(
                      'অতিরিক্ত মন্তব্য (যদি থাকে)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'যেমন: জরুরি ভিত্তিতে ডেলিভারি প্রয়োজন...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitPayment,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.verified, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'তথ্য যাচাই ও জমা হচ্ছে...' : 'পেমেন্ট নিশ্চিত করুন ও জমা দিন',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
