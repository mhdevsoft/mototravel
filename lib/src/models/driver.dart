import 'dart:convert';

Drive driveFromJson(String str) => Drive.fromJson(json.decode(str));

String driveToJson(Drive data) => json.encode(data.toJson());

class Drive {
    Drive({
        this.id,
        this.username,
        this.email,
        this.password,
        this.placa,
        this.token
    });

    String id;
    String username;
    String email;
    String password;
    String placa;
    String token;

    factory Drive.fromJson(Map<String, dynamic> json) => Drive(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
        placa: json["placa"],
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "password": password,
        "placa": placa,
        "token": token,
    };
}
