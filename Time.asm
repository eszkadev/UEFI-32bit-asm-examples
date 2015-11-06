;
; BOOTIA32.asm
; 2015 Szymon Kłos
;

format pe dll efi
entry main

section '.text' code executable readable

include 'efi.inc'

 ; print args: STRING

print:
	mov eax, EFI_SYSTEM_TABLE.ConOut
	mov ecx, [SystemTable]
	add ecx, eax
	mov ecx, [ecx]

	mov edx, ecx
	mov eax, SIMPLE_TEXT_OUTPUT_INTERFACE.OutputString
	add edx, eax

	mov eax, [esp+4]			; [arg] text - currently on stack
	push eax
	push ecx				; [arg] SystemTable.ConOut

	mov edx, [edx]
	call edx
	add esp, 8

	ret

 ; new_line args: no args

new_line:
	lea eax, [text_new_line]
	push eax				; [arg] text
	call print
	add esp, 4
	ret

 ; int_to_string args: INT32
 ; returns: STRING in buffer_to_string

int_to_string:
	mov eax, [esp+4]
	push ebx
	push esi

	mov ebp, 10
	xor edx, edx
	mov ecx, 0
	mov esi, 0
	lea ebx, [buffer_to_string]

	loop_its:
		div ebp
		add dl, 48
		push edx
		xor edx, edx
		inc esi
		cmp eax, 0
		jnz loop_its

	loop_its_2:
		pop edx
		mov [ebx+ecx], dl
		add ecx, 2
		xor edx, edx
		dec esi
		cmp esi, 0
		jnz loop_its_2

	mov dl, 0
	mov [ebx+ecx], dl

	pop esi
	pop ebx
	ret

 ; clear args: no args

clear:
	mov eax, EFI_SYSTEM_TABLE.ConOut
	mov ecx, [SystemTable]
	add ecx, eax
	mov ecx, [ecx]

	mov edx, ecx
	mov eax, SIMPLE_TEXT_OUTPUT_INTERFACE.ClearScreen
	add edx, eax

	push ecx				; [arg] SystemTable.ConOut

	mov edx, [edx]
	call edx
	add esp, 4

	ret

main:
	push ebp
	mov ebp, esp

 ; get args ( ImageHandle and SystemTable pointer )

	mov ecx, [ebp+8]
	mov [ImageHandle], ecx
	mov edx, [ebp+12]
	mov [SystemTable], edx

 ; checking the signature

	mov eax, EFI_SYSTEM_TABLE.Hdr
	add edx, eax

	mov eax, EFI_TABLE_HEADER.Signature
	add edx, eax
	mov ecx, [edx]

	mov eax, EFI_SYSTEM_TABLE_SIGNATURE
	cmp eax, ecx
	jne error

	mov ecx, [edx + 4]
	mov eax, EFI_SYSTEM_TABLE_SIGNATURE2
	cmp eax, ecx
	jne error

 ; signature OK
 ; checking EFI_RUNTOME_SERVICES signature

	mov eax, EFI_SYSTEM_TABLE.RuntimeServices
	mov edx, [SystemTable]
	add edx, eax
	mov edx, [edx]

	mov eax, EFI_RUNTIME_SERVICES.Hdr
	add edx, eax

	mov eax, EFI_TABLE_HEADER.Signature
	add edx, eax
	mov ecx, [edx]

	mov eax, EFI_RUNTIME_SERVICES_SIGNATURE
	cmp eax, ecx
	jne error

	mov ecx, [edx + 4]
	mov eax, EFI_RUNTIME_SERVICES_SIGNATURE2
	cmp eax, ecx
	jne error

 ; signature OK

inf_loop:

	call clear

	 ; get time

	mov eax, EFI_SYSTEM_TABLE.RuntimeServices
	mov edx, [SystemTable]
	add edx, eax
	mov edx, [edx]

	mov eax, EFI_RUNTIME_SERVICES.GetTime
	add edx, eax
	mov edx, [edx]

	mov eax, 0
	push eax
	lea eax, [time]
	push eax

	call edx

	add esp, 8

	 ; print time label

	lea eax, [text_time]
	push eax
	call print
	add esp, 4

	 ; print hours

	lea ecx, [time]
	mov edx, EFI_TIME.Hour
	add ecx, edx
	mov eax, 0
	mov al, [ecx]

	push eax
	call int_to_string
	add esp, 4

	lea eax, [buffer_to_string]
	push eax
	call print
	add esp, 4

	 ; print separator

	lea eax, [buffer]
	mov dl, ':'
	mov [eax], dl
	mov dl, 0
	mov [eax+2], dl
	push eax
	call print
	add esp, 4

	 ; print minutes

	lea ecx, [time]
	mov edx, EFI_TIME.Minute
	add ecx, edx
	mov eax, 0
	mov al, [ecx]

	push eax
	call int_to_string
	add esp, 4

	lea eax, [buffer_to_string]
	push eax
	call print
	add esp, 4

	 ; print separator

	lea eax, [buffer]
	mov dl, ':'
	mov [eax], dl
	mov dl, 0
	mov [eax+2], dl
	push eax
	call print
	add esp, 4

	 ; print seconds

	lea ecx, [time]
	mov edx, EFI_TIME.Second
	add ecx, edx
	mov eax, 0
	mov al, [ecx]

	push eax
	call int_to_string
	add esp, 4

	lea eax, [buffer_to_string]
	push eax
	call print
	add esp, 4

	call new_line

	jmp inf_loop				; infinite loop

success:
	mov eax, EFI_SUCCESS

	pop ebp
	retn

error:
	mov eax, 1
	pop ebp
	retn

section '.data' data readable writeable

ImageHandle		dd		?
SystemTable		dd		?

text_time		du		'Time: ',0
text_new_line		du		13,10,0

time			EFI_TIME
buffer			du		0
buffer_to_string	du		0,0,0,0,0,0,0,0,0,0,0,0,0

section '.reloc' fixups data discardable
