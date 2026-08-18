import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  final Set<String> updatingOrders = {};

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
    });

    final data = await OrderService.getStoreOrders();

    if (!mounted) return;

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  Future<void> advanceStatus(OrderModel order) async {
    final nextStatus = order.status.nextStatus;
    if (nextStatus == null) return;

    setState(() {
      updatingOrders.add(order.id);
    });

    final updated = await OrderService.updateStatus(
      orderId: order.id,
      newStatus: nextStatus,
    );

    if (!mounted) return;

    setState(() {
      updatingOrders.remove(order.id);
      if (updated != null) {
        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = updated;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order status')),
        );
      }
    });
  }

  Future<void> cancelOrder(OrderModel order) async {
    setState(() {
      updatingOrders.add(order.id);
    });

    final updated = await OrderService.updateStatus(
      orderId: order.id,
      newStatus: OrderStatus.cancelled,
    );

    if (!mounted) return;

    setState(() {
      updatingOrders.remove(order.id);
      if (updated != null) {
        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = updated;
        }
      }
    });
  }

  Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? const Center(child: Text('No orders yet'))
              : RefreshIndicator(
                onRefresh: loadOrders,
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isUpdating = updatingOrders.contains(order.id);
                    final canAdvance = order.status.nextStatus != null;
                    final canCancel =
                        order.status != OrderStatus.delivered &&
                        order.status != OrderStatus.cancelled;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.customerName ?? 'Unknown Customer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(
                                      order.status,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status.displayLabel,
                                    style: TextStyle(
                                      color: statusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (order.customerPhone != null)
                              Text(
                                '📞 ${order.customerPhone}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            const SizedBox(height: 8),
                            ...order.items.map(
                              (item) => Text(
                                '${item.quantity}x ${item.name}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (canAdvance)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          isUpdating
                                              ? null
                                              : () => advanceStatus(order),
                                      child:
                                          isUpdating
                                              ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Text(
                                                'Mark as ${order.status.nextStatus!.displayLabel}',
                                              ),
                                    ),
                                  ),
                                if (canAdvance && canCancel)
                                  const SizedBox(width: 8),
                                if (canCancel)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          isUpdating
                                              ? null
                                              : () => cancelOrder(order),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
