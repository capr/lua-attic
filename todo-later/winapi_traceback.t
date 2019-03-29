require_h('winapi.types', {[[
typedef struct _SYMBOL_INFO {
  ULONG   SizeOfStruct;
  ULONG   TypeIndex;
  ULONG64 Reserved[2];
  ULONG   Index;
  ULONG   Size;
  ULONG64 ModBase;
  ULONG   Flags;
  ULONG64 Value;
  ULONG64 Address;
  ULONG   Register;
  ULONG   Scope;
  ULONG   Tag;
  ULONG   NameLen;
  ULONG   MaxNameLen;
  CHAR    Name[1];
} SYMBOL_INFO, *PSYMBOL_INFO;

HANDLE GetCurrentProcess();
BOOL SymInitialize(
  HANDLE hProcess,
  PCSTR  UserSearchPath,
  BOOL   fInvadeProcess
);
USHORT CaptureStackBackTrace(
  ULONG  FramesToSkip,
  ULONG  FramesToCapture,
  PVOID  *BackTrace,
  PULONG BackTraceHash
);
BOOL SymFromAddr(
  HANDLE       hProcess,
  DWORD64      Address,
  PDWORD64     Displacement,
  PSYMBOL_INFO Symbol
);
]]})

--[[
terra traceback()
    result = "";
    unsigned int   i;
    void          *stack[HUGGLE_STACK];
    unsigned short frames;
    SYMBOL_INFO   *symbol;
    HANDLE         process;
    process = GetCurrentProcess();
    SymInitialize( process, NULL, TRUE );
    frames               = CaptureStackBackTrace( 0, HUGGLE_STACK, stack, NULL );
    symbol               = ( SYMBOL_INFO * )calloc( sizeof( SYMBOL_INFO ) + 256 * sizeof( char ), 1 );
    symbol->MaxNameLen   = 255;
    symbol->SizeOfStruct = sizeof( SYMBOL_INFO );
    for( i = 0; i < frames; i++ )
    {
        SymFromAddr( process, ( DWORD64 )( stack[ i ] ), 0, symbol );
        QString symbol_name = "unknown symbol";
        if (!QString(symbol->Name).isEmpty())
        symbol_name = QString(symbol->Name);
        result += QString(QString::number(frames - i - 1) + QString(" ") + symbol_name + QString(" 0x") +
                          QString::number(symbol->Address, 16) + QString("\n"));
    }
    free( symbol );
end
]]
