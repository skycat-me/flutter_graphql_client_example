part of graphql_client;

// TODO: データ取得までリポジトリで行う
class Queries {
  static const String readRepositories = r'''
  query ReadRepositories($nRepositories: Int!) {
    viewer {
      repositories(last: $nRepositories) {
        nodes {
          __typename
          id
          name
          viewerHasStarred
        }
      }
    }
  }
''';

  static const String testSubscription = r'''
		subscription test {
	    deviceChanged(id: 2) {
        id
        name
      }
		}
''';
}

class Mutations {
  static const String addStar = r'''
  mutation AddStar($starrableId: ID!) {
    action: addStar(input: {starrableId: $starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
''';

  static const String removeStar = r'''
  mutation RemoveStar($starrableId: ID!) {
    action: removeStar(input: {starrableId: $starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
''';
}
