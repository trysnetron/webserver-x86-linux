
; System calls
%define sys_write   1
%define sys_close   3
%define sys_socket 41
%define sys_accept 43
%define sys_bind   49
%define sys_listen 50
%define sys_exit   60

; Constants
%define STDOUT 1
%define AF_INET 2
%define SOCK_STREAM 1

; Static data section
section .rodata

startup_msg:     db "Listening on 127.0.0.1:8001", 10
startup_msg_len: equ $ - startup_msg

http_response:  db "HTTP/1.1 200 OK", 13, 10, \
                "Content-Length: 116", 13, 10, \
                13, 10, 13, 10, \
                "<!DOCTYPE html><html>", \
                  "<head><title>Wuhu</title></head>", \
                  "<body><h1>Very good</h1><p>Really very good</p></body>", \
                "</html>"
http_response_len: equ $ - http_response

; Socketaddress "struct"
sockaddr:
sockaddr_family:  dw AF_INET       ; IPv4 socket
sockaddr_port:    db 0x1f, 0x41    ; Port 8001 (0x1f41)
sockaddr_address: db 127, 0, 0, 1  ; Listen on loopbakc (localhost) address
sockaddr_padding: dq 0             ; 8 bytes padding, sockaddr data must be 16 bytes total
sockaddr_len:     equ $ - sockaddr

error_msg:     db "Something went wrong, exiting.", 10
error_msg_len: equ $ - error_msg

; Executable code section
section .text

global main ; main is entrypoint

main:
  ; Write (sys_write) to stdout
  mov rax, sys_write
  mov rdi, STDOUT
  mov rsi, startup_msg
  mov rdx, startup_msg_len
  syscall

  ; Create socket (sys_socket)
  mov rax, sys_socket
  mov rdi, AF_INET     ; domain AF_INET
  mov rsi, SOCK_STREAM ; type SOCK_STREAM (Transmission Control Protocol)
  mov rdx, 0           ; protocol, none
  syscall

  ; Move socket file descriptor to known location
  mov rbx, rax
  
  ; Bind socket to address (sys_bind)
  mov rax, sys_bind
  mov rdi, rbx
  mov rsi, sockaddr
  mov rdx, sockaddr_len
  syscall

  cmp rax, -4095
  jae error

  ; Listen for connections (sys_listen)
  mov rax, sys_listen
  mov rdi, rbx
  mov rsi, 10 ; Backlog (allow 10 connections to wait)
  syscall

wait_for_connection:

  ; Accept incomming connection (sys_accept)
  mov rax, sys_accept
  mov rdi, rbx
  mov rsi, 0
  mov rdx, 0
  syscall

  ; Store client socket
  mov rcx, rax

  ; Write HTTP response to client
  mov rax, sys_write
  mov rdi, rcx
  mov rsi, http_response
  mov rdx, http_response_len
  syscall

  ; Close client socket (sys_close)
  mov rax, sys_close
  mov rdi, rcx
  syscall

  jmp wait_for_connection

error:
  ; Print error message and exit
  mov rax, sys_write
  mov rdi, STDOUT
  mov rsi, error_msg
  mov rdx, error_msg_len
  syscall

  mov rax, sys_exit
  mov rdi, 1
  syscall
