import 'package:muslim/api/endpoint/jadwal_ajan/azan_response.dart';

class AdzanItem {
    bool status;
    Request request;
    AzanItem data;

    AdzanItem({
        required this.status,
        required this.request,
        required this.data,
    });

    factory AdzanItem.fromJson(Map<String, dynamic> json) => AdzanItem(
        status: json["status"],
        request: Request.fromJson(json["request"]),
        data: AzanItem.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "request": request.toJson(),
        "data": data.toJson(),
    };
}