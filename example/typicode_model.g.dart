// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typicode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypicodeModel _$TypicodeModelFromJson(Map<String, dynamic> json) =>
    TypicodeModel(
      json['userId'] as int?,
      json['id'] as int?,
      json['title'] as String?,
      json['body'] as String?,
    );

Map<String, dynamic> _$TypicodeModelToJson(TypicodeModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
    };
