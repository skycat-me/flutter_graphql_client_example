# graphql_client_example

graphql-flutterのサンプルをいじってるかんじです。

> graphql-flutter/example at master · zino-app/graphql-flutter
> https://github.com/zino-app/graphql-flutter/tree/master/example

graphql-flutter 1.0.0+2がコンパイルエラーで死ぬ場合は,
pubのcache(~/.pub-cache/hosted/pub.dartlang.org/graphql_flutter-1.0.0+2)にある
``lib/src/widgets/subscription.dart``を削除して,
``libs/graphql_flutter.dart``内のexportを削除してください。