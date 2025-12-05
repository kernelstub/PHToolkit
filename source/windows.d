module windows;

extern (C):

enum {
    create_suspended = 0x00000004,
    context_full = 0x00010007
}

alias HANDLE = void*;
alias LPVOID = void*;
alias LPCSTR = const(char)*;
alias LPSTR = char*;
alias DWORD = uint;
alias SIZE_T = size_t;
alias UINT = uint;
alias BOOL = int;
alias WORD = ushort;

struct StartupInfo {
    DWORD cb;
    LPSTR lp_reserved;
    LPSTR lp_desktop;
    LPSTR lp_title;
    DWORD dw_x;
    DWORD dw_y;
    DWORD dw_x_size;
    DWORD dw_y_size;
    DWORD dw_x_count_chars;
    DWORD dw_y_count_chars;
    DWORD dw_fill_attribute;
    DWORD dw_flags;
    WORD w_show_window;
    WORD cb_reserved2;
    LPVOID lp_reserved2;
    HANDLE h_std_input;
    HANDLE h_std_output;
    HANDLE h_std_error;
}

struct ProcessInformation {
    HANDLE h_process;
    HANDLE h_thread;
    DWORD dw_process_id;
    DWORD dw_thread_id;
}

struct Context {
    DWORD context_flags;
    DWORD dr0;
    DWORD dr1;
    DWORD dr2;
    DWORD dr3;
    DWORD dr6;
    DWORD dr7;
    DWORD control_word;
    DWORD status_word;
    DWORD tag_word;
    DWORD error_offset;
    DWORD error_selector;
    DWORD data_offset;
    DWORD data_selector;
    DWORD cr0_npx_state;
    DWORD eax;
    DWORD ebx;
    DWORD ecx;
    DWORD edx;
    DWORD esi;
    DWORD edi;
    DWORD ebp;
    DWORD esp;
    DWORD eip;
    DWORD seg_cs;
    DWORD seg_ds;
    DWORD seg_es;
    DWORD seg_fs;
    DWORD seg_gs;
    DWORD seg_ss;
    DWORD extended_registers[512];
}

BOOL create_process_a(
    LPCSTR lp_application_name,
    LPSTR lp_command_line,
    void* lp_process_attributes,
    void* lp_thread_attributes,
    BOOL b_inherit_handles,
    DWORD dw_creation_flags,
    void* lp_environment,
    LPCSTR lp_current_directory,
    startup_info* lp_startup_info,
    process_information* lp_process_information
);

BOOL get_thread_context(
    HANDLE h_thread,
    context* lp_context
);

BOOL set_thread_context(
    HANDLE h_thread,
    context* lp_context
);

BOOL read_process_memory(
    HANDLE h_process,
    LPVOID lp_base_address,
    LPVOID lp_buffer,
    SIZE_T n_size,
    SIZE_T* lp_number_of_bytes_read
);

BOOL write_process_memory(
    HANDLE h_process,
    LPVOID lp_base_address,
    LPVOID lp_buffer,
    SIZE_T n_size,
    SIZE_T* lp_number_of_bytes_written
);

DWORD resume_thread(
    HANDLE h_thread
);

DWORD get_last_error();

BOOL terminate_process(
    HANDLE h_process,
    UINT u_exit_code
);

BOOL close_handle(HANDLE h_object);
