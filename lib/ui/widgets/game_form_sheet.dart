import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/catalog/catalog_bloc.dart';
import '../../bloc/catalog/catalog_event.dart';
import '../../domain/entities/game.dart';

Future<void> showGameFormSheet(BuildContext context, {Game? initial}) {
  final bloc = context.read<CatalogBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider<CatalogBloc>.value(
      value: bloc,
      child: GameFormSheet(initial: initial),
    ),
  );
}

class GameFormSheet extends StatefulWidget {
  const GameFormSheet({super.key, this.initial});

  final Game? initial;

  @override
  State<GameFormSheet> createState() => _GameFormSheetState();
}

class _GameFormSheetState extends State<GameFormSheet> {
  static const _palette = [
    '7B3F3F',
    '3F7B6B',
    '3A5A8B',
    '8B7A3A',
    '5B8B3A',
    '6A4C93',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late GameGenre _genre;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _subtitleController = TextEditingController(text: initial?.subtitle ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _genre = initial?.genre ?? GameGenre.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _pickColor(String title) {
    final sum = title.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palette[sum % _palette.length];
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Введите название');
      return;
    }
    final subtitle = _subtitleController.text.trim();
    final description = _descriptionController.text.trim();
    final letter = title.substring(0, 1).toUpperCase();
    final initial = widget.initial;
    final bloc = context.read<CatalogBloc>();

    if (initial == null) {
      bloc.add(
        CatalogGameAdded(
          Game(
            id: '',
            title: title,
            subtitle: subtitle.isEmpty ? 'Добавлено вручную' : subtitle,
            genre: _genre,
            description: description,
            color: _pickColor(title),
            coverLetter: letter,
          ),
        ),
      );
    } else {
      bloc.add(
        CatalogGameUpdated(
          Game(
            id: initial.id,
            title: title,
            subtitle: subtitle,
            genre: _genre,
            description: description,
            color: initial.color,
            coverLetter: letter,
            createdAt: initial.createdAt,
          ),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Редактирование игры' : 'Новая игра',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Название',
                border: const OutlineInputBorder(),
                errorText: _titleError,
              ),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Подпись (студия, год)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final genre in GameGenre.values)
                  ChoiceChip(
                    label: Text(genre.label),
                    selected: _genre == genre,
                    onSelected: (_) => setState(() => _genre = genre),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isEdit ? 'Сохранить' : 'Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
