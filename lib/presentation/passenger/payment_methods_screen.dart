import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': AppConstants.paymentMethodCash,
      'title': 'Cash',
      'subtitle': 'Pay directly to driver',
      'isDefault': true,
    },
  ];

  bool _showAdditionalMethods = false;
  Widget _getPaymentImage(String type) {
    switch (type) {
      case AppConstants.paymentMethodCash:
        return Image.asset(
          'assets/images/cash.png',
        );
      case AppConstants.paymentMethodEasyPaisa:
        return Image.asset(
          'assets/images/img.png', // ✅ put your EasyPaisa logo in assets
          width: 24,
          height: 24,
        );
      case AppConstants.paymentMethodJazzCash:
        return Image.asset(
          'assets/images/jz.png', // ✅ put your JazzCash logo in assets
          width: 24,
          height: 24,
        );
      default:
        return const SizedBox();
    }
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // your action here
                  print("Add payment method pressed");
                },
              ),
              // ),
              title: const Text('Cash'),
              subtitle: const Text('Pay directly to driver'),
              onTap: () {
                Navigator.pop(context);
                _addCashPayment();
              },
            ),
            const Divider(),
            ListTile(
              leading:  Image.asset(
                'assets/images/img.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              title: const Text('EasyPaisa'),
              onTap: () {
                Navigator.pop(context);
                _addEasyPaisaPayment();
              },
            ),
            const Divider(),
            ListTile(
              leading:Image.asset(
                'assets/images/jz.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              title: const Text('JazzCash'),
              onTap: () {
                Navigator.pop(context);
                _addJazzCashPayment();
              },
            ),
            const Divider(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addCashPayment() {
    setState(() {
      _paymentMethods.add({
        'type': AppConstants.paymentMethodCash,
        'title': 'Cash',
        'subtitle': 'Pay directly to driver',
        'isDefault': false,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cash payment method added'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _addEasyPaisaPayment() {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add EasyPaisa'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '03XXXXXXXXX',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _paymentMethods.add({
                    'type': AppConstants.paymentMethodEasyPaisa,
                    'title': 'EasyPaisa',
                    'subtitle': phoneController.text,
                    'isDefault': false,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('EasyPaisa added successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addJazzCashPayment() {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add JazzCash'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '03XXXXXXXXX',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _paymentMethods.add({
                    'type': AppConstants.paymentMethodJazzCash,
                    'title': 'JazzCash',
                    'subtitle': phoneController.text,
                    'isDefault': false,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JazzCash added successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (var i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i]['isDefault'] = (i == index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default payment method updated'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deletePaymentMethod(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method deleted'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Payment Methods'),
        ),
        body: _paymentMethods.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No payment methods',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a payment method to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddPaymentMethodDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
              ),
            ],
          ),
        )
            :ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cash Payment Method (always visible)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/cash.png', fit: BoxFit.contain),
                ),
                title: Row(
                  children: [
                    const Text('Cash'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: const Text('Pay directly to driver'),
                trailing: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/img.png', fit: BoxFit.contain),
                ),
              ),
            ),

            // Added payment methods (excluding Cash)
            ..._paymentMethods.where((m) => m['type'] != AppConstants.paymentMethodCash).map((method) {
              final index = _paymentMethods.indexOf(method);
              final isDefault = method['isDefault'] as bool;

              String imagePath;
              if (method['type'] == AppConstants.paymentMethodEasyPaisa) {
                imagePath = 'assets/images/img.png';
              } else if (method['type'] == AppConstants.paymentMethodJazzCash) {
                imagePath = 'assets/images/jz.png';
              } else {
                imagePath = 'assets/images/cash.png';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/cash.png', fit: BoxFit.contain),
                  ),
                  title: Row(
                    children: [
                      Text(method['title'] as String),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(method['subtitle'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isDefault)
                        IconButton(
                          icon: const Icon(Icons.star_outline, color: AppTheme.primaryColor),
                          onPressed: () => _setDefault(index),
                          tooltip: 'Set as default',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () => _deletePaymentMethod(index),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Additional Payment Methods (shown when icon is clicked)
            if (_showAdditionalMethods) ...[
              // EasyPaisa Add Option
              if (!_paymentMethods.any((m) => m['type'] == AppConstants.paymentMethodEasyPaisa))
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/images/img.png', fit: BoxFit.contain),
                    ),
                    title: const Text('EasyPaisa'),
                    subtitle: const Text('Tap to add EasyPaisa'),
                    trailing: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/images/img.png', fit: BoxFit.contain),
                    ),
                    onTap: _addEasyPaisaPayment,
                  ),
                ),

// JazzCash Add Option
              if (!_paymentMethods.any((m) => m['type'] == AppConstants.paymentMethodJazzCash))
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/images/jz.png', fit: BoxFit.contain),
                    ),
                    title: const Text('JazzCash'),
                    subtitle: const Text('Tap to add JazzCash'),
                    trailing: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset('assets/images/jz.png', fit: BoxFit.contain),
                    ),
                    onTap: _addJazzCashPayment,
                  ),
                ),
            ],
          ],
        )

    );
  }
}

// import 'package:flutter/material.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/constants/app_constants.dart';
//
// class PaymentMethodsScreen extends StatefulWidget {
//   const PaymentMethodsScreen({super.key});
//
//   @override
//   State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
// }
//
// class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
//   final List<Map<String, dynamic>> _paymentMethods = [
//     {
//       'type': AppConstants.paymentMethodCash,
//       'title': 'Cash',
//       'subtitle': 'Pay directly to driver',
//       'isDefault': true,
//     },
//   ];
//
//   bool _showAdditionalMethods = false;
//
//   Widget _getPaymentImage(String type) {
//     switch (type) {
//       case AppConstants.paymentMethodCash:
//         return Image.asset('assets/images/cash.png', width: 40, height: 40);
//       case AppConstants.paymentMethodEasyPaisa:
//         return Image.asset('assets/images/img.png', width: 40, height: 40);
//       case AppConstants.paymentMethodJazzCash:
//         return Image.asset('assets/images/jz.png', width: 40, height: 40);
//       default:
//         return const SizedBox();
//     }
//   }
//
//   void _addEasyPaisaPayment() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add EasyPaisa'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.phone,
//           decoration: const InputDecoration(hintText: '03XXXXXXXXX'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _paymentMethods.add({
//                   'type': AppConstants.paymentMethodEasyPaisa,
//                   'title': 'EasyPaisa',
//                   'subtitle': controller.text,
//                   'isDefault': false,
//                 });
//                 _showAdditionalMethods = false;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addJazzCashPayment() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add JazzCash'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.phone,
//           decoration: const InputDecoration(hintText: '03XXXXXXXXX'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _paymentMethods.add({
//                   'type': AppConstants.paymentMethodJazzCash,
//                   'title': 'JazzCash',
//                   'subtitle': controller.text,
//                   'isDefault': false,
//                 });
//                 _showAdditionalMethods = false;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Methods'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// CASH (DEFAULT)
//           Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: _getPaymentImage(AppConstants.paymentMethodCash),
//               title: Row(
//                 children: [
//                   const Text('Cash'),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: AppTheme.successColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       'Default',
//                       style: TextStyle(
//                         color: AppTheme.successColor,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               subtitle: const Text('Pay directly to driver'),
//
//               /// ➕ PLUS ICON ONLY HERE
//               trailing: IconButton(
//                 icon: const Icon(Icons.add, color: AppTheme.primaryColor),
//                 onPressed: () {
//                   setState(() {
//                     _showAdditionalMethods = !_showAdditionalMethods;
//                   });
//                 },
//               ),
//             ),
//           ),
//
//           /// ADDED METHODS
//           ..._paymentMethods
//               .where((m) => m['type'] != AppConstants.paymentMethodCash)
//               .map((method) => Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: _getPaymentImage(method['type']),
//               title: Text(method['title']),
//               subtitle: Text(method['subtitle']),
//             ),
//           )),
//
//           /// ADD OPTIONS (VISIBLE AFTER +)
//           if (_showAdditionalMethods) ...[
//             if (!_paymentMethods.any((m) => m['type'] == AppConstants.paymentMethodEasyPaisa))
//               Card(
//                 child: ListTile(
//                   leading: _getPaymentImage(AppConstants.paymentMethodEasyPaisa),
//                   title: const Text('EasyPaisa'),
//                   subtitle: const Text('Tap to add EasyPaisa'),
//                   onTap: _addEasyPaisaPayment,
//                 ),
//               ),
//             if (!_paymentMethods.any((m) => m['type'] == AppConstants.paymentMethodJazzCash))
//               Card(
//                 child: ListTile(
//                   leading: _getPaymentImage(AppConstants.paymentMethodJazzCash),
//                   title: const Text('JazzCash'),
//                   subtitle: const Text('Tap to add JazzCash'),
//                   onTap: _addJazzCashPayment,
//                 ),
//               ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
