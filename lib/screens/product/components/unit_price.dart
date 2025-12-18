import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';

class UnitPrice extends StatelessWidget {
  const UnitPrice({
    super.key,
    required this.price,
    this.priceAfterDiscount,
  });

  final double price;
  final double? priceAfterDiscount;

  String formatVND(double value) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = priceAfterDiscount != null && priceAfterDiscount! < price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unit price",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 1),
        Text(
          formatVND(hasDiscount ? priceAfterDiscount! : price),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (hasDiscount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              formatVND(price),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
          ),
      ],
    );
  }
}
