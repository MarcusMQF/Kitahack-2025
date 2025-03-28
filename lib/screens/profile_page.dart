import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import '../utils/app_theme.dart'; // Import theme utilities
import 'package:provider/provider.dart';
import '../services/rewards_service.dart';
import '../services/theme_service.dart'; // Add theme service import
import 'reward_page.dart';

// Class to store shared profile data
class ProfileData {
  static File? sharedProfileImage;
  static String username = 'Marcus';
  static String email = 'marcus.t@example.com';
  static bool notificationsEnabled = true;
  static String paymentAccountName = 'MARCUS'; // Separate payment account name
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  File? _profileImage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Use existing image if available
    _profileImage = ProfileData.sharedProfileImage;
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? returnedImage = await picker.pickImage(source: ImageSource.gallery);
      
      if (returnedImage == null) return;
      
      final File imageFile = File(returnedImage.path);
      
      // Verify the file exists before setting it
      if (await imageFile.exists()) {
        setState(() {
          _profileImage = imageFile;
          ProfileData.sharedProfileImage = imageFile;
        });
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Could not pick image: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme service instead of AppTheme
    final themeService = Provider.of<ThemeService>(context);
    final themeColors = AppThemeColors.fromTheme(themeService.currentThemeKey);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Blue curved header with profile information
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColors.primaryColor, themeColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: themeColors.primaryColor.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background elements
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Floating circles with different animation patterns
                        Positioned(
                          right: -50 + 20 * math.sin(_animationController.value * math.pi),
                          top: -50 + 20 * math.cos(_animationController.value * math.pi * 2),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30 + 15 * math.cos(_animationController.value * math.pi),
                          bottom: -60 + 15 * math.sin(_animationController.value * math.pi * 1.5),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Additional floating elements
                        Positioned(
                          right: 80,
                          top: 120 + 30 * math.sin(_animationController.value * math.pi * 0.8),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Animated transit path
                        Positioned(
                          bottom: 50,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: 60,
                            child: CustomPaint(
                              size: Size(MediaQuery.of(context).size.width, 60),
                              painter: PathDesignPainter(_animationController.value),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Main content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile section with image and name
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profile image
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: ClipOval(
                                      child: _profileImage != null
                                          ? Image.file(
                                              _profileImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: _pickImageFromGallery,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // User info
                            Text(
                              ProfileData.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Edit button styled to match home page design
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: GestureDetector(
                                onTap: () => _showEditUsernameDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account section
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccountInfoCard(),
                  
                  // Points card
                  _buildPointsCard(),
                  
                  // Menu items
                  _buildMenuOption(
                    icon: Icons.history,
                    title: 'Travel History',
                    onTap: () {},
                    showArrow: true,
                  ),
                  _buildMenuOption(
                    icon: Icons.payment,
                    title: 'Payment Method',
                    onTap: () {},
                    showArrow: true,
                  ),
                  _buildMenuOption(
                    icon: Icons.notifications_active,
                    title: 'Notification',
                    onTap: () {
                      setState(() {
                        ProfileData.notificationsEnabled = !ProfileData.notificationsEnabled;
                      });
                    },
                    showToggle: true,
                    isToggled: ProfileData.notificationsEnabled,
                  ),
                  
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  
                  // Appearance section
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOption(
                    icon: Icons.palette,
                    title: 'App Color Theme',
                    onTap: () {
                      _showThemeSelector();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppThemeColors.fromTheme(themeService.currentThemeKey).primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppThemeColors.fromTheme(themeService.currentThemeKey).name,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                  
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  
                  // Support section
                  const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOption(
                    icon: Icons.help,
                    title: 'Help Centre',
                    onTap: () {},
                    showArrow: true,
                  ),
                  _buildMenuOption(
                    icon: Icons.feedback,
                    title: 'Share Feedback',
                    onTap: () {},
                    showArrow: true,
                  ),
                  _buildMenuOption(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () {},
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Account info card with verified icon
  Widget _buildAccountInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/images/tng2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment account name (without the label)
                    Text(
                      ProfileData.paymentAccountName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ID: +60 17-7371286',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Points card
  Widget _buildPointsCard() {
    return Consumer<RewardsService>(
      builder: (context, rewardsService, child) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RewardPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reward',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatNumber(rewardsService.points)} pts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Modified menu option to support custom trailing widget
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool showArrow = false,
    bool showToggle = false,
    bool isToggled = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? AppThemeColors.fromTheme(Provider.of<ThemeService>(context).currentThemeKey).primaryColor,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: trailing ?? (showToggle
            ? Switch(
                value: isToggled,
                onChanged: (value) {
                  setState(() {
                    ProfileData.notificationsEnabled = value;
                  });
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withAlpha((0.3 * 255).round()),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.shade400;
                  }
                  return states.contains(WidgetState.selected) ? Colors.green : Colors.grey.shade400;
                }),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              )
            : showArrow
                ? const Icon(Icons.chevron_right, color: Colors.grey)
                : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEditUsernameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: ProfileData.username);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Username',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your profile username',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Username input section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(15),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF2196F3),
                                  size: 22,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: controller,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter your username',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ),
                              if (controller.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This will change how your name appears across the app.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save button
                    ElevatedButton(
                      onPressed: () {
                        final newUsername = controller.text.trim();
                        if (newUsername.isNotEmpty) {
                          setState(() {
                            ProfileData.username = newUsername;
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show theme selector dialog
  void _showThemeSelector() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section with gradient
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppThemeColors.fromTheme(themeService.currentThemeKey).primaryColor,
                          AppThemeColors.fromTheme(themeService.currentThemeKey).secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Choose Theme',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select your preferred color theme',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Theme options section
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme options
                        for (var theme in AppThemeColors.allThemes)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // Use the helper function for consistent key conversion
                                themeService.setTheme(AppThemeColors.nameToKey(theme.name));
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name)
                                    ? theme.primaryColor.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name)
                                      ? theme.primaryColor
                                      : Colors.grey.shade200,
                                  width: themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name)
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Theme color preview
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme.primaryColor, theme.secondaryColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Theme name
                                  Text(
                                    theme.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name)
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name)
                                          ? theme.primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Selected indicator
                                  if (themeService.currentThemeKey == AppThemeColors.nameToKey(theme.name))
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Apply button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Theme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to format numbers with commas
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
  }
}

class PathDesignPainter extends CustomPainter {
  final double animationValue;
  
  PathDesignPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    
    // Draw a stylized transit path with animation
    final startY = size.height * (0.7 + 0.2 * math.sin(animationValue * math.pi));
    
    path.moveTo(0, startY);
    path.quadraticBezierTo(
      size.width * 0.1, 
      size.height * (0.2 + 0.1 * math.cos(animationValue * math.pi * 2)), 
      size.width * 0.3, 
      size.height * (0.4 + 0.1 * math.sin(animationValue * math.pi * 3))
    );
    path.quadraticBezierTo(
      size.width * 0.5, 
      size.height * (0.6 + 0.1 * math.cos(animationValue * math.pi * 2)), 
      size.width * 0.7, 
      size.height * (0.2 + 0.1 * math.sin(animationValue * math.pi * 2.5))
    );
    path.quadraticBezierTo(
      size.width * 0.85, 
      size.height * (0.0 + 0.1 * math.cos(animationValue * math.pi * 1.5)), 
      size.width, 
      size.height * (0.3 + 0.1 * math.sin(animationValue * math.pi))
    );
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw animated circles at key points to simulate moving stations
    final circlePaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.fill;
    
    // Moving station circles
    final station1X = size.width * 0.3;
    final station1Y = size.height * (0.4 + 0.1 * math.sin(animationValue * math.pi * 3));
    canvas.drawCircle(Offset(station1X, station1Y), 5, circlePaint);
    
    final station2X = size.width * 0.7;
    final station2Y = size.height * (0.2 + 0.1 * math.sin(animationValue * math.pi * 2.5));
    canvas.drawCircle(Offset(station2X, station2Y), 5, circlePaint);
    
    // Moving train/bus along the path
    final trainPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.fill;
    
    // Calculate position along the path based on animation value
    final trainPosition = (animationValue * 2) % 1.0; // Cycles twice per animation
    final trainX = size.width * trainPosition;
    
    // Approximate the Y position on the path (simplified calculation)
    final trainYBase = size.height * 0.4;
    final trainYOffset = size.height * 0.3 * math.sin(trainPosition * math.pi * 2);
    final trainY = trainYBase + trainYOffset;
    
    canvas.drawCircle(Offset(trainX, trainY), 8, trainPaint);
  }

  @override
  bool shouldRepaint(PathDesignPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
