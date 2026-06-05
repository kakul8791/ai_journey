import 'package:flutter/material.dart';
import '../models/trip_plan.dart';
import '../utils/season_helper.dart';
import 'result_screen.dart';

class PlanTripScreen extends StatefulWidget {
  final String? destHint;
  const PlanTripScreen({super.key, this.destHint});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  static const _red = Color(0xFFC0392B);

  final _fromCtrl = TextEditingController(text: 'Bareilly');
  final _toCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _personsCtrl = TextEditingController(text: '2');
  DateTime _travelDate = DateTime.now();
  String _travelMode = 'any';

  @override
  void initState() {
    super.initState();
    if (widget.destHint != null) {
      _toCtrl.text = widget.destHint!;
    }
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _budgetCtrl.dispose();
    _personsCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _travelDate = picked);
  }

  void _planTrip() {
    if (_toCtrl.text.isEmpty || _budgetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination aur budget daalo!')),
      );
      return;
    }

    final plan = TripPlan(
      from: _fromCtrl.text,
      to: _toCtrl.text,
      budgetPerPerson: int.tryParse(_budgetCtrl.text) ?? 3000,
      persons: int.tryParse(_personsCtrl.text) ?? 2,
      travelDate: _travelDate,
      travelMode: _travelMode,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(plan: plan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('Aapki Location (From)', _fromCtrl, ''),
                  const SizedBox(height: 14),
                  _buildInput('Kahan Jaana Hai? (To)', _toCtrl, 'e.g. Manali, Goa...'),
                  const SizedBox(height: 14),
                  _buildBudgetField(),
                  const SizedBox(height: 14),
                  _buildTravelMode(),
                  const SizedBox(height: 14),
                  _buildInput('Kitne Log?', _personsCtrl, '2',
                      type: TextInputType.number),
                  const SizedBox(height: 14),
                  _buildDatePicker(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _planTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Best Routes Dhundo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _red,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan Your Trip',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text('Budget daalo, destination choose karo',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.8)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _red)),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    final presets = [1500, 3000, 5000, 10000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget (₹ per person)',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.8)),
        const SizedBox(height: 5),
        TextField(
          controller: _budgetCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 3000',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _red)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: presets
              .map((p) => GestureDetector(
                    onTap: () =>
                        setState(() => _budgetCtrl.text = p.toString()),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _budgetCtrl.text == p.toString()
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('₹${p ~/ 1000}k',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _budgetCtrl.text == p.toString()
                                  ? Colors.white
                                  : const Color(0xFF2E7D32))),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTravelMode() {
    final modes = [
      {'id': 'bus', 'icon': '🚌', 'label': 'Bus'},
      {'id': 'train', 'icon': '🚆', 'label': 'Train'},
      {'id': 'car', 'icon': '🚗', 'label': 'Self Drive'},
      {'id': 'any', 'icon': '🔀', 'label': 'Any'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Travel Mode',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Row(
          children: modes
              .map((m) => Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _travelMode = m['id'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _travelMode == m['id']
                              ? const Color(0xFFFDE8E8)
                              : Colors.white,
                          border: Border.all(
                              color: _travelMode == m['id']
                                  ? _red
                                  : Colors.grey[300]!,
                              width: _travelMode == m['id'] ? 1.5 : 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(m['icon'] as String,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 3),
                            Text(m['label'] as String,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _travelMode == m['id']
                                        ? _red
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kab Jaana Hai?',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.8)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  '${_travelDate.day}/${_travelDate.month}/${_travelDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}