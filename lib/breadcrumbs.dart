import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Breadcrumbs')),
          body: const Center(
            child: Breadcrumb(
              items: [
                BreadcrumbItem('Home', null),
                BreadcrumbItem('Products', null),
                BreadcrumbItem('Current Page', null),
              ],
            ),
          ),
        ),
      ),
    );

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  const BreadcrumbItem(this.label, this.onTap);
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: items[i].onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: Text(
                  items[i].label,
                  style: TextStyle(
                    color: i == items.length - 1 ? Colors.grey[800] : Colors.blue,
                    fontWeight: i == items.length - 1 ? FontWeight.bold : null,
                  ),
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text('>', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ],
      ),
    );
  }
}
