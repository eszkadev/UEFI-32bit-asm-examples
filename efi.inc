;
; EFI.inc
; Based on: http://wiki.osdev.org/Uefi.inc
; 2015 Szymon Kłos
;

struc int8 {
  . db ?
}

struc int16 {
  align 2
  . dw ?
}

struc int32 {
  align 4
  . dd ?
}

struc int64 {
  align 8
  . dq ?
}

struc intn {
  align 4
  . dd ?
}

struc dptr {
  align 4
  . dd ?
}

 ; symbols

EFI_SUCCESS			equ	0

EFI_SYSTEM_TABLE_SIGNATURE	equ	20494249h
EFI_SYSTEM_TABLE_SIGNATURE2	equ	54535953h

 ; helper macro for definition of relative structure member offsets

macro struct name
{
  virtual at 0
    name name
  end virtual
}

 ; structures

struc EFI_TABLE_HEADER {
 .Signature    int64
 .Revision     int32
 .HeaderSize   int32
 .CRC32        int32
 .Reserved     int32
}
struct EFI_TABLE_HEADER

struc EFI_SYSTEM_TABLE {
 .Hdr		       EFI_TABLE_HEADER
 .FirmwareVendor       dptr
 .FirmwareRevision     int32
 .ConsoleInHandle      dptr
 .ConIn 	       dptr
 .ConsoleOutHandle     dptr
 .ConOut	       dptr
 .StandardErrorHandle  dptr
 .StdErr	       dptr
 .RuntimeServices      dptr
 .BootServices	       dptr
 .NumberOfTableEntries intn
 .ConfigurationTable   dptr
}
struct EFI_SYSTEM_TABLE

struc SIMPLE_TEXT_OUTPUT_INTERFACE {
 .Reset 	    dptr
 .OutputString	    dptr
 .TestString	    dptr
 .QueryMode	    dptr
 .SetMode	    dptr
 .SetAttribute	    dptr
 .ClearScreen	    dptr
 .SetCursorPosition dptr
 .EnableCursor	    dptr
 .Mode		    dptr
}
struct SIMPLE_TEXT_OUTPUT_INTERFACE
