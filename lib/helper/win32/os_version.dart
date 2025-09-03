import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

bool isWindows11() {
  if (!Platform.isWindows) {
    return false;
  }
  final versionInfo = calloc<OSVERSIONINFO>(); // 使用 calloc 分配内存
  versionInfo.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

  try {
    if (GetVersionEx(versionInfo) != 0) {
      final major = versionInfo.ref.dwMajorVersion; // 通过 ref 访问结构体字段
      final build = versionInfo.ref.dwBuildNumber;

      return major == 10 && build >= 22000;
    }
  } finally {
    calloc.free(versionInfo); // 释放分配的内存
  }
  return false;
}

String getWindowsVersion() {
  final versionInfo = calloc<OSVERSIONINFO>(); // 使用 calloc 分配内存
  versionInfo.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

  try {
    if (GetVersionEx(versionInfo) != 0) {
      final major = versionInfo.ref.dwMajorVersion; // 通过 ref 访问结构体字段
      final build = versionInfo.ref.dwBuildNumber;

      if (major == 10 && build >= 22000) {
        return 'Windows 11';
      } else if (major == 10) {
        return 'Windows 10';
      }
    }
    return 'Unknown Windows';
  } finally {
    calloc.free(versionInfo); // 释放分配的内存
  }
}
