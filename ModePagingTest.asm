;
; ModePagingTest.asm
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

	call clear

	 ; print CR3 label

	lea eax, [text_CR3]
	push eax
	call print
	add esp, 4

	 ; print CR3 Register value

	mov eax, cr3

	push eax
	call int_to_string
	add esp, 4

	lea eax, [buffer_to_string]
	push eax
	call print
	add esp, 4

	call new_line

	 ; print CR0 label

	lea eax, [text_CR0]
	push eax
	call print
	add esp, 4

	 ; print CR0 Register value

	mov eax, cr0

	push eax
	call int_to_string
	add esp, 4

	lea eax, [buffer_to_string]
	push eax
	call print
	add esp, 4

	call new_line

	 ; check mode

	mov eax, cr0
	bt eax, 0

	jc protected_mode

	 ; real_mode

	lea eax, [text_RM]
	push eax
	call print
	add esp, 4

	call new_line

inf_loop:
	nop
	jmp inf_loop				; infinite loop

success:
	mov eax, EFI_SUCCESS

	pop ebp
	retn

protected_mode:
	lea eax, [text_PM]
	push eax
	call print
	add esp, 4

	call new_line

	mov eax, cr0
	bt eax, 31
	
	jc paging_on

	lea eax, [text_no_paging]
	jmp print_paging

paging_on:
	lea eax, [text_paging]

print_paging:
	push eax
	call print
	add esp, 4

	call new_line

	jmp inf_loop

error:
	mov eax, 1
	pop ebp
	retn

section '.data' data readable writeable

ImageHandle		dd		?
SystemTable		dd		?

text_CR3		du		'CR3: ',0
text_CR0		du		'CR0: ',0
text_PM			du		'Protected Mode',0
text_RM			du		'Real Mode',0
text_paging		du		'Paging Enabled',0
text_no_paging		du		'Paging Disabled',0
text_new_line		du		13,10,0

buffer			du		0
buffer_to_string	du		0,0,0,0,0,0,0,0,0,0,0,0,0

section '.reloc' fixups data discardable
