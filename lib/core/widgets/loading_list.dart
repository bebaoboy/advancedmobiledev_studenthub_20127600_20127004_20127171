/*
 *
 * Refazynist is a Refreshable, Lazy and Animated List
 * Writen by Murat TAMCI aka THEMT.CO | http://themt.co
 * 2021/06/04 / v0.0.1
 *
 */

import 'dart:convert';
import 'package:boilerplate/core/widgets/refresh_indicator/indicators/plane_indicator.dart';
import 'package:boilerplate/presentation/home/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef RefazynistErrorBuilder = Widget Function(
    BuildContext bContext, AsyncSnapshot bSnapshot);
typedef RefazynistEmptyBuilder = Widget Function(BuildContext bContext);
typedef RefazynistLoaderBuilder = Widget Function(
    BuildContext bContext, Animation<double> bAnimation);
typedef RefazynistOnLazy = Future<List<dynamic>> Function();
typedef RefazynistItemBuilder = Widget Function(
    dynamic item,
    BuildContext bContext,
    int index,
    Animation<double> bAnimation,
    RefazynistCallType type);
typedef RefazynistRemovedItemBuilder = Widget Function(
    dynamic item,
    BuildContext bContext,
    int index,
    Animation<double> bAnimation,
    RefazynistCallType type);

/// Used for configure how [itemBuilder] or [removeItemBuilder] can be triggered
enum RefazynistCallType {
  /// The builder triggered can be single added
  item,

  /// The builder triggered can be mass added
  all,
}

/// Refazynist is a Refreshable, Lazy and Animated List
///
class Refazynist extends StatefulWidget {
  /// Creates a Refazynist
  ///
  /// The [onInit], [itemBuilder], [removedItemBuilder],
  /// [onLazy], [onRefresh], [sharedPreferencesName] arguments must be
  /// non-null.
  const Refazynist(
      {required this.onInit,
      required this.itemBuilder,
      required this.removedItemBuilder,
      required this.onLazy,
      required this.onRefresh,
      required this.sharedPreferencesName,
      this.emptyBuilder = refazynistDefaultErrorBuilder,
      this.loaderBuilder = refazynistDefaultLoaderBuilder,
      this.insertDuration = const Duration(milliseconds: 250),
      this.removeDuration = const Duration(milliseconds: 250),
      this.sequentialInsert = false,
      this.sequentialRemove = false,
      required this.scrollController,
      this.scrollExtent = 80.0,
      super.key});

  /// A name that's name for cache. Used for [SharedPreferences]
  final String sharedPreferencesName;
  final ScrollController? scrollController;
  final double scrollExtent;

  /// A function that's called builder when list is empty
  final RefazynistEmptyBuilder emptyBuilder;

  /// itemBuilder for rendering on Animated List
  final RefazynistItemBuilder itemBuilder;

  /// itemBuilder for rendering on Animated List when item removed
  final RefazynistRemovedItemBuilder removedItemBuilder;

  /// A function that's called when lazy load is required
  final RefazynistOnLazy onLazy;

  /// A function that's called when swap to refresh
  final RefazynistOnLazy onRefresh;

  /// A function that's called when first run
  final RefazynistOnLazy onInit;

  /// A function that's called when loader rendering when lazy load required
  final RefazynistLoaderBuilder loaderBuilder;

  /// Used for how to be item inserting, sequential or same-time
  final bool sequentialInsert;

  /// Used for how to be item removing, sequential or same-time
  final bool sequentialRemove;

  /// Duration for animation when item inserted to list
  final Duration insertDuration;

  /// Duration for animation when item removed from list
  final Duration removeDuration;

  @override
  RefazynistState createState() => RefazynistState();
}

class _RefazynistItemParam {
  RefazynistCallType callType = RefazynistCallType.all;

  _RefazynistItemParam();
}

