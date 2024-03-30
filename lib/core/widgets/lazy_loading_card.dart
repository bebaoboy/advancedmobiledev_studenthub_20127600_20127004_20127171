// ignore_for_file: unused_element, empty_catches, implementation_imports, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/presentation/dashboard/components/project_item.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:enhanced_paginated_view/src/enhanced_deduplication.dart';
import 'package:enhanced_paginated_view/src/widgets/empty_widget.dart';
import 'package:enhanced_paginated_view/src/widgets/error_widget.dart';
import 'package:enhanced_paginated_view/src/widgets/loading_widget.dart';

/// this is the EnhancedPaginatedView widget
/// the T is the type of the items that will be loaded
class EnhancedPaginatedView<T> extends StatefulWidget {
  /// this is the load more widget constructor
  const EnhancedPaginatedView({
    required this.listOfData,
    required this.onLoadMore,
    required this.builder,
    required this.showError,
    required this.showLoading,
    required this.isMaxReached,
    this.shouldDeduplicate = true,
    this.reverse = false,
    this.itemsPerPage = 15,
    this.loadingWidget,
    this.errorWidget,
    this.physics,
    this.header,
    this.emptyView,
    super.key,
    required this.scrollController,
  });

  final scrollController;

  /// [deduplication] is a boolean that will be used
  /// to control wither the list will be deduplicated or not
  /// the default value is true
  /// if you want to disable the deduplication, then set this value to false
  final bool shouldDeduplicate;

  /// [physics] is a [ScrollPhysics] that will be used
  /// to control the scrolling behavior of the widget
  ///
  /// the default value is [null]
  final ScrollPhysics? physics;

  /// [isMaxReached] is a boolean that will be used
  /// to control the loading widget
  /// this boolean will be set to true when the list reaches the end
  final bool isMaxReached;

  /// [showLoading] is a [ValueNotifier] that will be used
  /// to control the loading widget
  /// this [ValueNotifier] will be set to true when the user
  /// reaches the end of the list and [onLoadMore] is called
  /// and will be set to false when the new items are loaded
  /// and the list is rebuilt
  /// this [ValueNotifier] is required
  final bool showLoading;

  /// the loading widget that will be shown when loading
  /// new items from the server or any other source
  /// this widget will be shown at the bottom of the list
  /// and will be removed when the new items are loaded
  /// and the list is rebuilt
  /// this widget will be shown only if [showLoading] is true
  /// and [isMaxReached] is false
  /// this widget is required
  /// this widget is not nullable
  final Widget? loadingWidget;

  /// [showError] is a boolean that will be used
  /// to control the error widget
  /// this boolean will be set to true when an error occurs
  final bool showError;

  /// [itemsPerPage] is an integer that will be used
  /// to control the number of items that will be loaded
  /// per page
  /// this help with requesting the right page number from the server
  /// in case of delete or update operations
  /// the default value is 15
  final int itemsPerPage;

  /// [errorWidget] is a widget that will be shown
  /// when an error occurs during data loading.
  /// This widget is optional and can be null.
  final Widget Function(int page)? errorWidget;

  /// [onLoadMore] is a function that will be called when
  /// the user reaches the end of the list
  /// this function will be called only if [isMaxReached] is false
  /// this function is required
  final void Function(int) onLoadMore;

  /// [listOfData] is a list of items that will be added to the list
  /// this list is required
  final List<T> listOfData;

  /// [header] is a list of widgets that will be shown
  /// at the top of the list
  /// this list is not required
  final Widget? header;

  /// [emptyView] is a widgets that will be shown
  /// when the list is empty
  /// this list is not required
  final Widget? emptyView;

  /// [reverse] is a boolean that will be used
  /// to reverse the list and its children
  final bool reverse;

  /// [builder] is a function that will be used to build the widget
  /// wither it is a [ListView] or a [GridView] or any other widget
  ///
  /// the `physics` parameter is the physics that will be used
  /// for the widget to control the scrolling behavior of the widget
  /// by default the physics will be [NeverScrollableScrollPhysics]
  /// to prevent the widget from scrolling
  /// this parameter is required
  ///
  /// the `items` parameter is the list of items that will be shown
  /// in the widget
  /// this parameter is required
  ///
  /// the `shrinkWrap` parameter is a boolean that will be used
  /// to control the shrinkWrap property of the widget
  /// by default the shrinkWrap will be true
  /// this parameter is required
  ///
  /// the `reverse` parameter is a boolean that will be used
  /// to reverse the list and its children
  /// it code be handy when you are building a chat app for example
  /// and you want to reverse the list to show the latest messages
  /// at the bottom of the list
  /// this parameter is required
  final Widget Function(
    ScrollPhysics physics,
    List<T> items,
    bool shrinkWrap,
    bool reverse,
  ) builder;

