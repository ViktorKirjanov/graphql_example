import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink =
        HttpLink(uri: 'https://countries.trevorblades.com/');
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      ),
    );

    return MaterialApp(
      title: 'GraphQL Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GraphQLProvider(
        client: client,
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String getContinents = r"""
  query GetContinents{
    continents{
      code
      name
    }
  }
  """;

  String getContinentByCode = r"""
    query GetContinentByCode($code : ID!){
      continent(code:$code){
        name
        countries{
          name
        }
      }
    }
    """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GraphQL Example'),
      ),
      body: Query(
        options: QueryOptions(
          documentNode: gql(getContinentByCode),
          variables: <String, dynamic>{"code": "AS"},
        ),
        builder: (
          QueryResult result, {
          VoidCallback refetch,
          FetchMore fetchMore,
        }) {
          if (result.hasException) {
            return Text(result.exception.toString());
          } else if (result.loading) {
            return Text('Loading...');
          } else if (result.data == null) {
            return Text('No Data');
          }

          // it can be either Map or List
          List data = result.data['continent']['countries'];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return ListTile(
                title: Text(item['name']),
              );
            },
          );
        },
      ),
    );
  }
}
