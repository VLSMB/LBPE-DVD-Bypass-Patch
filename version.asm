	.386
	.model flat,stdcall
	option casemap:none
include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include iphlpapi.inc
includelib iphlpapi.lib
include shlwapi.inc
includelib Shlwapi.lib

FUNC_COUNT EQU 17

	.data
versionModule dd 0
funcAddr dd FUNC_COUNT dup(0)

	.data?
pathBuffer db 300 dup(?)
wow64Flag dd 0

	.const
PROGRESS_NAME db "REALLIVE.EXE", 0
MEG_TITLE db "LBPE DVD Bypass Patch", 0
WARNING_MSG db "This DVD validation bypass patch is provided solely for learning and research purposes. Commercial use is strictly prohibited, and it must be removed from your system within 24 hours after download.", 0
ERROR_MSG db "Bypass DVD Patch Init Error", 0
kernelbase db "kernelbase.dll", 0
iphlpapi db "iphlpapi.dll", 0
getVersionExA db "GetVersionExA", 0
getAdaptersInfo db "GetAdaptersInfo", 0

strGetFileVersionInfoA db "GetFileVersionInfoA", 0
strGetFileVersionInfoByHandle db "GetFileVersionInfoByHandle", 0
strGetFileVersionInfoExA db "GetFileVersionInfoExA", 0
strGetFileVersionInfoExW db "GetFileVersionInfoExW", 0
strGetFileVersionInfoSizeA db "GetFileVersionInfoSizeA", 0
strGetFileVersionInfoSizeExA db "GetFileVersionInfoSizeExA", 0
strGetFileVersionInfoSizeExW db "GetFileVersionInfoSizeExW", 0
strGetFileVersionInfoSizeW db "GetFileVersionInfoSizeW", 0
strGetFileVersionInfoW db "GetFileVersionInfoW", 0
strVerFindFileA db "VerFindFileA", 0
strVerFindFileW db "VerFindFileW", 0
strVerInstallFileA db "VerInstallFileA", 0
strVerInstallFileW db "VerInstallFileW", 0
strVerLanguageNameA db "VerLanguageNameA", 0
strVerLanguageNameW db "VerLanguageNameW", 0
strVerQueryValueA db "VerQueryValueA", 0
strVerQueryValueW db "VerQueryValueW", 0
funcName dd offset strGetFileVersionInfoA
	dd offset strGetFileVersionInfoByHandle
	dd offset strGetFileVersionInfoExA
	dd offset strGetFileVersionInfoExW
	dd offset strGetFileVersionInfoSizeA
	dd offset strGetFileVersionInfoSizeExA
	dd offset strGetFileVersionInfoSizeExW
	dd offset strGetFileVersionInfoSizeW
	dd offset strGetFileVersionInfoW
	dd offset strVerFindFileA
	dd offset strVerFindFileW
	dd offset strVerInstallFileA
	dd offset strVerInstallFileW
	dd offset strVerLanguageNameA
	dd offset strVerLanguageNameW
	dd offset strVerQueryValueA
	dd offset strVerQueryValueW

	.code
DllEntry proc _hInstance, _dwReason, _dwReserved
	mov eax, _dwReason
	cmp eax, 1
	je __entry_init
	cmp eax, 0
	je __entry_free
__entry_init:
	pushad
	mov eax, _hInstance
	push eax
	call DisableThreadLibraryCalls
	call DllInit
	call HookInit
	popad
	jmp __entry_ret
__entry_free:
	call DllFree
__entry_ret:
	mov eax, 1
	ret
DllEntry endp

HookInit proc
	push ebp
	mov ebp, esp

	push 260
	push offset pathBuffer
	push 0
	call GetModuleFileNameA
	push offset pathBuffer
	call PathStripPathA
	push offset PROGRESS_NAME
	push offset pathBuffer
	call lstrcmpiA
	test eax, eax
	jne __hook_init_ret

	push offset wow64Flag
	call GetCurrentProcess
	push eax
	call IsWow64Process

	push 48
	push offset MEG_TITLE
	push offset WARNING_MSG
	push 0
	call MessageBoxA

	push offset getVersionExA
	push offset kernelbase
	call GetApiAddress
	push ProxyGetVersionExA
	push eax
	call WriteHook

	push offset getAdaptersInfo
	push offset iphlpapi
	call GetApiAddress
	push ProxyGetAdaptersInfo
	push eax
	call WriteHook