  @override
  State<EnhancedPaginatedView<T>> createState() =>
      _EnhancedPaginatedViewState<T>();
}

class _EnhancedPaginatedViewState<T> extends State<EnhancedPaginatedView<T>> {
  bool isLoading = false;
  late int loadThreshold;

  /// get the current page
  int get page => widget.listOfData.length ~/ widget.itemsPerPage + 1;

  void loadMore() {
    if (isLoading) return;

    isLoading = true;
    // log('loadMore called from EnhancedPaginatedView with page $page');
    widget.onLoadMore(page);
    // Use a delayed Future to reset the loading flag after a short delay
    Future.delayed(const Duration(milliseconds: 500), () => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadThreshold = widget.itemsPerPage - 3;
  }

  void checkAndLoadDataIfNeeded() {
    if (widget.isMaxReached || widget.showLoading || widget.showError) {
      return;
    }

    if (widget.listOfData.length <= loadThreshold) {
      // Load more data when the list gets shorter than the minimum threshold
      if (page < 2) {
        loadMore();
      }
    }
  }

  @override
  void didUpdateWidget(covariant EnhancedPaginatedView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkAndLoadDataIfNeeded();
  }

  @override
  void dispose() {
    // widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (widget.isMaxReached || widget.showLoading || widget.showError) {
          return false;
        }

        if (scrollInfo is ScrollUpdateNotification) {
          // Check if the last 5 items are visible
          final lastVisibleIndex =
              widget.scrollController.position.maxScrollExtent -
                  scrollInfo.metrics.pixels;
          if (lastVisibleIndex <= 100) {
            // The last 5 items are visible
            // You can now take appropriate action
            loadMore();
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        reverse: widget.reverse,
        controller: widget.scrollController,
        physics: widget.physics,
        child: Column(
          children: [
            // if reverse is true then show the loading widget
            // before the list
            if (widget.reverse)
              Column(
                children: [
                  if (widget.showLoading)
                    widget.loadingWidget ?? const LoadingWidget()
                  else if (widget.showError)
                    widget.errorWidget != null
                        ? widget.errorWidget!(page)
                        : const SomethingWentWrong(),
                ],
              ),

            // if reverse is true, then show the header before the list
            if (!widget.reverse)
              if (widget.header != null) widget.header ?? const SizedBox(),

            // if the list is not empty, then show the list
            // otherwise show the empty view
            if (widget.listOfData.isNotEmpty)
              widget.builder(
                const NeverScrollableScrollPhysics(),
                widget.shouldDeduplicate
                    ? widget.listOfData.removeDuplication()
                    : widget.listOfData,
                true,
                widget.reverse,
              )
            else
              widget.emptyView ?? const EmptyWidget(),

            // if reverse is true, then show the header after the list
            if (widget.reverse)
              if (widget.header != null) widget.header ?? const SizedBox(),
            if (!widget.reverse)
              Column(
                children: [
                  if (widget.showLoading)
                    widget.loadingWidget ?? const LoadingWidget()
                  else if (widget.showError)
                    widget.errorWidget != null
                        ? widget.errorWidget!(page)
                        : const SomethingWentWrong(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Colors.white,
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0),
  end: Alignment(1.0, 0),
  tileMode: TileMode.clamp,
);

class ExampleLoadingAnimationProjectList extends StatefulWidget {
  const ExampleLoadingAnimationProjectList({
    super.key,
    required this.height,
    required this.list,
    required this.firstCallback,
  });

  final double height;
  final List<Project> list;
  final Function firstCallback;

  @override
  State<ExampleLoadingAnimationProjectList> createState() =>
      _ExampleLoadingAnimationProjectListState();
}

class _ExampleLoadingAnimationProjectListState
    extends State<ExampleLoadingAnimationProjectList> {
  final bool _isLoading = true;
  late List<Timer?> timer;

  void _toggleLoading() async {
    for (int i = 0; i < widget.list.length; i++) {
      bool b = widget.list[i].isLoading;
      // print(i.toString() + ": " + b.toString());
      timer[i] = Timer(
          Duration(milliseconds: b ? Random().nextInt(30) + 8 : 0) * 100, () {
        try {
          setState(() {
            widget.list[i].isLoading = false;
          });
        } catch (e) {}
      });
    }
  }

  @override
  void dispose() {
    for (var element in timer) {
      if (element != null) element.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timer = List.filled(widget.list.length, null, growable: true);
    _toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer(
        linearGradient: _shimmerGradient,
        child: Scrollbar(
          child: widget.list.isEmpty
              ? Text(Lang.get("nothing_here"))
              : ListView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // _buildTopRowList(),
                    const SizedBox(height: 16),
                    _buildList(),
                  ],
                ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _toggleLoading,
      //   child: Icon(
      //     _isLoading ? Icons.hourglass_full : Icons.hourglass_bottom,
      //   ),
      // ),
    );
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildTopRowItem();
        },
      ),
    );
  }

  Widget _buildTopRowItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: const CircleListItem(),
    );
  }

  Widget _buildList() {
    return Container(
      width: 100,
      padding: const EdgeInsets.only(bottom: 60),
      height: widget.height - 80,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          return _buildListItem(widget.list[index], index);
        },
      ),
    );
  }

  // Widget _buildListItem() {
  //   return ShimmerLoading(
  //     isLoading: _isLoading,
  //     child: CardListItem(
  //       isLoading: _isLoading,
  //     ),
  //   );
  // }
  Widget _buildListItem(ShimmerLoadable w, int index) {
    return ShimmerLoading(
      isLoading: w.isLoading,
      child: ProjectItem(
        project: w as Project,
        onFavoriteTap: () => widget.firstCallback(index),
      ),
    );
  }
}

class LazyLoadingAnimationProjectList extends StatefulWidget {
  const LazyLoadingAnimationProjectList({
    super.key,
    required this.itemHeight,
    required this.list,
    required this.firstCallback,
    required this.scrollController,
  });

