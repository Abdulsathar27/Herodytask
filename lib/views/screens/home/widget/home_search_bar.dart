import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/views/widgets/app_text_field.dart';



class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AppSearchField(
        controller: _searchCtrl,
        hint: 'Search tasks...',
        onChanged: (q) => context.read<TaskProvider>().setSearchQuery(q),
        onClear: () {
          _searchCtrl.clear();
          context.read<TaskProvider>().setSearchQuery('');
        },
      ),
    );
  }
}