__hook_init_ret:
	leave
	ret
HookInit endp

DllInit proc
	push ebp
	mov ebp, esp
	sub esp, 4

	push 260
	push offset pathBuffer
	call GetSystemDirectoryA
	lea esi, pathBuffer
	dec esi
__get_str_end:
	inc esi
	movzx eax, byte ptr [esi]
	test al, al
	jne __get_str_end
	mov dword ptr [esi], 'rev\'
	mov dword ptr [esi+4], 'nois'
	mov dword ptr [esi+8], 'lld.'
	mov byte ptr [esi+12], 0
	push offset pathBuffer
	call LoadLibraryA
	test eax, eax
	je LogError
	mov [versionModule], eax

	mov dword ptr [ebp-4], 0
__init_proxy:
	mov ecx, [ebp-4]
	cmp ecx, FUNC_COUNT
	jnb __init_proxy_end
	mov edx, ecx
	shl edx, 2

	lea esi, funcName
	mov eax, [esi+edx]
	push eax
	mov eax, [versionModule]
	push eax
	call GetFuncAddress
	lea esi, funcAddr
	mov ecx, [ebp-4]
	mov edx, ecx
	shl edx, 2
	mov [esi+edx], eax

	inc ecx
	mov [ebp-4], ecx
	jmp __init_proxy
__init_proxy_end:
	leave
	ret
DllInit endp

DllFree proc
	ret
DllFree endp

GetFuncAddress proc
	push ebp
	mov ebp, esp

	mov eax, [ebp+12]
	push eax
	mov eax, [ebp+8]
	push eax
	call GetProcAddress

	leave
	ret 8
GetFuncAddress endp

GetApiAddress proc
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	push eax
	call GetModuleHandleA
	test eax, eax
	je LogError

	push ebx
	mov ebx, [ebp+12]
	push ebx
	push eax
	call GetFuncAddress
	pop ebx
	test eax, eax
	je LogError

	leave
	ret 8
GetApiAddress endp

WriteHook proc
	push ebp
	mov ebp, esp
	sub esp, 13

	xor eax, eax
	mov [ebp-4], eax
	mov [ebp-8], eax
	mov byte ptr [ebp-13], 0E9H
	mov eax, [ebp+12]
	mov [ebp-12], eax
	mov eax, [ebp+8]
	add eax, 5
	sub [ebp-12], eax

	lea eax, [ebp-4]
	push eax
	push 40H
	push 5
	mov eax, [ebp+8]
	push eax
	call VirtualProtect

	push 5
	lea eax, [ebp-13]
	push eax
	mov eax, [ebp+8]
	push eax
	call MemoryCopy

	lea eax, [ebp-8]
	push eax
	mov eax, [ebp-4]
	push eax
	push 5
	mov eax, [ebp+8]
	push eax
	call VirtualProtect

	push 5
	mov eax, [ebp+8]
	push eax
	call GetCurrentProcess
	push eax
	call FlushInstructionCache

	xor eax, eax
	leave
	ret 8
WriteHook endp

LogError proc
	push 16
	push offset MEG_TITLE
	push offset ERROR_MSG
	push 0
	call MessageBoxA
	push 1
	call ExitProcess
LogError endp

MemoryCopy proc
    push ebp
    mov ebp, esp
    
    mov edi, [ebp+8]
    mov esi, [ebp+12]
    mov ecx, [ebp+16]
    cld
    rep movsb
    
    leave
    ret 12
MemoryCopy endp

ProxyGetVersionExA proc
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	mov dword ptr [eax], 148
	mov dword ptr [eax+4], 6
	mov dword ptr [eax+8], 2
	mov dword ptr [eax+12], 9200
	mov dword ptr [eax+16], 2

	pushad
	lea edi, [eax+20]
	mov ecx, 32
	xor eax, eax
	cld
	rep stosd
	popad

	mov eax, 1
	leave
	ret 4
ProxyGetVersionExA endp
	