  final double itemHeight;
  final List<Project> list;
  final Function firstCallback;
  final ScrollController? scrollController;

  @override
  State<LazyLoadingAnimationProjectList> createState() =>
      _LazyLoadingAnimationProjectListState();
}

class _LazyLoadingAnimationProjectListState
    extends State<LazyLoadingAnimationProjectList> {
  final bool _isLoading = true;

  void _toggleLoading() async {
    for (int i = 0; i < widget.list.length; i++) {
      bool b = widget.list[i].isLoading;
      // print(i.toString() + ": " + b.toString());
      Future.delayed(
              Duration(milliseconds: b ? Random().nextInt(10) + 5 : 0) * 100)
          .then((value) {
        try {
          setState(() {
            widget.list[i].isLoading = false;
          });
        } catch (e) {}
      });
    }
  }

  @override
  void initState() {
    super.initState();
    maxItems = min(maxItems, widget.list.length);
    // initList.addAll(widget.list.sublist(0, maxItems));
    states = List.filled(widget.list.length, false);
    //_toggleLoading();
    loadMore(0);
  }

  final initList = List<Project>.empty(growable: true);
  bool isLoading = false;
  int maxItems = 5;
  bool isMaxReached = false;
  int startIndex = 0;
  late List<bool> states;

  Future<void> loadMore(int page) async {
    // here we simulate that the list reached the end
    // and we set the isMaxReached to true to stop
    // the loading widget from showing
    if (startIndex == widget.list.length ||
        initList.length >= widget.list.length) {
      setState(() => isMaxReached = true);
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
    } catch (e) {}

    await Future.delayed(const Duration(seconds: 3));
    // here we simulate the loading of new items
    // from the server or any other source
    // we pass the page number to the onLoadMore function
    // that the package provide to load the next page
    for (int i = startIndex;
        i < min(startIndex + maxItems, widget.list.length);
        i++) {
      bool b = widget.list[i].isLoading;
      // print(i.toString() + ": " + b.toString());
      if (!states[i]) {
        states[i] = true;
        Future.delayed(
                Duration(milliseconds: b ? Random().nextInt(10) + 5 : 0) * 100)
            .then((value) {
          try {
            setState(() {
              widget.list[i].isLoading = false;
            });
          } catch (e) {}
        });
      }
    }
    try {
      setState(() {
        initList.addAll(widget.list.sublist(
            startIndex, min(startIndex + maxItems, widget.list.length)));
        startIndex = min(startIndex + maxItems, widget.list.length);
        isLoading = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer(
        linearGradient: _shimmerGradient,
        child: Scrollbar(
          child:
              // ListView(
              //   physics: ClampingScrollPhysics(),
              //   children: [
              //     // _buildTopRowList(),
              //     const SizedBox(height: 16),
              //     _buildList(),
              //   ],
              // ),

              EnhancedPaginatedView<Project>(
            scrollController: widget.scrollController,
            shouldDeduplicate: false,
            listOfData: initList,
            itemsPerPage: maxItems,
            showLoading: isLoading,
            isMaxReached: isMaxReached,
            onLoadMore: loadMore,
            loadingWidget:
                // const Center(child: CircularProgressIndicator()),
                Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/animations/loading_animation.json', // Replace with the path to your Lottie JSON file
                      fit: BoxFit.cover,
                      width: 60, // Adjust the width and height as needed
                      height: 60,
                      repeat:
                          true, // Set to true if you want the animation to loop
                    ),
                  ),
                  Center(
                    child: Text(
                      Lang.get("loading"),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  )
                ],
              ),
            ),

            /// [showErrorWidget] is a boolean that will be used
            /// to control the error widget
            /// this boolean will be set to true when an error occurs
            showError: false,
            errorWidget: (page) => Center(
              child: Column(
                children: [
                  Text(Lang.get('nothing_here')),
                  ElevatedButton(
                    onPressed: () => loadMore(page),
                    child: Text(Lang.get('Reload')),
                  )
                ],
              ),
            ),
            // header: Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Column(
            //     children: [
            //       Text(
            //         'Header',
            //         style: Theme.of(context).textTheme.headlineLarge,
            //       ),
            //       const SizedBox(height: 16),
            //       OutlinedButton(
            //         onPressed: () {},
            //         child: const Text(Lang.get('Bloc Example'),
            //       ),
            //     ],
            //   ),
            // ),

            /// the `reverse` parameter is a boolean that will be used
            /// to reverse the list and its children
            /// it code be handy when you are building a chat app for example
            /// and you want to reverse the list to show the latest messages

            builder: (physics, items, shrinkWrap, reverse) {
              return ListView.builder(
                // here we must pass the physics, items and shrinkWrap
                // that came from the builder function
                reverse: false,
                physics: physics,
                shrinkWrap: true,
                itemCount: items.length,
                // separatorBuilder: (BuildContext context, int index) {
                //   return const Divider(
                //     height: 16,
                //   );
                // },
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                      width: 100,
                      height: widget.itemHeight,
                      child: _buildListItem(widget.list[index], index));
                },
              );
            },
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _toggleLoading,
      //   child: Icon(
      //     _isLoading ? Icons.hourglass_full : Icons.hourglass_bottom,
      //   ),
      // ),
    );
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildTopRowItem();
        },
      ),
    );
  }

  Widget _buildTopRowItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: const CircleListItem(),
    );
  }

  Widget _buildList() {
    return Container(
      width: 100,
      padding: const EdgeInsets.only(bottom: 60),
      height: widget.itemHeight - 80,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          return _buildListItem(widget.list[index], index);
        },
      ),
    );
  }

  // Widget _buildListItem() {
  //   return ShimmerLoading(
  //     isLoading: _isLoading,
  //     child: CardListItem(
  //       isLoading: _isLoading,
  //     ),
  //   );
  // }
  Widget _buildListItem(ShimmerLoadable w, int index) {
    return ShimmerLoading(
      isLoading: w.isLoading,
      child: ProjectItem(
        project: w as Project,
        onFavoriteTap: () => widget.firstCallback(index),
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  const Shimmer({
    super.key,
    required this.linearGradient,
    this.child,
  });

  final LinearGradient linearGradient;
  final Widget? child;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(
        vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat(min: -0.3, max: 0.7, reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
// code-excerpt-closing-bracket

  LinearGradient get gradient => LinearGradient(
        colors: widget.linearGradient.colors,
        stops: widget.linearGradient.stops,
        begin: widget.linearGradient.begin,
        end: widget.linearGradient.end,
        transform:
            _SlidingGradientTransform(slidePercent: _shimmerController.value),
      );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  double opacity = 0;

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) {
      setState(() {
        // update the shimmer painting.
      });
    } else {
      setState(() {
        opacity = 1;
      });
    }
  }
// code-excerpt-closing-bracket

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(seconds: 1),
        child: widget.child,
      );
    }

    // Collect ancestor shimmer info.
    final shimmer = Shimmer.of(context)!;
    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    Offset offsetWithinShimmer;
    try {
      offsetWithinShimmer = shimmer.getDescendantOffset(
        descendant: context.findRenderObject() as RenderBox,
      );
    } catch (e) {
      offsetWithinShimmer = const Offset(0, 0);
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

//----------- List Items ---------
class CircleListItem extends StatelessWidget {
  const CircleListItem({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            'https://docs.flutter.dev/cookbook'
            '/img-files/effects/split-check/Avatar1.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class CardListItem extends StatelessWidget {
  const CardListItem({
    super.key,
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(height: 16),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://docs.flutter.dev/cookbook'
            '/img-files/effects/split-check/Food1.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 250,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: AutoSizeText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
          'eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        ),
      );
    }
  }
}
