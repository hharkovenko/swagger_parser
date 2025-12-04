import 'package:swagger_parser/src/parser/config/parser_config.dart';
import 'package:swagger_parser/src/parser/parser/open_api_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Strip Query Params from Path', () {
    test('should strip query params when config is enabled', () {
      const spec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/entitiesQuery/find/keys{?timeseries,attributes,scope}": {
      "post": {
        "tags": ["entity-query-controller"],
        "summary": "Find Entity Keys by Query",
        "operationId": "findEntityTimeseriesAndAttributesKeysByQuery",
        "parameters": [
          {
            "name": "timeseries",
            "in": "query",
            "required": true,
            "schema": {
              "type": "boolean"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

      const config = ParserConfig(
        spec,
        isJson: true,
        stripQueryParamsFromPath: true,
      );

      final parser = OpenApiParser(config);
      final clients = parser.parseRestClients();

      expect(clients.isNotEmpty, true);
      final requests = clients.first.requests;
      expect(requests.isNotEmpty, true);
      
      // The route should not contain query params
      expect(
        requests.first.route,
        equals('/api/entitiesQuery/find/keys'),
      );
    });

    test('should handle duplicate paths with different query params', () {
      const spec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/data{?param1}": {
      "get": {
        "tags": ["test"],
        "summary": "Get data with param1",
        "operationId": "getDataParam1",
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    },
    "/api/data{?param2}": {
      "get": {
        "tags": ["test"],
        "summary": "Get data with param2",
        "operationId": "getDataParam2",
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "number"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

      const config = ParserConfig(
        spec,
        isJson: true,
        stripQueryParamsFromPath: true,
      );

      final parser = OpenApiParser(config);
      final clients = parser.parseRestClients();

      expect(clients.isNotEmpty, true);
      final requests = clients.first.requests;
      expect(requests.length, equals(2));
      
      // Both should have the same route
      expect(requests[0].route, equals('/api/data'));
      expect(requests[1].route, equals('/api/data'));
      
      // But different operation IDs
      expect(requests[0].name, equals('getDataParam1'));
      expect(requests[1].name, equals('getDataParam2'));
    });

    test('should add suffix to duplicate method names when using pathMethodName', () {
      const spec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/data{?param1}": {
      "get": {
        "tags": ["test"],
        "summary": "Get data with param1",
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    },
    "/api/data{?param2}": {
      "get": {
        "tags": ["test"],
        "summary": "Get data with param2",
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "number"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

      const config = ParserConfig(
        spec,
        isJson: true,
        stripQueryParamsFromPath: true,
        pathMethodName: true,
      );

      final parser = OpenApiParser(config);
      final clients = parser.parseRestClients();

      expect(clients.isNotEmpty, true);
      final requests = clients.first.requests;
      expect(requests.length, equals(2));
      
      // First should have base name, second should have suffix
      expect(requests[0].name, equals('getApiData'));
      expect(requests[1].name, equals('getApiData2'));
    });

    test('should not strip query params when config is disabled', () {
      const spec = '''
{
  "openapi": "3.0.0",
  "info": {
    "title": "Test API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/data{?param1,param2}": {
      "get": {
        "tags": ["test"],
        "summary": "Get data",
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

      const config = ParserConfig(
        spec,
        isJson: true,
      );

      final parser = OpenApiParser(config);
      final clients = parser.parseRestClients();

      expect(clients.isNotEmpty, true);
      final requests = clients.first.requests;
      expect(requests.isNotEmpty, true);
      
      // The route should contain query params
      expect(
        requests.first.route,
        equals('/api/data{?param1,param2}'),
      );
    });
  });
}
