part of graphql_client;

// TODO: 認証して永続化させる
const String YOUR_PERSONAL_ACCESS_TOKEN = '<YOUR_PERSONAL_ACCESS_TOKEN>';

// TODO: graphql_flutterのサンプルそのままなので汚いので整理する
class Bloc {
  Bloc() {
    _queryRepo();
    _updateNumberOfRepo.listen((int n) async => _queryRepo(nRepositories: n));
    _toggleStarSubject.listen((GithubRepoModel t) async {
      _toggleStarLoadingSubject.add(t.id);
      // @todo handle error
      final QueryResult _ = await _mutateToggleStar(t);

      _repoSubject.add(_repoSubject.value.map((GithubRepoModel e) {
        if (e.id != t.id) {
          return e;
        }
        return GithubRepoModel(
            id: t.id, name: t.name, viewerHasStarred: !t.viewerHasStarred);
      }).toList());
      _toggleStarLoadingSubject.add(null);
    });
  }

  final BehaviorSubject<List<GithubRepoModel>> _repoSubject =
      BehaviorSubject<List<GithubRepoModel>>();

  Stream<List<GithubRepoModel>> get repoStream => _repoSubject.stream;

  final ReplaySubject<GithubRepoModel> _toggleStarSubject =
      ReplaySubject<GithubRepoModel>();

  Sink<GithubRepoModel> get toggleStarSink => _toggleStarSubject;

  /// The repo currently loading, if any
  final BehaviorSubject<String> _toggleStarLoadingSubject =
      BehaviorSubject<String>();

  Stream<String> get toggleStarLoadingStream =>
      _toggleStarLoadingSubject.stream;

  final BehaviorSubject<int> _updateNumberOfRepo = BehaviorSubject<int>();

  Sink<int> get updateNumberOfRepoSink => _updateNumberOfRepo;

  static final HttpLink _httpLink = HttpLink(
    uri: 'https://api.github.com/graphql',
  );

  static final AuthLink _authLink = AuthLink(
    getToken: () async => 'Bearer $YOUR_PERSONAL_ACCESS_TOKEN',
  );

  static final Link _link = _authLink.concat(_httpLink as Link);

  // TODO: クライアントはapp.dartあたりで作ってstoreにいれて使い回す
  static final GraphQLClient _client = GraphQLClient(
    cache: NormalizedInMemoryCache(
      dataIdFromObject: typenameDataIdFromObject,
    ),
    link: _link,
  );

  Future<QueryResult> _mutateToggleStar(GithubRepoModel repo) async {
    final MutationOptions _options = MutationOptions(
      document:
          repo.viewerHasStarred ? Mutations.removeStar : Mutations.addStar,
      variables: <String, String>{
        'starrableId': repo.id,
      },
//      fetchPolicy: widget.options.fetchPolicy,
//      errorPolicy: widget.options.errorPolicy,
    );

    final QueryResult result = await _client.mutate(_options);
    return result;
  }

  Future<void> _queryRepo({int nRepositories = 50}) async {
    // null is loading
    _repoSubject.add(null);
//    FetchPolicy fetchPolicy = widget.options.fetchPolicy;
//
//    if (fetchPolicy == FetchPolicy.cacheFirst) {
//      fetchPolicy = FetchPolicy.cacheAndNetwork;
//    }
    final WatchQueryOptions _options = WatchQueryOptions(
      document: Queries.readRepositories,
      variables: <String, dynamic>{
        'nRepositories': nRepositories,
      },
//      fetchPolicy: fetchPolicy,
//      errorPolicy: widget.options.errorPolicy,
      pollInterval: 4,
      fetchResults: true,
//      context: widget.options.context,
    );

    final QueryResult result = await _client.query(_options);

    if (result.hasErrors) {
      _repoSubject.addError(result.errors);
      return;
    }

    // result.data can be either a [List<dynamic>] or a [Map<String, dynamic>]
    final List<dynamic> repositories =
        result.data['viewer']['repositories']['nodes'] as List<dynamic>;

    _repoSubject.add(repositories
        .map((dynamic e) => GithubRepoModel(
              id: e['id'] as String,
              name: e['name'] as String,
              viewerHasStarred: e['viewerHasStarred'] as bool,
            ))
        .toList());
  }
}
