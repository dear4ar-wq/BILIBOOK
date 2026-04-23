import 'package:flutter/material.dart';
import '../data/admin_repository.dart';
import '../../../models/models.dart';
import '../../../core/theme/app_theme.dart';

class DrawManagementView extends StatefulWidget {
  const DrawManagementView({super.key});

  @override
  State<DrawManagementView> createState() => _DrawManagementViewState();
}

class _DrawManagementViewState extends State<DrawManagementView> {
  final _repository = AdminRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Draw>>(
        stream: _repository.streamAllDraws(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final draws = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: draws.length,
            itemBuilder: (context, index) {
              final draw = draws[index];
              return _buildDrawCard(draw);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDrawModal(context),
        backgroundColor: kNavyPrimary,
        label: const Text('NEW DRAW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawCard(Draw draw) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kGoldAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: kGoldAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draw.name, style: const TextStyle(fontWeight: FontWeight.w900, color: kNavyPrimary, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Date: ${draw.date.day}/${draw.date.month}/${draw.date.year}', 
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: kNavyPrimary),
            onPressed: () => _showDrawModal(context, draw: draw),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _confirmDelete(draw),
          ),
        ],
      ),
    );
  }

  void _showDrawModal(BuildContext context, {Draw? draw}) {
    final nameController = TextEditingController(text: draw?.name);
    final priceController = TextEditingController(text: draw?.ticketPrice.toString() ?? '100');
    final resultController = TextEditingController(text: draw?.result ?? '');
    DateTime selectedDate = draw?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(draw == null ? 'CREATE NEW DRAW' : 'EDIT DRAW', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kNavyPrimary)),
            const SizedBox(height: 24),
            _buildTextField(nameController, 'Draw Name (e.g. Dear Morning)', Icons.title_rounded),
            const SizedBox(height: 16),
            _buildTextField(priceController, 'Ticket Price (INR)', Icons.payments_rounded, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(resultController, 'Result (e.g. 50A-12345)', Icons.stars_rounded),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.grey),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (draw == null) {
                        await _repository.createDraw(
                          name: nameController.text,
                          date: selectedDate,
                          price: int.tryParse(priceController.text) ?? 100,
                        );
                      } else {
                        await _repository.updateDraw(
                          id: draw.id,
                          name: nameController.text,
                          price: int.tryParse(priceController.text),
                          result: resultController.text,
                        );
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kNavyPrimary, foregroundColor: Colors.white),
                    child: const Text('SAVE DRAW'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  void _confirmDelete(Draw draw) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draw?'),
        content: Text('Are you sure you want to delete ${draw.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await _repository.deleteDraw(draw.id);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text('DELETE', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
