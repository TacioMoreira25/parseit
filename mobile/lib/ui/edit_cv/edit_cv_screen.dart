import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/cv_block.dart';
import 'view_models/edit_cv_viewmodel.dart';

class EditCvScreen extends StatefulWidget {
  const EditCvScreen({Key? key}) : super(key: key);

  @override
  State<EditCvScreen> createState() => _EditCvScreenState();
}

class _EditCvScreenState extends State<EditCvScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditCvViewModel>(context, listen: false).fetchCvBlocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () =>
                context.read<EditCvViewModel>().generateAndOpenPdf(),
          ),
        ],
      ),
      body: Consumer<EditCvViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.blocks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }

          return ReorderableListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: List.generate(viewModel.blocks.length, (index) {
              final block = viewModel.blocks[index];
              return buildBlock(context, block, Key(block.id));
            }),
            onReorder: viewModel.onReorder,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBlockMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildBlock(BuildContext context, CVBlock block, Key key) {
    final viewModel = context.read<EditCvViewModel>();

    Widget content;
    switch (block.type) {
      case 'HEADER':
        content = _buildHeaderBlock(viewModel, block);
        break;
      case 'TEXT':
        content = _buildTextBlock(viewModel, block);
        break;
      case 'EXPERIENCE':
        content = _buildExperienceBlock(viewModel, block);
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: content),
          ReorderableDragStartListener(
            index: viewModel.blocks.indexOf(block),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.drag_handle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBlock(EditCvViewModel viewModel, CVBlock block) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: block.content['name'],
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                final newContent = Map<String, dynamic>.from(block.content);
                newContent['name'] = value;
                viewModel.updateBlockContent(block.id, newContent);
              },
            ),
            TextFormField(
              initialValue: block.content['email'],
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                final newContent = Map<String, dynamic>.from(block.content);
                newContent['email'] = value;
                viewModel.updateBlockContent(block.id, newContent);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBlock(EditCvViewModel viewModel, CVBlock block) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          initialValue: block.content['text'],
          decoration: const InputDecoration(
            labelText: 'Text',
            border: InputBorder.none,
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          onChanged: (value) {
            final newContent = Map<String, dynamic>.from(block.content);
            newContent['text'] = value;
            viewModel.updateBlockContent(block.id, newContent);
          },
        ),
      ),
    );
  }

  Widget _buildExperienceBlock(EditCvViewModel viewModel, CVBlock block) {
    return Card(
      child: ListTile(
        title: Text(block.content['role'] ?? 'Role'),
        subtitle: Text(
          '${block.content['company'] ?? 'Company'} (${block.content['period'] ?? 'Period'})',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            print('Editing experience...');
          },
        ),
      ),
    );
  }

  void _showAddBlockMenu(BuildContext context) {
    final viewModel = context.read<EditCvViewModel>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Header'),
              onTap: () {
                viewModel.addBlock(CVBlock.createHeader());
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Text'),
              onTap: () {
                viewModel.addBlock(CVBlock.createText());
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Experience'),
              onTap: () {
                viewModel.addBlock(CVBlock.createExperience());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
