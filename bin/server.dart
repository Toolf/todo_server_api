import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:todo_server_api/api/api.dart';
import 'package:todo_server_api/core/endpoint.dart';
import 'package:todo_server_api/core/exception/api_exception.dart';
import 'package:todo_server_api/core/exception/db_exception.dart';
import 'package:todo_server_api/core/exception/validation_exception.dart';

import 'systemInit.dart';

part 'endpoints.dart';

FutureOr<Response> _rootHandler(Request req) async {
  final defaultHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'X-Requested-With,content-type',
  };
  print("request");
  try {
    if (req.method == "OPTIONS") {
      return Response.ok(
        "",
        headers: defaultHeaders,
      );
    }
    if (req.method != "POST") {
      return Response(
        400,
        body: "Invalid method",
        headers: defaultHeaders,
      );
    }

    final data = await req.readAsString();
    if (data.isEmpty) {
      return Response(
        400,
        body: "Invalid request",
        headers: defaultHeaders,
      );
    }
    final jsonData = jsonDecode(data);
    if (jsonData is! Map) {
      return Response(
        400,
        body: "Invalid request",
        headers: defaultHeaders,
      );
    }

    final method = jsonData["method"];
    if (method == null) {
      return Response(
        400,
        body: "Method field must exists",
        headers: defaultHeaders,
      );
    }

    final endpoint = endpoints[method];
    if (endpoint == null) {
      return Response(
        400,
        body: "Method not found",
        headers: defaultHeaders,
      );
    }

    endpoint.parameters?.validate(jsonData["data"]);
    final endpointData =
        endpoint.parameters?.entityConstructor(jsonData["data"]) ??
            jsonData["data"];
    endpoint.validate(endpointData);
    final res = await endpoint.method(endpointData);
    final resJsonString = jsonEncode(res);
    final resJson = jsonDecode(resJsonString);
    endpoint.returns?.validate(resJson);
    print(resJsonString);
    return Response.ok(
      resJsonString,
      headers: defaultHeaders,
    );
  } on DbException catch (e) {
    print(e.inner);
    return Response(
      400,
      body: e.message,
      headers: defaultHeaders,
    );
  } on ApiException catch (e) {
    return Response(
      400,
      body: e.message,
      headers: defaultHeaders,
    );
  } on ValidationException catch (e) {
    return Response(
      400,
      body: e.message,
      headers: defaultHeaders,
    );
  } catch (e) {
    print(e);
    return Response.internalServerError(
      headers: defaultHeaders,
    );
  }
}

void main(List<String> args) async {
  systemInit();
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_rootHandler, ip, port);
  print('Server listening on port ${server.port}');
}
