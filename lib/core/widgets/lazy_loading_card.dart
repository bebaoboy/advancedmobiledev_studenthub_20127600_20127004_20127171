import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:boilerplate/domain/entity/project/project.dart';
import 'package:boilerplate/presentation/dashboard/components/project_item.dart';
import 'package:enhanced_paginated_view/enhanced_paginated_view.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
  bool _isLoading = true;
  late List<Timer?> timer;

  void _toggleLoading() async {
    print("done animation shimmering");
    for (int i = 0; i < widget.list.length; i++) {
      bool b = widget.list[i].isLoading;
      // print(i.toString() + ": " + b.toString());
      timer[i] = Timer(
          Duration(milliseconds: b ? Random().nextInt(30) + 8 : 0) * 100, () {
        try {
          setState(() {
            widget.list[i].isLoading = false;
          });
        } catch (e) {
          print(e.toString());
        }
      });
    }
  }

  @override
  void dispose() {
    timer.forEach((element) {
      if (element != null) element.cancel();
    });
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
          child: ListView(
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
  });

  final double itemHeight;
  final List<Project> list;
  final Function firstCallback;

  @override
  State<LazyLoadingAnimationProjectList> createState() =>
      _LazyLoadingAnimationProjectListState();
}

class _LazyLoadingAnimationProjectListState
    extends State<LazyLoadingAnimationProjectList> {
  bool _isLoading = true;

  void _toggleLoading() async {
    print("done animation shimmering");
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
        } catch (e) {
          print(e.toString());
        }
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
    print(widget.list.length);
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
    } catch (e) {
      print(e);
    }

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
          } catch (e) {
            print(e.toString());
          }
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
    } catch (e) {
      print(e);
    }
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

              Container(
            padding: const EdgeInsets.only(bottom: 60),
            child: EnhancedPaginatedView<Project>(
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
                    const Center(
                      child: Text(
                        "Please wait...",
                        style: TextStyle(
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
                    const Text('No items found'),
                    ElevatedButton(
                      onPressed: () => loadMore(page),
                      child: const Text('Reload'),
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
              //         child: const Text('Bloc Example'),
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
                    return Container(
                        width: 100,
                        height: widget.itemHeight,
                        child: _buildListItem(widget.list[index], index));
                  },
                );
              },
            ),
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
    var offsetWithinShimmer;
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
