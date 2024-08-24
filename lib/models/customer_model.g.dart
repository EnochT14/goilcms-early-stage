// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      organizationName: fields[0] as String,
      personInCharge: fields[1] as String,
      phoneNumber: fields[2] as String,
      location: fields[3] as String,
      creditDuration: fields[4] as int,
      zone: fields[5] as String,
      lastInvoiceDate: fields[6] as DateTime,
      inputDate: fields[7] as DateTime,
      status: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.organizationName)
      ..writeByte(1)
      ..write(obj.personInCharge)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.creditDuration)
      ..writeByte(5)
      ..write(obj.zone)
      ..writeByte(6)
      ..write(obj.lastInvoiceDate)
      ..writeByte(7)
      ..write(obj.inputDate)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
