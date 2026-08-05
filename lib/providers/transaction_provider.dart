import 'package:flutter/foundation.dart';

import '../models/incoming_item.dart';
import '../models/outgoing_item.dart';
import '../models/transaction_filter.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({TransactionService? transactionService})
      : _transactionService = transactionService ?? TransactionService();

  final TransactionService _transactionService;

  List<IncomingItem> _incoming = [];
  List<OutgoingItem> _outgoing = [];
  bool _loading = false;
  String? _error;

  TransactionFilter _incomingFilter = const TransactionFilter();
  TransactionFilter _outgoingFilter = const TransactionFilter();

  List<IncomingItem> get incoming => _incoming;
  List<OutgoingItem> get outgoing => _outgoing;
  bool get loading => _loading;
  String? get error => _error;
  TransactionFilter get incomingFilter => _incomingFilter;
  TransactionFilter get outgoingFilter => _outgoingFilter;

  Future<void> loadIncoming({bool refresh = true}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final (items, _) = await _transactionService.incoming(
        search: _incomingFilter.search,
        from: _incomingFilter.from,
        to: _incomingFilter.to,
        itemId: _incomingFilter.itemId,
      );
      _incoming = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadOutgoing({bool refresh = true}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final (items, _) = await _transactionService.outgoing(
        search: _outgoingFilter.search,
        from: _outgoingFilter.from,
        to: _outgoingFilter.to,
        itemId: _outgoingFilter.itemId,
      );
      _outgoing = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setIncomingFilter(TransactionFilter filter) async {
    _incomingFilter = filter;
    await loadIncoming();
  }

  Future<void> setOutgoingFilter(TransactionFilter filter) async {
    _outgoingFilter = filter;
    await loadOutgoing();
  }

  Future<void> storeIncoming({
    required int itemId,
    required String date,
    required int quantity,
    String? description,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _transactionService.storeIncoming(
        itemId: itemId,
        date: date,
        quantity: quantity,
        description: description,
      );
      await loadIncoming();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> storeOutgoing({
    required int itemId,
    required String date,
    required int quantity,
    String? destination,
    String? description,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _transactionService.storeOutgoing(
        itemId: itemId,
        date: date,
        quantity: quantity,
        destination: destination,
        description: description,
      );
      await loadOutgoing();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
