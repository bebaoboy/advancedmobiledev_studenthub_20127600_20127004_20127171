export 'src/core/address_book/models/addres_book_result.dart';
export 'src/core/address_book/models/cube_contact.dart';
export 'src/core/address_book/query/address_book_queries.dart';

export 'src/core/auth/models/cube_session.dart';
export 'src/core/auth/query/auth_query.dart';
export 'src/core/auth/query/delete_session_query.dart';
export 'src/core/auth/query/get_session_query.dart';

export 'src/core/cube_exceptions.dart';
export 'src/core/cube_session_manager.dart';

export 'src/core/models/cube_entity.dart';
export 'src/core/models/cube_settings.dart';

export 'src/core/users/models/cube_user.dart';
export 'src/core/users/query/create_user_query.dart';
export 'src/core/users/query/delete_user_query.dart';
export 'src/core/users/query/get_users_query.dart';
export 'src/core/users/query/get_users_v2_query.dart';
export 'src/core/users/query/reset_password_query.dart';
export 'src/core/users/query/update_user_query.dart';

export 'src/core/rest/query/query.dart';
export 'src/core/rest/request/request_help_models.dart';
export 'src/core/rest/request/rest_request.dart';
export 'src/core/rest/response/delete_items_result.dart';
export 'src/core/rest/response/paged_result.dart';
export 'src/core/rest/response/rest_response.dart';

export 'src/core/utils/collections_utils.dart';
export 'src/core/utils/consts.dart';
export 'src/core/utils/cube_logger.dart';
export 'src/core/utils/platform_utils.dart';
export 'src/core/utils/string_utils.dart';

import 'src/core/address_book/models/addres_book_result.dart';
import 'src/core/address_book/models/cube_contact.dart';
import 'src/core/address_book/query/address_book_queries.dart';
import 'src/core/auth/models/cube_session.dart';
import 'src/core/auth/query/auth_query.dart';
import 'src/core/auth/query/delete_session_query.dart';
import 'src/core/auth/query/get_session_query.dart';
import 'src/core/models/cube_settings.dart';
import 'src/core/rest/request/request_help_models.dart';
import 'src/core/rest/response/paged_result.dart';
import 'src/core/users/models/cube_user.dart';
import 'src/core/users/query/create_user_query.dart';
import 'src/core/users/query/delete_user_query.dart';
import 'src/core/users/query/get_users_query.dart';
import 'src/core/users/query/get_users_v2_query.dart';
import 'src/core/users/query/reset_password_query.dart';
import 'src/core/users/query/update_user_query.dart';
import 'src/core/utils/consts.dart';

init(String applicationId, String authorizationKey, String authorizationSecret,
    {Future<CubeSession> Function()? onSessionRestore}) {
  CubeSettings.instance.init(
      applicationId, authorizationKey, authorizationSecret,
      onSessionRestore: onSessionRestore);
}

setEndpoints(String apiEndpoint, String chatEndpoint) {
  CubeSettings.instance.setEndpoints(apiEndpoint, chatEndpoint);
}

Future<CubeSession> createSession([CubeUser? cubeUser]) {
  return CreateSessionQuery(cubeUser).perform();
}

Future<CubeSession> createSessionUsingSocialProvider(
    String socialProvider, String accessToken,
    [String? accessTokenSecret]) {
  return CreateSessionQuery.usingSocial(
      socialProvider, List.of({accessToken, accessTokenSecret})).perform();
}

@Deprecated(
    'Use [createSessionUsingFirebasePhone(projectId, accessToken)] instead.')
Future<CubeSession> createSessionUsingFirebase(
    String projectId, String accessToken) {
  return createSessionUsingFirebasePhone(projectId, accessToken);
}

Future<CubeSession> createSessionUsingFirebasePhone(
    String projectId, String accessToken) {
  return CreateSessionQuery.usingSocial(
      CubeProvider.FIREBASE_PHONE, List.of({projectId, accessToken})).perform();
}

Future<CubeSession> createSessionUsingFirebaseEmail(
    String projectId, String accessToken) {
  return CreateSessionQuery.usingSocial(
      CubeProvider.FIREBASE_EMAIL, List.of({projectId, accessToken})).perform();
}

