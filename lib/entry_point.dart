import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/constants.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/notification/notification_screen.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/discover/discover_screen.dart';
import 'package:shop/screens/home/home_screen.dart';
import 'package:shop/screens/profile/profile_screen.dart';
import 'package:shop/services/notifications/notification_service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    NotificationScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;
  int _unreadCount = 0;
  int _loadCount = 0; // Đếm số lần đã load

  @override
  void initState() {
    super.initState();
    _loadUnreadCountThreeTimes();
  }

  // Load unread count 3 lần: ngay lập tức, sau 2s, sau 5s
  void _loadUnreadCountThreeTimes() {
    // Lần 1: Load ngay
    _loadUnreadCount();

    // Lần 2: Sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _loadCount < 3) {
        _loadUnreadCount();
      }
    });

    // Lần 3: Sau 5 giây
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _loadCount < 3) {
        _loadUnreadCount();
      }
    });
  }

  Future<void> _loadUnreadCount() async {
    if (_loadCount >= 3) return; // Giới hạn chỉ load 3 lần

    try {
      final count = await NotificationService.fetchUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
          _loadCount++;
        });
      }
    } catch (e) {
      print('Error loading unread count: $e');
      if (mounted) {
        setState(() {
          _loadCount++;
        });
      }
    }
  }

  // Reload unread count khi quay lại từ notification screen
  Future<void> _reloadUnreadCount() async {
    try {
      final count = await NotificationService.fetchUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error reloading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context)
                    .iconTheme
                    .color!
                    .withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Text(
          'Shoplon',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, notificationsScreenRoute);
                  // Reload unread count khi quay lại từ notification screen
                  _reloadUnreadCount();
                },
                icon: SvgPicture.asset(
                  "assets/icons/Notification.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!, BlendMode.srcIn),
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(_unreadCount > 9 ? 4 : 5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: _unreadCount > 9 ? 9 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
              // Reload unread count khi chuyển sang tab Notification
              if (index == 2) {
                _reloadUnreadCount();
              }
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF101015),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.transparent,
          selectedLabelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Shop.svg"),
              activeIcon: svgIcon("assets/icons/Shop.svg", color: primaryColor),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Search.svg"),
              activeIcon: svgIcon("assets/icons/Search.svg", color: primaryColor),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: _unreadCount > 0
                  ? Badge(
                      label: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      child: svgIcon("assets/icons/Bookmark.svg"),
                    )
                  : svgIcon("assets/icons/Bookmark.svg"),
              activeIcon: _unreadCount > 0
                  ? Badge(
                      label: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      child: svgIcon("assets/icons/Bookmark.svg", color: primaryColor),
                    )
                  : svgIcon("assets/icons/Bookmark.svg", color: primaryColor),
              label: "Bookmark",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Bag.svg"),
              activeIcon: svgIcon("assets/icons/Bag.svg", color: primaryColor),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Profile.svg"),
              activeIcon: svgIcon("assets/icons/Profile.svg", color: primaryColor),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
