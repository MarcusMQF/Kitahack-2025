import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import 'package:intl/intl.dart';

class Voucher {
  final String id;
  final String title;
  final String description;
  final String code;
  final DateTime expiryDate;
  final bool isUsed;
  final String provider;
  final List<String> terms;
  final String imagePath;

  Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.expiryDate,
    this.isUsed = false,
    required this.provider,
    required this.terms,
    required this.imagePath,
  });
}

class MyVouchersPage extends StatefulWidget {
  const MyVouchersPage({super.key});

  @override
  State<MyVouchersPage> createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample voucher data - would come from rewards service in production
  final List<Voucher> _activeVouchers = [
    Voucher(
      id: 'v001',
      title: 'Free Coffee at Starbucks',
      description: 'One tall coffee of your choice at any Starbucks outlet in the city.',
      code: 'TRNSCF2023',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      provider: 'Starbucks',
      terms: [
        'Valid for one tall coffee only',
        'Cannot be combined with other promotions',
        'Valid at all participating Starbucks outlets',
        'Show this voucher to the cashier before payment',
        'No cash value'
      ],
      imagePath: 'lib/images/coffee_voucher.png',
    ),
    Voucher(
      id: 'v002',
      title: 'RM5 Grab Voucher',
      description: 'RM5 off your next Grab ride. Minimum fare RM15.',
      code: 'TRNSGRB5',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      provider: 'Grab',
      terms: [
        'Minimum ride fare of RM15',
        'Valid for GrabCar only',
        'Cannot be used for GrabFood or GrabMart',
        'Limited to one use per account',
      ],
      imagePath: 'lib/images/grab_voucher.png',
    ),
  ];
  
  final List<Voucher> _usedVouchers = [
    Voucher(
      id: 'v003',
      title: 'Free Movie Ticket',
      description: 'One free movie ticket at TGV Cinemas.',
      code: 'TRNSMV2023',
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      isUsed: true,
      provider: 'TGV Cinemas',
      terms: [
        'Valid for one standard 2D movie ticket',
        'Not valid for premium screens or special events',
        'Booking must be made at least 24 hours in advance',
        'Subject to seat availability',
      ],
      imagePath: 'lib/images/movie_voucher.png',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    final secondaryColor = themeService.secondaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Vouchers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Used'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active vouchers tab
          _buildVoucherList(_activeVouchers),
          
          // Used vouchers tab
          _buildVoucherList(_usedVouchers),
        ],
      ),
    );
  }
  
  Widget _buildVoucherList(List<Voucher> vouchers) {
    final themeService = Provider.of<ThemeService>(context);
    final primaryColor = themeService.primaryColor;
    
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No vouchers yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Redeem your points to get vouchers',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to rewards page
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rewards');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'View Rewards',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        final isExpired = voucher.expiryDate.isBefore(DateTime.now());
        
        return GestureDetector(
          onTap: () => _showVoucherDetails(voucher),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Voucher header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: voucher.isUsed || isExpired
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [primaryColor, themeService.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForVoucher(voucher.title),
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.provider,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (voucher.isUsed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'USED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'EXPIRED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                
                // Voucher body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPIRES',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(voucher.expiryDate),
                                style: TextStyle(
                                  color: isExpired ? Colors.red : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'CODE',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                voucher.code,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap for details',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (!voucher.isUsed && !isExpired)
                            OutlinedButton(
                              onPressed: () => _showRedeemDialog(voucher),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(color: primaryColor),
                              ),
                              child: const Text('Use Now'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showVoucherDetails(Voucher voucher) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForVoucher(voucher.title),
                            color: primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.provider,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    voucher.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Voucher code
                  const Text(
                    'Voucher Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          voucher.code,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Copy to clipboard would be implemented here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Voucher code copied to clipboard'),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Expiry date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valid Until',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMMM yyyy').format(voucher.expiryDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: voucher.expiryDate.isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (voucher.isUsed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: const Text(
                            'USED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (voucher.expiryDate.isBefore(DateTime.now()))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: const Text(
                            'EXPIRED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and conditions
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...voucher.terms.map((term) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            term,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 32),
                  
                  // Redeem button
                  if (!voucher.isUsed && !voucher.expiryDate.isBefore(DateTime.now()))
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRedeemDialog(voucher);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Use Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showRedeemDialog(Voucher voucher) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final primaryColor = themeService.primaryColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Voucher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to redeem this voucher now? Once redeemed, you will need to use it at the merchant.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    voucher.code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you would mark the voucher as used in your database
              // For demo purposes, we'll just close the dialog
              Navigator.pop(context);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Voucher redeemed successfully!'),
                  backgroundColor: primaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForVoucher(String title) {
    if (title.toLowerCase().contains('coffee')) {
      return Icons.coffee;
    } else if (title.toLowerCase().contains('grab') || title.toLowerCase().contains('ride')) {
      return Icons.local_taxi;
    } else if (title.toLowerCase().contains('movie') || title.toLowerCase().contains('cinema')) {
      return Icons.movie;
    } else if (title.toLowerCase().contains('food') || title.toLowerCase().contains('restaurant')) {
      return Icons.restaurant;
    } else if (title.toLowerCase().contains('discount') || title.toLowerCase().contains('sale')) {
      return Icons.discount;
    } else {
      return Icons.card_giftcard;
    }
  }
} 