class RefazynistState extends State<Refazynist> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  final List<dynamic> _items = <dynamic>[];
  final List<_RefazynistItemParam> _params = <_RefazynistItemParam>[];

  /// A string that's store cursor in SharedPreferences
  String cursor = '';

  bool _end = false;
  Widget? _frontWidget;
  late Widget _animatedListWidget;

  void setTheState() {
    setState(() {});
  }

  void editItem(int index, dynamic item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      _animatedListKey.currentState!.setState(() {});
      setState(() {});
    } else {
      print('refazynist | editItem | index not in range');
    }
  }

  /// Get length of list
  int length() {
    return _items.length;
  }

  /// Remove an item by [index]
  /// [duration] used can be animation
  /// [disappear] user can be just remove it quickly, without animation
  Future<void> removeItem(int index,
      {Duration? duration, bool disappear = false}) async {
    if (index >= 0 && index < _items.length) {
      int oldLen = _items.length;
      await _removeItem(index, RefazynistCallType.item,
          duration: duration, disappear: disappear);
      oldLen--;
      if (_frontWidget == null && oldLen == 0) {
        _frontWidget = widget.emptyBuilder(context);
        setState(() {});
      }
      _setSharedPreferences();
    }
  }

  /// Insert an item by [item] at [index]
  /// callType used can be a type for itemBuilder or removeBuilder
  Future<void> insertItem(int index, dynamic item,
      {RefazynistCallType callType = RefazynistCallType.item}) async {
    _insertItem(index, item, callType: callType);
    _frontWidget = null;
    setState(() {});
    _setSharedPreferences();
  }

  /// Insert all items in [itemList] at [index]
  /// callType used can be a type for itemBuilder or removeBuilder
  Future<void> insertAllItem(int index, List<dynamic> itemList,
      {RefazynistCallType callType = RefazynistCallType.item}) async {
    _insertAllItem(index, itemList, callType: callType);
    _frontWidget = null;
    setState(() {});
    _setSharedPreferences();
  }

  Future<void> _setSharedPreferences() async {
    return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        widget.sharedPreferencesName,
        jsonEncode(
            {'cursor': cursor, '_end': !_loaderShowing, 'list': _items}));
  }

  Future<bool> _getSharedPreferences() async {
    return false;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? spString = prefs.getString(widget.sharedPreferencesName);

    if (spString == '') return false;

    if (spString != null) {
      Map<dynamic, dynamic> sp = jsonDecode(spString);

      if (sp.containsKey('cursor')) {
        cursor = sp['cursor'];
      }

      if (sp.containsKey('_end')) {
        _end = sp['_end'];
        if (_end) {
          removeLoader();
        } else {
          addLoader();
        }
      }

      if (sp.containsKey('list')) {
        List<dynamic> spList = sp['list'];

        if (spList.isNotEmpty) {
          _insertAllItem(0, spList);
        }

        return true;
      }
    }

    return false;
  }

  Future<void> _refresh() async {
    if (!_play) return Future.value();

    cursor = "";

    List<dynamic> refreshList = await widget.onRefresh();

    await clear(sequentialRemove: widget.sequentialRemove);

    if (refreshList.isNotEmpty) {
      _insertAllItem(_items.length, refreshList,
          sequentialInsert: widget.sequentialInsert,
          callType: RefazynistCallType.all);

      addLoader();
    }

    if (_items.isNotEmpty) {
      _frontWidget = null;
    } else {
      _frontWidget = widget.emptyBuilder(context);
    }

    setState(() {});

    return Future.value(null);
  }

  @override
  void initState() {
    super.initState();

    _play = true;
    _loaderShowing = false;

    _animatedListWidget = Scrollbar(
      child: AnimatedList(
        controller: widget.scrollController,
        initialItemCount: _items.length + (_loaderShowing ? 1 : 0),
        key: _animatedListKey,
        itemBuilder: _itemBuilder,
      ),
    );

    _frontWidget = const LoadingScreenWidget();

    _onInit();
  }

  /// Clear the all item on list
  ///
  /// [sequentialRemove] used for remove process, true for ordered-time, false for same-time
  Future<void> clear({bool sequentialRemove = false}) async {
    _clearRunning = true;

    //cursor = "";

    removeLoader();

    int oldLen = _items.length;

    if (sequentialRemove) {
      for (int i = 0; i < oldLen; i++) {
        await _removeItem(0, RefazynistCallType.all);
      }
    } else {
      for (int i = 0; i < oldLen; i++) {
        _removeItem(0, RefazynistCallType.all);
      }
    }

    _setSharedPreferences();

    await Future.delayed(widget.removeDuration);

    if (_items.isNotEmpty) {
      _frontWidget = null;
    } else {
      _frontWidget = widget.emptyBuilder(context);
    }

    setState(() {});

    _clearRunning = false;
  }

  Future<void> _insertItem(index, dynamic item,
      {RefazynistCallType callType = RefazynistCallType.item}) async {
    assert(index >= 0);

    _items.insert(index, item);
    _params.insert(index, _RefazynistItemParam());
    _params[index].callType = callType;

    _animatedListKey.currentState!
        .insertItem(index, duration: widget.insertDuration);

    await Future.delayed(widget.insertDuration);

    return;
  }

  Future<void> _insertAllItem(int index, List<dynamic> list_items,
      {bool sequentialInsert = false,
      RefazynistCallType callType = RefazynistCallType.item}) async {
    if (sequentialInsert) {
      for (int i = 0; i < list_items.length; i++) {
        await _insertItem(index + i, list_items[i], callType: callType);
      }
    } else {
      for (int i = 0; i < list_items.length; i++) {
        _insertItem(index + i, list_items[i], callType: callType);
      }
    }
  }

  Future<dynamic> _removeItem(int index, RefazynistCallType callType,
      {Duration? duration, bool disappear = false}) async {
    assert(index >= 0);
    assert(index < _items.length);

    _params.removeAt(index);
    dynamic item = _items.removeAt(index);
    _animatedListKey.currentState!.removeItem(index, (context, animation) {
      if (disappear) {
        return Container();
      } else {
        return widget.removedItemBuilder(
            item, context, index, animation, callType);
      }
    },
        duration: disappear
            ? const Duration(seconds: 0)
            : duration ?? widget.removeDuration);

    if (disappear == false) {
      await Future.delayed(duration ?? widget.removeDuration);
    }

    return item;
  }

  /// Add loader on the end on list for indicate lazy load is working
  Future<void> addLoader() async {
    _loaderShowing = true;
    _onLazyRunning = false;
    if (_animatedListKey.currentState != null) {
      _animatedListKey.currentState!
          .insertItem(_items.length, duration: widget.insertDuration);
    }
  }

  /// Remove loader on the end on list when lazy load in progress
  Future<void> removeLoader() async {
    if (_loaderShowing) {
      _animatedListKey.currentState!.removeItem(_items.length,
          (riContext, rAnimation) {
        return widget.loaderBuilder(riContext, rAnimation);
      }, duration: widget.removeDuration);

      await Future.delayed(widget.removeDuration);

      _loaderShowing = false;
    }
  }

  bool _loaderShowing = false;
  bool _onLazyRunning = false;
  bool _clearRunning = false;
  bool _play = false;

  Widget _itemBuilder(
      BuildContext ibContext, int index, Animation<double> ibAnimation) {
    if (_loaderShowing && index >= _items.length) {
      // lazynin çağrılması için o an çalışmıyor olması gerek
      // ek olarak temizleme yapılmıyor olmalı. temizlerken eklemek saçma olur

      if (_play && _onLazyRunning == false && _clearRunning == false) {
        _onLazyRunning = true;

        Future<List<dynamic>> futureLazyList = widget.onLazy();

        futureLazyList.then((List<dynamic> lazyList) {
          if (!_play) return;
          if (_clearRunning) {
            return; // temizlenme istendiyse ekleme yapmak anlamsız.
          }

          if (lazyList.isEmpty) {
            removeLoader().then((value) {
              _setSharedPreferences();
            });
          } else {
            _insertAllItem(_items.length, lazyList,
                sequentialInsert: widget.sequentialInsert,
                callType: RefazynistCallType.all);
            _setSharedPreferences();
          }

          _onLazyRunning = false;
        });
      }

      return widget.loaderBuilder(ibContext, ibAnimation);
    }

    if (index < _items.length) {
      return widget.itemBuilder(_items[index], ibContext, index, ibAnimation,
          _params[index].callType);
    }

    return Center(
      child: Text("Overflow #$index"),
    );
  }

  Future<bool> _onInit() async {
    //print ('_onInit');

    if (!_play) return false;

    _loaderShowing = false;

    bool spResult = await _getSharedPreferences(); // kayıtlı veri varsa çek
    //bool spResult = false;

    // kayıtlı veri yoksa netten al
    if (!spResult) {
      List<dynamic> list = await widget.onInit();

      if (list.isNotEmpty) {
        //_items.addAll(list);
        _insertAllItem(0, list,
            sequentialInsert: widget.sequentialInsert,
            callType: RefazynistCallType.all);

        await _setSharedPreferences();
      }
    }

    if (_items.isNotEmpty) {
      _frontWidget = null;
    } else {
      _frontWidget = widget.emptyBuilder(context);
    }
    addLoader();
    setState(() {});

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_frontWidget != null) {
      return PlaneIndicator(
          offsetToArmed: widget.scrollExtent,
          onRefresh: _refresh,
          child: Stack(
            children: [
              Opacity(
                opacity: 0,
                child: _animatedListWidget,
              ),
              _frontWidget!,
            ],
          ));
    } else {
      return PlaneIndicator(
        onRefresh: _refresh,
        offsetToArmed: widget.scrollExtent,
        child: _animatedListWidget,
      );
    }
  }
}

Widget refazynistDefaultErrorBuilder(BuildContext bContext) {
  return Stack(
    children: <Widget>[
      ListView(),
      const Center(
        child: Wrap(
          children: [
            Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.black26,
                ),
                Text('Empty'),
              ],
            )
          ],
        ),
      ),
    ],
  );
}

Widget refazynistDefaultLoaderBuilder(
    BuildContext bContext, Animation<double> bAnimation) {
  return Center(
    child: FadeTransition(
        opacity: bAnimation,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        )),
  );
}
