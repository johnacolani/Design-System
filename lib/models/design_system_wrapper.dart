// import 'package:json_annotation/json_annotation.dart';
import 'design_system.dart';

// part 'design_system_wrapper.g.dart';

// @JsonSerializable()
class DesignSystemWrapper {
  // @JsonKey(name: 'designSystem')
  final DesignSystem designSystem;

  DesignSystemWrapper({required this.designSystem});

  // factory DesignSystemWrapper.fromJson(Map<String, dynamic> json) =>
  //     _$DesignSystemWrapperFromJson(json);

  // Map<String, dynamic> toJson() => _$DesignSystemWrapperToJson(this);
}
