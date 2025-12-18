import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          /// ===== PROFILE CARD =====
          ProfileCard(
            name: name,
            email: email,
            imageSrc: avatar,
            press: () {
              // Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),

          /// ===== ACCOUNT =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),

          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: "Returns",
            svgSrc: "assets/icons/Return.svg",
            press: () {},
          ),

          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, userAddressScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Payment",
            svgSrc: "assets/icons/card.svg",
            press: () {},
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
            title: const Text(
              "Log Out",
              style: TextStyle(
                color: errorColor,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
