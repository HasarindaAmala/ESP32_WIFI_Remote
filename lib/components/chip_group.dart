import 'package:flutter/material.dart';

class SingleSelectionChipGroup extends StatefulWidget {
  final int initialSelectedChip;
  final String prefix;
  final Function(int) onChipSelected;

  const SingleSelectionChipGroup({
    Key? key,
    this.initialSelectedChip = 1,
    required this.onChipSelected,
    required this.prefix,
  }) : super(key: key);

  @override
  State<SingleSelectionChipGroup> createState() =>
      _SingleSelectionChipGroupState();
}

class _SingleSelectionChipGroupState extends State<SingleSelectionChipGroup> {
  late int _selectedChip;

  static const int _backgroundColor = 0xFF36393B;
  static const int _selectedColor = 0xFF0EBBFF;

  @override
  void initState() {
    super.initState();
    _selectedChip = widget.initialSelectedChip;
  }

  void _handleChipSelection(int chipIndex) {
    setState(() {
      _selectedChip = chipIndex;
      widget.onChipSelected(chipIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}1",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _selectedChip == 1,
          onSelected: (selected) {
            _handleChipSelection(1);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}2",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _selectedChip == 2,
          onSelected: (selected) {
            _handleChipSelection(2);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}3",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _selectedChip == 3,
          onSelected: (selected) {
            _handleChipSelection(3);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
      ],
    );
  }
}

class MultiSelectionChipGroup extends StatefulWidget {
  final bool chip1InitState, chip2InitState, chip3InitState;
  final String prefix;
  final Function(int) onChipSelected;

  const MultiSelectionChipGroup({
    Key? key,
    this.chip1InitState = false,
    this.chip2InitState = false,
    this.chip3InitState = false,
    required this.onChipSelected,
    required this.prefix,
  }) : super(key: key);

  @override
  State<MultiSelectionChipGroup> createState() =>
      _MultiSelectionChipGroupState();
}

class _MultiSelectionChipGroupState extends State<MultiSelectionChipGroup> {
  late bool _chip1Selected, _chip2Selected, _chip3Selected;

  static const int _backgroundColor = 0xFF36393B;
  static const int _selectedColor = 0xFF0EBBFF;

  @override
  void initState() {
    super.initState();

    _chip1Selected = widget.chip1InitState;
    _chip2Selected = widget.chip2InitState;
    _chip3Selected = widget.chip3InitState;
  }

  void _handleChipSelection(int chipIndex) {
    int chipVal = 0;

    if (chipIndex == 1) _chip1Selected = !_chip1Selected;
    if (chipIndex == 2) _chip2Selected = !_chip2Selected;
    if (chipIndex == 3) _chip3Selected = !_chip3Selected;

    chipVal += _chip1Selected ? 1 : 0;
    chipVal += _chip2Selected ? 2 : 0;
    chipVal += _chip3Selected ? 4 : 0;

    setState(() {
      widget.onChipSelected(chipVal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}1",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _chip1Selected,
          onSelected: (selected) {
            _handleChipSelection(1);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}2",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _chip2Selected,
          onSelected: (selected) {
            _handleChipSelection(2);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            "${widget.prefix}3",
            style: const TextStyle(color: Colors.white,fontSize: 14,),
          ),
          selected: _chip3Selected,
          onSelected: (selected) {
            _handleChipSelection(3);
          },
          backgroundColor: const Color(_backgroundColor),
          selectedColor: const Color(_selectedColor),
        ),
      ],
    );
  }
}
