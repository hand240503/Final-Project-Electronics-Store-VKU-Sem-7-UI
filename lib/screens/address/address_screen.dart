import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shop/models/user_model.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/users/address_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Future<List<UserAddress>> _addressesFuture;

  int? _selectedIndex; // index của address mặc định

  @override
  void initState() {
    super.initState();
    _addressesFuture = _loadAddressesFuture();
  }

  Future<List<UserAddress>> _loadAddressesFuture() async {
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr == null) {
      throw Exception("User not logged in");
    }
    final userId = int.parse(userIdStr);
    final addresses = await AddressService.getAddressesByUserId(userId: userId);

    // tìm index address mặc định
    final defaultIndex = addresses.indexWhere((a) => a.isDefault);
    if (defaultIndex != -1) {
      _selectedIndex = defaultIndex;
    }

    return addresses;
  }

  void _onSelectAddress(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddAddress() {
    // Navigate tới màn hình thêm địa chỉ
    Navigator.pushNamed(context, addAddressScreenRoute).then((_) {
      // reload list sau khi add
      setState(() {
        _addressesFuture = _loadAddressesFuture();
      });
    });
  }

  void _onEditAddress(UserAddress address) {
    // Navigate tới màn hình sửa địa chỉ
    Navigator.pushNamed(context, editAddressScreenRoute, arguments: address).then((_) {
      setState(() {
        _addressesFuture = _loadAddressesFuture();
      });
    });
  }

  Widget _buildAddressCard(UserAddress address, int index) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue.shade400 : Colors.grey.shade200,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectAddress(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with radio and name
                Row(
                  children: [
                    // Custom radio button
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isSelected ? Colors.blue : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Name and default badge
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.fullName,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade300,
                                    Colors.orange.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Mặc định",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Edit button
                    InkWell(
                      onTap: () => _onEditAddress(address),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Sửa",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),

                const SizedBox(height: 12),

                // Phone number with icon
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.phone,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Address with icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.addressLine,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${address.ward}, ${address.district}, ${address.city}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Address"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<UserAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final addresses = snapshot.data ?? [];

          return Column(
            children: [
              // Add new address button
              GestureDetector(
                onTap: _onAddAddress,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Add new address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Address list
              Expanded(
                child: addresses.isEmpty
                    ? const Center(child: Text("Chưa có địa chỉ nào"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        itemBuilder: (_, index) => _buildAddressCard(addresses[index], index),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
