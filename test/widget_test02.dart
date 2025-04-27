// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.
//
// import 'dart:ffi';
//
// import 'package:ffi/ffi.dart';
// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:win32/win32.dart';
//
// // 添加以下Win32 API绑定
// final _kernel32 = DynamicLibrary.open('kernel32.dll');
//
//
// typedef DeviceIoControlNative = Int32 Function(
//     IntPtr hDevice,
//     Uint32 dwIoControlCode,
//     Pointer<NativeType> lpInBuffer,
//     Uint32 nInBufferSize,
//     Pointer<NativeType> lpOutBuffer,
//     Uint32 nOutBufferSize,
//     Pointer<Uint32> lpBytesReturned,
//     Pointer<NativeType> lpOverlapped,
//     );
//
// typedef CreateFileANative = IntPtr Function(
//     Pointer<Utf8> lpFileName,
//     Uint32 dwDesiredAccess,
//     Uint32 dwShareMode,
//     Pointer<NativeType> lpSecurityAttributes,
//     Uint32 dwCreationDisposition,
//     Uint32 dwFlagsAndAttributes,
//     IntPtr hTemplateFile,
//     );
//
// // 添加存储设备相关常量
// const STORAGE_PROPERTY_ID = 0;
// const IOCTL_STORAGE_QUERY_PROPERTY = 0x002D1400;
//
// // 修改函数绑定部分
// final _CreateFile = _kernel32.lookupFunction<CreateFileANative, CreateFileANative>('CreateFileA');
// final _DeviceIoControl = _kernel32.lookupFunction<DeviceIoControlNative, DeviceIoControlNative>('DeviceIoControl');
//
//
// final class STORAGE_PROPERTY_QUERY extends Struct {
//   @Uint32()
//   external int PropertyId;
//
//   @Uint32()
//   external int QueryType;
// }
//
// void main() {
//   test('ssh', () async {
//     debugPrint('hello');
//   });
//
//   test('getDeviceNumber', () async {
//     final allocator = calloc;
//     final deviceName = '\\\\.\\PhysicalDrive0'.toNativeUtf8();
//
//     final hDevice = _CreateFile(
//       deviceName,
//       0, // GENERIC_READ
//       1, // FILE_SHARE_READ
//       nullptr,
//       3, // OPEN_EXISTING
//       0,
//       nullptr,
//     );
//
//     if (hDevice == -1) throw Exception('无法打开设备');
//
//     try {
//       final query = allocator<STORAGE_PROPERTY_QUERY>();
//       query.ref
//         ..PropertyId = STORAGE_PROPERTY_ID
//         ..QueryType = 0; // PropertyStandardQuery
//
//       final outBuffer = allocator<Uint8>(1024);
//
//       final bytesReturned = allocator<Uint32>();
//       final success = _DeviceIoControl(
//         hDevice,
//         IOCTL_STORAGE_QUERY_PROPERTY,
//         query.cast(),
//         sizeOf<STORAGE_PROPERTY_QUERY>(),
//         outBuffer.cast(),
//         1024,
//         bytesReturned,
//         nullptr,
//       );
//
//       if (success != 1) throw Exception('设备查询失败');
//
//       final descriptor = outBuffer.cast<STORAGE_DEVICE_DESCRIPTOR>();
//       final serialOffset = descriptor.ref.SerialNumberOffset;
//       if (serialOffset == 0) throw Exception('未找到序列号');
//
//       final serialPtr = outBuffer.elementAt(serialOffset).cast<Utf8>();
//       return serialPtr.toDartString();
//     } finally {
//       CloseHandle(hDevice);
//       allocator.free(deviceName);
//     }
//   });
// }
