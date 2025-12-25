import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/routes/route_constants.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String name = 'User';
  String email = '';
  String avatar = "https://i.imgur.com/IXnwbLk.png";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final storedName = await storage.read(key: 'first_name');
    final storedEmail = await storage.read(key: 'email');

    setState(() {
      name = storedName ?? 'User';
      email = storedEmail ?? '';
    });
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      loginScreenRoute,
      (route) => false,
    );
  }

  // Hàm build avatar với chữ cái đầu
  Widget _buildAvatar({required String name, double size = 60}) {
    // Lấy chữ cái đầu tiên của tên
    String initials = '';
    if (name.isNotEmpty) {
      final nameParts = name.trim().split(' ');
      if (nameParts.length >= 2) {
        // Nếu có họ và tên, lấy chữ cái đầu của cả hai
        initials = nameParts[0][0].toUpperCase() + nameParts[nameParts.length - 1][0].toUpperCase();
      } else {
        // Nếu chỉ có một từ, lấy chữ cái đầu
        initials = nameParts[0][0].toUpperCase();
      }
    } else {
      initials = 'U'; // Default
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurple, // Nền màu tím
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: size * 0.4, // Font size tương ứng với size của avatar
            fontWeight: FontWeight.w600,
            color: Colors.orange, // Chữ màu cam
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          /// ===== PROFILE CARD với Custom Avatar =====
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                // Avatar với chữ cái đầu
                _buildAvatar(name: name, size: 60),

                const SizedBox(width: defaultPadding),

                // Thông tin user
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon edit
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, editProfileScreenRoute);
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          /// ===== ACCOUNT =====
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
            child: Text(
              "Account",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, listOrderScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Returned Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, processedReturnOrdersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, userAddressScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),

          /// ===== LOGOUT =====
          ListTile(
            onTap: _logout,
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              "Log Out",
              style: GoogleFonts.roboto(
                color: errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
