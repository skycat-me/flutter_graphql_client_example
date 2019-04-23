part of graphql_client;

class GithubRepoModel {
  const GithubRepoModel({this.id, this.name, this.viewerHasStarred});

  final String id;
  final String name;
  final bool viewerHasStarred;
}
