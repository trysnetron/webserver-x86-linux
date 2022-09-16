global main

section .rodata
  msg: db "Hello, world!", 10
  msg_len: equ $ - msg
  
  response: db "HTTP/1.1 200 OK", 13, 10, \
               "Content-Length: 116", 13, 10, \
               13, 10, 13, 10, \
               "<!DOCTYPE html><html><head><title>Wuhu</title></head><body><h1>Very good</h1><p>Really very good</p></body></html>"
  response_len: equ $ - response

  ; sockaddr: db 0x41, 0x1f, 0, 2, 1, 0, 0, 0x7f, 0, 0, 0, 0, 0, 0, 0, 0
  sockaddr: db 2, 0, 0x1f, 0x41, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
  sockaddr_len: equ $ - sockaddr

section .text

main:
  ; Write (sys_write) to stdout
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, msg_len
  syscall

  ; Create socket (sys_socket)
  mov rax, 41
  mov rdi, 2 ; domain AF_INET
  mov rsi, 1 ; type SOCK_STREAM (Transmission Control Protocol)
  mov rdx, 0 ; protocol, none
  syscall

  ; Move socket file descriptor to known location
  mov rbx, rax
  
  ; Bind socket to address (sys_bind)
  mov rax, 49
  mov rdi, rbx
  mov rsi, sockaddr
  mov rdx, sockaddr_len
  syscall

  ; Listen for connections (sys_listen)
  mov rax, 50
  mov rdi, rbx
  mov rsi, 1000 ; Backlog (allow 10 connections to wait)
  syscall

listen:

  ; Accept incomming connection (sys_accept)
  mov rax, 43
  mov rdi, rbx
  mov rsi, 0
  mov rdx, 0
  syscall

  ; Store client socket
  mov rcx, rax

  ; Write HTTP response to client
  mov rax, 1
  mov rdi, rcx
  mov rsi, response
  mov rdx, response_len
  syscall

  ; Close client socket (sys_close)
  mov rax, 3
  mov rdi, rcx
  syscall

  jmp listen

  ; Exit (sys_exit)
  mov rax, 60
  mov rdi, 0
  syscall
