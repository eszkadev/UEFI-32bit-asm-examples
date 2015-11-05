;
; BOOTIA32.asm
; 2015 Szymon Kłos
;

format pe dll efi
entry main

section '.text' code executable readable

include 'efi.inc'

 ; print args: pointer to string

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

	call clear

	lea eax, [text]
	push eax				; [arg] text
	call print
	add esp, 4

	lea eax, [text2]
	push eax				; [arg] text
	call print
	add esp, 4

inf_loop:
	nop
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

text			du		'Hello World',13,10,0

section '.reloc' fixups data discardable
