import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/cv_repository.dart';

class CvListScreen extends StatefulWidget {
  const CvListScreen({super.key});

  @override
  State<CvListScreen> createState() => _CvListScreenState();
}

class _CvListScreenState extends State<CvListScreen> {
  // Estado local simples. Em app maior, usaria um ViewModel dedicado.
  List<Map<String, dynamic>> _cvs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCVs();
  }

  Future<void> _loadCVs() async {
    try {
      final repo = context.read<CvRepository>();
      final cvs = await repo.fetchCVs();
      if (mounted) {
        setState(() {
          _cvs = cvs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar currículos: $e')),
        );
      }
    }
  }

  Future<void> _createNewCV() async {
    // Diálogo simples para pedir o título
    final titleController = TextEditingController();
    final String? title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Currículo'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Ex: Desenvolvedor Go'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      try {
        final repo = context.read<CvRepository>();
        final newId = await repo.createCV(title);
        if (mounted) {
          // Navega para a edição usando GoRouter
          context.push('/edit-cv/$newId').then((_) => _loadCVs());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao criar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Currículos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cvs.isEmpty
          ? const Center(child: Text("Nenhum currículo criado."))
          : ListView.builder(
              itemCount: _cvs.length,
              itemBuilder: (context, index) {
                final cv = _cvs[index];
                return ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Color(0xFF00695C),
                  ),
                  title: Text(cv['title'] ?? 'Sem título'),
                  subtitle: Text('Criado em: ${cv['created_at'] ?? '-'}'),
                  onTap: () {
                    context
                        .push('/edit-cv/${cv['id']}')
                        .then((_) => _loadCVs());
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A),
        onPressed: _createNewCV,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
