class LoginModel {
  final int status;
  final String message;
  final List<UserData> data;

  LoginModel({required this.status, required this.message, required this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List).map((e) => UserData.fromJson(e)).toList(),
    );
  }
}

class UserData {
  final String usersrno;
  final String employeesrno;
  final String name;
  final String employeeType;

  UserData({
    required this.usersrno,
    required this.employeesrno,
    required this.name,
    required this.employeeType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      usersrno: json['usersrno'],
      employeesrno: json['employeesrno'],
      name: json['name'],
      employeeType: json['employee_type'],
    );
  }
}
