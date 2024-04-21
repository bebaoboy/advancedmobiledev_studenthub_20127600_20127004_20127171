import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/data/local/constants/db_constants.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/domain/entity/project/project_list.dart';
import 'package:sembast/sembast.dart';

class ProjectDataSource {
  final _projectStore =
      intMapStoreFactory.store(DBConstants.PROJECT_STORE_NAME);

  // database instance
  final SembastClient _sembastClient;

  // Constructor
  ProjectDataSource(this._sembastClient);

  // DB functions:--------------------------------------------------------------
  Future insert(Project project) async {
    print("insert ${project.objectId}");
    if (project.objectId != null &&
        int.tryParse(project.objectId ?? "") != null) {
      return await _projectStore
          .record(int.parse(project.objectId!))
          .put(_sembastClient.database, project.toJson());
    } else {
      return await _projectStore.add(_sembastClient.database, project.toJson());
    }
  }

  Future<int> count() async {
    return await _projectStore.count(_sembastClient.database);
  }

  Future<List<Project>> getAllSortedByFilter({List<Filter>? filters}) async {
    //creating finder
    final finder = Finder(
        filter: filters != null ? Filter.and(filters) : null,
        sortOrders: [SortOrder(DBConstants.PROJECT_FIELD_ID)]);

    final recordSnapshots = await _projectStore.find(
      _sembastClient.database,
      finder: finder,
    );

    // Making a List<Project> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final project = Project.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      project.objectId = snapshot.key.toString();
      return project;
    }).toList();
  }

  Future<ProjectList> getProjectsFromDb() async {
    //print('Loading from database');

    // project list
    var projectList;

    // fetching data
    final recordSnapshots = await _projectStore.find(
      _sembastClient.database,
    );

    // Making a List<Post> out of List<RecordSnapshot>
    if (recordSnapshots.isNotEmpty) {
      projectList = ProjectList(
          projects: recordSnapshots.map((snapshot) {
        final project = Project.fromMap(snapshot.value);
        // An ID is a key of a record from the database.
        // project.objectId = snapshot.key.toString();
        return project;
      }).toList());
    }

    return projectList;
  }

  Future<int> update(Project project) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(project.objectId));
    return await _projectStore.update(
      _sembastClient.database,
      project.toJson(),
      finder: finder,
    );
  }

  Future<int> delete(Project project) async {
    final finder = Finder(filter: Filter.byKey(project.objectId));
    return await _projectStore.delete(
      _sembastClient.database,
      finder: finder,
    );
  }

  Future deleteAll() async {
    await _projectStore.drop(
      _sembastClient.database,
    );
  }
}
