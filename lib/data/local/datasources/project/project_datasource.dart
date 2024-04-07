import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';

class ProjectDataSource{
    // database instance
  final SembastClient _sembastClient;

  // Constructor
  ProjectDataSource(this._sembastClient);

  void insert(Project project) {}
}