ProxyGetAdaptersInfo proc
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	test eax, eax
	je __proxy_adapter_size_ret
	mov eax, [ebp+12]
	test eax, eax
	je __proxy_adapter_size_ret
	mov eax, [eax]
	cmp eax, 648
	jb __proxy_adapter_size_ret
	mov eax, [ebp+12]
	mov dword ptr [eax], 648

	pushad
	mov edi, [ebp+8]
	mov ecx, 162
	xor eax, eax
	cld
	rep stosd
	popad

	mov eax, [ebp+8]
	lea eax, [eax+8]
	mov dword ptr [eax], 'kcoM'
	mov dword ptr [eax+4], 'adA-'
	mov dword ptr [eax+8], 'retp'

	mov eax, [wow64Flag]
	test eax, eax
	je __proxy_adapter_32_begin

	mov eax, [ebp+8]
	lea eax, [eax+404]
	mov dword ptr [eax], 3C2B1A02H
	mov word ptr [eax+4], 5E4DH
	jmp __proxy_adapter_32_end

__proxy_adapter_32_begin:
	mov eax, [ebp+8]
	lea eax, [eax+404]
	mov dword ptr [eax], 3C2B0002H
	mov word ptr [eax+4], 0DC4DH

__proxy_adapter_32_end:
	mov eax, [ebp+8]
	mov dword ptr [eax+400], 6

	xor eax, eax
	jmp __proxy_adapter_ret
__proxy_adapter_size_ret:
	mov eax, [ebp+12]
	mov dword ptr [eax], 648
	mov eax, 111
__proxy_adapter_ret:
	leave
	ret 8
ProxyGetAdaptersInfo endp

DummyFuncForLoadDll proc
	push esi
	dec esp
	push ebx
	dec ebp
	inc edx
	call GetVersionExA
	call GetAdaptersInfo
	dec esi
	dec edi
	dec esi
	sub eax, 4D4D4F43H
	inc ebp
	push edx
	inc ebx
	dec ecx
	inc ecx
	dec esp
	and byte ptr ds:[edi+4EH], cl
	dec esp
	pop ecx
DummyFuncForLoadDll endp

; EXPORTS
pGetFileVersionInfoA proc
    jmp dword ptr [funcAddr + 0*4]
pGetFileVersionInfoA endp

pGetFileVersionInfoByHandle proc
    jmp dword ptr [funcAddr + 1*4]
pGetFileVersionInfoByHandle endp

pGetFileVersionInfoExA proc
    jmp dword ptr [funcAddr + 2*4]
pGetFileVersionInfoExA endp

pGetFileVersionInfoExW proc
    jmp dword ptr [funcAddr + 3*4]
pGetFileVersionInfoExW endp

pGetFileVersionInfoSizeA proc
    jmp dword ptr [funcAddr + 4*4]
pGetFileVersionInfoSizeA endp

pGetFileVersionInfoSizeExA proc
    jmp dword ptr [funcAddr + 5*4]
pGetFileVersionInfoSizeExA endp

pGetFileVersionInfoSizeExW proc
    jmp dword ptr [funcAddr + 6*4]
pGetFileVersionInfoSizeExW endp

pGetFileVersionInfoSizeW proc
    jmp dword ptr [funcAddr + 7*4]
pGetFileVersionInfoSizeW endp

pGetFileVersionInfoW proc
    jmp dword ptr [funcAddr + 8*4]
pGetFileVersionInfoW endp

pVerFindFileA proc
    jmp dword ptr [funcAddr + 9*4]
pVerFindFileA endp

pVerFindFileW proc
    jmp dword ptr [funcAddr + 10*4]
pVerFindFileW endp

pVerInstallFileA proc
    jmp dword ptr [funcAddr + 11*4]
pVerInstallFileA endp

pVerInstallFileW proc
    jmp dword ptr [funcAddr + 12*4]
pVerInstallFileW endp

pVerLanguageNameA proc
    jmp dword ptr [funcAddr + 13*4]
pVerLanguageNameA endp

pVerLanguageNameW proc
    jmp dword ptr [funcAddr + 14*4]
pVerLanguageNameW endp

pVerQueryValueA proc
    jmp dword ptr [funcAddr + 15*4]
pVerQueryValueA endp

pVerQueryValueW proc
    jmp dword ptr [funcAddr + 16*4]
pVerQueryValueW endp

end DllEntry