Future<void> deleteSession() {
  return DeleteSessionQuery().perform();
}

Future<void> deleteSessionsExceptCurrent() {
  return DeleteSessionQuery(exceptCurrent: true).perform();
}

Future<CubeSession> getSession() {
  return GetSessionQuery().perform();
}

Future<CubeUser> signIn(CubeUser user) {
  return SignInQuery(user).perform();
}

Future<CubeUser> signInByLogin(String login, String password) {
  CubeUser user = CubeUser(login: login, password: password);
  return signIn(user);
}

Future<CubeUser> signInByEmail(String email, String password) {
  CubeUser user = CubeUser(email: email, password: password);
  return signIn(user);
}

Future<CubeUser> signInUsingSocialProvider(
    String socialProvider, String accessToken,
    [String? accessTokenSecret]) {
  return SignInQuery.usingSocial(
      socialProvider, List.of({accessToken, accessTokenSecret})).perform();
}

@Deprecated('Use [signInUsingFirebasePhone(projectId, accessToken)] instead.')
Future<CubeUser> signInUsingFirebase(String projectId, String accessToken) {
  return signInUsingFirebasePhone(projectId, accessToken);
}

Future<CubeUser> signInUsingFirebasePhone(
    String projectId, String accessToken) {
  return SignInQuery.usingSocial(
      CubeProvider.FIREBASE_PHONE, List.of({projectId, accessToken})).perform();
}

Future<CubeUser> signInUsingFirebaseEmail(
    String projectId, String accessToken) {
  return SignInQuery.usingSocial(
      CubeProvider.FIREBASE_EMAIL, List.of({projectId, accessToken})).perform();
}

Future<CubeUser> signUp(CubeUser user) {
  return CreateUserQuery(user).perform();
}

Future<void> signOut() {
  return SignOutQuery().perform();
}

Future<CubeUser> updateUser(CubeUser user) {
  return UpdateUserQuery(user).perform();
}

Future<void> deleteUser(int userId) {
  return DeleteUserQuery.byId(userId).perform();
}

Future<void> deleteUserByExternalId(int externalId) {
  return DeleteUserQuery.byExternalId(externalId).perform();
}

Future<void> resetPassword(String email) {
  return ResetPasswordQuery(email).perform();
}

@Deprecated(
    'Use the `getUsers(Map<String, String> parameters, {RequestPaginator? paginator, RequestSorter? sorter})` function instead.')
Future<PagedResult<CubeUser>?> getAllUsers() {
  return GetUsersQuery.byFilter().perform();
}

/// The method returns the list according to the specified list of parameters.
/// The list of available [parameters] is provided in the Server API documentation
/// by link https://developers.connectycube.com/server/users?id=retrieve-users-v2
/// [paginator] - the instance of the helper class `RequestPaginator` that is representing
/// the pagination parameters in the request. Note: the [paginator.page] should start from 0.
/// [sorter] - the instance of the helper class `RequestSorter` that is representing
/// the sorting parameters in the request. The example can be `var sorter = RequestSorter.desc('created_at');`
Future<PagedResult<CubeUser>?> getUsers(Map<String, dynamic> parameters,
    {RequestPaginator? paginator, RequestSorter? sorter}) {
  return GetUsersV2Query(parameters, paginator: paginator, sorter: sorter)
      .perform();
}

/// [ids] - the set of ids of users you want to get
/// [paginator] - the instance of the helper class `RequestPaginator` that is representing
/// the pagination parameters in the request. Note: the [paginator.page] should start from 0.
/// [sorter] - the instance of the helper class `RequestSorter` that is representing
/// the sorting parameters in the request. The example can be `var sorter = RequestSorter.desc('created_at');`
Future<PagedResult<CubeUser>?> getAllUsersByIds(Set<int> ids,
    {RequestPaginator? paginator, RequestSorter? sorter}) {
  return GetUsersV2Query(
    {'$FILTER_ID[${QueryRule.IN}]': ids},
    paginator: paginator,
    sorter: sorter,
  ).perform();
}

