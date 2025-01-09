import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';

class PopupMenuItemModel {
  String title;
  IconData icon;
  int menuNumber;

  PopupMenuItemModel(this.title, this.icon, this.menuNumber);
}

typedef CustomPopupMenuCallback = void Function(int menuItemNumber);

class CustomPopupMenuButton extends StatefulWidget {
  final CustomPopupMenuCallback onSelected;

  const CustomPopupMenuButton({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<CustomPopupMenuButton> createState() => _CustomPopupMenuButtonState();
}

class _CustomPopupMenuButtonState extends State<CustomPopupMenuButton> {
  late List<PopupMenuItemModel> _popupMenuItems;
  final CustomPopupMenuController _customPopupMenuController =
      CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
    _popupMenuItems = [
      PopupMenuItemModel('Full-screen', Icons.fullscreen, 1),
      PopupMenuItemModel('Settings', Icons.settings, 2),
      PopupMenuItemModel('About', Icons.info_outline, 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          color: const Color(0xFF4C4C4C),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _popupMenuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.onSelected(item.menuNumber);
                        _customPopupMenuController.hideMenu();
                      },
                      child: Container(
                        height: 60.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 25,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10.0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10.0,
      controller: _customPopupMenuController,
      child: Container(
        // color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: const Icon(Icons.more_vert_sharp),
      ),
    );
  }
}
