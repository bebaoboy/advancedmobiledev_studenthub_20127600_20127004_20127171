import 'package:boilerplate/core/widgets/lazy_loading_card.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key, this.projectList, this.onFavoriteTap});
  final List<Project>? projectList;
  final Function? onFavoriteTap;

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildProjectContent();
  }

  double yOffset = 0;
  String keyword = "";

  Widget _buildProjectContent() {
    if (yOffset == 0) {
      yOffset = MediaQuery.of(context).size.height;
    }
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Text(Lang.get('This is project page"),
        Align(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      keyword = value;
                    },
                    onSubmitted: (value) {},
                    decoration: InputDecoration(
                      hintText: Lang.get('search'),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,
                            size: 35, color: Colors.black.withOpacity(.7)),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(
          height: 100,
        ),
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: LazyLoadingAnimationProjectList(
            scrollController: ScrollController(),
            skipItemLoading: true,
            itemHeight: MediaQuery.of(context).size.height * 0.3,
            list: widget.projectList ?? [],
            firstCallback: (i) {
              if (widget.projectList != null) {
                if (widget.onFavoriteTap != null) {
                  widget.onFavoriteTap!(widget.projectList![i].objectId);
                }
                setState(() {
                  widget.projectList![i].isFavorite =
                      !widget.projectList![i].isFavorite;
                });
              }
            },
          ),
        ),
        // AnimatedContainer(
        //     curve: Easing.legacyAccelerate,
        //     // color: Colors.amber,
        //     alignment: Alignment.bottomCenter,
        //     duration: Duration(milliseconds: 300),
        //     transform: Matrix4.translationValues(0, yOffset, -1.0),
        //     child: SearchBottomSheet(
        //       searchList: widget.projectList
        //           .where((e) =>
        //               e.title.toLowerCase().contains(keyword.toLowerCase()))
        //           .toList(),
        //       onSheetDismissed: () {
        //         setState(() {
        //           NavbarNotifier2.hideBottomNavBar = false;
        //           yOffset = MediaQuery.of(context).size.height;
        //         });
        //         final FocusScopeNode currentScope = FocusScope.of(context);
        //         if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //           FocusManager.instance.primaryFocus?.unfocus();
        //         }
        //         return true;
        //       },
        //       onFilterTap: () {},
        //     )),
        // AnimatedContainer(
        //     curve: Easing.legacyAccelerate,
        //     // color: Colors.amber,
        //     alignment: Alignment.bottomCenter,
        //     duration: Duration(milliseconds: 300),
        //     transform: Matrix4.translationValues(0, yOffset, -1.0),
        //     child: SearchBottomSheet(
        //       searchList: widget.projectList
        //           .where((e) =>
        //               e.title.toLowerCase().contains(keyword.toLowerCase()))
        //           .toList(),
        //       onSheetDismissed: () {
        //         setState(() {
        //           NavbarNotifier2.hideBottomNavBar = false;
        //           yOffset = MediaQuery.of(context).size.height;
        //         });
        //         final FocusScopeNode currentScope = FocusScope.of(context);
        //         if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //           FocusManager.instance.primaryFocus?.unfocus();
        //         }
        //         return true;
        //       },
        //       onFilterTap: () {},
        //     )),
      ],
    );
  }
}
