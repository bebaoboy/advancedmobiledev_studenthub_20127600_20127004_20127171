import 'package:boilerplate/core/widgets/backguard.dart';
import 'package:boilerplate/domain/entity/post/post.dart';
import 'package:flutter/material.dart';

class Welcome2 extends StatefulWidget {
  const Welcome2({super.key});

  @override
  State<Welcome2> createState() => _Welcome2State();
}

class _Welcome2State extends State<Welcome2> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: ScrollController(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            width: 64,
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                'https://docs.flutter.dev/assets/images/404/dash_nest.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackGuard(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            controller: ScrollController(),

            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.amber,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                // title: const Text("Title"),
                expandedHeight: 330.0,
                backgroundColor: Colors.white,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  // title: const Text('Available seats'),
                  background: Stack(
                    children: [
                      Positioned(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(
                                70,
                              ),
                            ),
                            // border: Border(
                            //   left: BorderSide(
                            //     width: 1,
                            //     style: BorderStyle.solid,
                            //   ),
                            //   right: BorderSide(
                            //     width: 1,
                            //     style: BorderStyle.solid,
                            //   ),
                            //   top: BorderSide(
                            //     width: 1,
                            //     style: BorderStyle.solid,
                            //   ),
                            //   bottom: BorderSide(
                            //     width: 1,
                            //     style: BorderStyle.solid,
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                      Positioned(
                        height: 200,
                        top: 130,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(
                                70,
                              ),
                              topLeft: Radius.circular(
                                70,
                              ),
                              topRight: Radius.circular(
                                70,
                              ),
                            ),
                          ),
                          child: const Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.all(45.0),
                                child: Text("Welcome\nFind your dream job"),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            70,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 30),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text("Explore the people"), Text("...")],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _buildTopRowList(),
                          const SizedBox(
                            height: 20,
                          ),
                          ListView.separated(
                            controller: ScrollController(),
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: postList.length,
                            separatorBuilder: (context, position) {
                              return const Divider();
                            },
                            itemBuilder: (context, position) {
                              return _buildListItem(position);
                            },
                          ),
                        ],
                      )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int position) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.cloud_circle),
      title: Text(
        '${postList[position].title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        '${postList[position].body}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------

  List<Post> postList = [
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
    Post(
        body:
            "CAEShAFDZzFVWlhoMFgyZHlNM1Y0WXpaM0dBSWlTeEliQ2d0SVpXeHNieUJYYjNKc1pCRUFBQUFBQUFCTFFFQUdxQUVBV2drUkFBQUFBQUFBU1VCeUVna0FBQUFBQUFBQUFCRUFBQUFBQUFBQUFQb0RBUElGQ1FrQUFBQUFBQUR3UDJJQXdnRUE=",
        title: "Posttt"),
  ];
}