///Returns users by the custom filter. Possible filters provided by link https://developers.connectycube.com/server/users?id=parameters-1
///For example for getting users by ids you can use the next code snippet:
///
///```dart
///var ids = [22, 33, 44];
///
///var requestFilter = RequestFilter(
///   RequestFieldType.NUMBER, "id", QueryRule.IN, ids.join(","));
///
///getUsersByFilter(requestFilter).then((response) {
///   var users = response?.items;
///});
///```
///
@Deprecated(
    'The API is deprecated due to an update of the GET Users Server API to the V2 version. '
    'Use the `getUsers(Map<String, String> parameters, {RequestPaginator? paginator, RequestSorter? sorter})` function instead.')
Future<PagedResult<CubeUser>?> getUsersByFilter(RequestFilter filter) {
  return GetUsersQuery.byFilter(filter).perform();
}

/// [fullName] - the part of the 'fullName' with which the name begins.
/// [paginator] - the instance of the helper class `RequestPaginator` that is representing
/// the pagination parameters in the request.
/// Pay attention: the [paginator.itemsPerPage] should be `5` for this request.
/// Note: the [paginator.page] should start from 0.
/// [sorter] - the instance of the helper class `RequestSorter` that is representing
/// the sorting parameters in the request. The example can be `var sorter = RequestSorter.desc('created_at');`
Future<PagedResult<CubeUser>?> getUsersByFullName(String fullName,
    {RequestPaginator? paginator, RequestSorter? sorter}) {
  return GetUsersV2Query(
    {'$FILTER_FULL_NAME[${QueryRule.START_WITH}]': fullName},
    paginator: paginator,
    sorter: sorter,
  ).perform();
}

Future<PagedResult<CubeUser>?> getUsersByTags(Set<String> tags,
    {RequestPaginator? paginator, RequestSorter? sorter}) {
  return GetUsersV2Query(
    {'$FILTER_USER_TAGS[${QueryRule.IN}]': tags},
    paginator: paginator,
    sorter: sorter,
  ).perform();
}

Future<CubeUser?> getUserById(int id) {
  return GetUsersV2Query.byIdentifier(FILTER_ID, id)
      .perform()
      .then((value) => value.items[0]);
}

Future<CubeUser?> getUserByIdentifier(
    String identifierName, dynamic identifierValue,
    {Map<String, dynamic>? additionalParameters}) {
  return GetUsersV2Query.byIdentifier(
    identifierName,
    identifierValue,
    additionalParameters: additionalParameters,
  ).perform().then((pagedResult) =>
      pagedResult.items.isEmpty ? null : pagedResult.items.first);
}

Future<CubeUser?> getUserByLogin(String login) {
  return getUserByIdentifier(FILTER_LOGIN, login);
}

Future<CubeUser?> getUserByEmail(String email) {
  return getUserByIdentifier(FILTER_EMAIL, email);
}

Future<CubeUser?> getUserByFacebookId(String facebookId) {
  return getUserByIdentifier(FILTER_FACEBOOK_ID, facebookId);
}

Future<CubeUser?> getUserByTwitterId(String twitterId) {
  return getUserByIdentifier(FILTER_TWITTER_ID, twitterId);
}

Future<CubeUser?> getUserByPhoneNumber(String phone) {
  return getUserByIdentifier(FILTER_PHONE, phone);
}

@Deprecated('The field `externalId` of the `CubeUser` model is deprecated. '
    'Use the `getUserByExternalUserId(String externalUserId)` function for requesting the user by `externalUserId`')
Future<CubeUser?> getUserByExternalId(int externalId) {
  return GetUserQuery.byExternal(externalId).perform();
}

Future<CubeUser?> getUserByExternalUserId(String externalUserId) {
  return getUserByIdentifier(EXTERNAL_USER_ID, externalUserId);
}

Future<AddressBookResult?> uploadAddressBook(List<CubeContact> contacts,
    {bool? force, String? udid}) {
  return UploadAddressBookQuery(contacts, force, udid).perform();
}

Future<List<CubeContact>?> getAddressBook([String? udid]) {
  return GetAddressBookQuery(udid).perform();
}

Future<List<CubeUser>?> getRegisteredUsersFromAddressBook(bool compact,
    [String? udid]) {
  return GetRegisteredUsers(compact, udid).perform();
}
