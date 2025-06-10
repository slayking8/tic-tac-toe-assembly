global _start

%define READ 0
%define WRITE 1
%define STDIN 0
%define STDOUT 1
%define NUM_SIZE 256
%define BASE 10
%define COL_NUM 13
%define SYMBOL_SIZE 2
%define CHOICES 9
%define TRUE 1
%define FALSE 0


section .data
    newline db 0x0A
    newline_size equ $ - newline

    dash db '-'
    dash_size equ $ - dash
    pipe db '|'
    pipe_size equ $ - pipe
    space db ' '
    space_size equ $ - space
    x_sym db 'X'
    o_sym db 'O'
    sym db 'X'
    sym_size equ $ - sym
    time_msg db "  (1 - 9): "
    time_msg_size equ $ - time_msg
    invalid_entry_msg db "Invalid entry. Try again!!!"
    invalid_entry_msg_size equ $ - invalid_entry_msg
    used_cell_msg db "Cell used. Choose another!!!"
    used_cell_msg_size equ $ - used_cell_msg
    choices db "123456789"
    choices_size equ $ - choices
    winning_msg db " won!"
    winning_msg_size equ $ - winning_msg


section .bss
    num resb NUM_SIZE
    choice resb SYMBOL_SIZE


section .text
_start:
    call _run
    jmp _exit

_run:
    call _board_printer
    call _newline

    call .check_winner

    call .has_free_cell
    cmp rax, FALSE
    je .end

    call _read_symbol
    jmp _run

.end:
    ret

.end_game:
    mov bl, [o_sym]
    cmp [sym], bl
    je .swap_sym_x
    jne .swap_sym_o

.continue_end_game:
    mov rsi, sym
    mov rdi, sym_size
    call _print

    mov rsi, winning_msg
    mov rdi, winning_msg_size
    call _print
    call _newline
    jmp _exit

.swap_sym_x:
    mov bl, [x_sym]
    mov [sym], bl
    jmp .continue_end_game

.swap_sym_o:
    mov bl, [o_sym]
    mov [sym], bl
    jmp .continue_end_game

.check_winner:
    call .check_all_zero_index_matches
    call .check_all_second_index_matches
    call .check_all_seventh_index_matches
    call .check_second_row_match
    ret


; FOURTH CELL CHECK
.check_second_row_match:
    mov bl, [choices + 4]
    cmp [choices + 3], bl
    je .check_third_row
    ret

.check_third_row:
    cmp [choices + 5], bl
    je .end_game
    ret

; FIRST CELL => CHECK HORIZONTALY, VERTICALLY AND DIAGONALLY
.check_all_zero_index_matches:
    mov bl, [choices + 1]
    cmp [choices], bl
    je .check_first_cell_horizontal

.zero_index_matches_continue_1:
    mov bl, [choices + 3]
    cmp [choices], bl
    je .check_first_cell_vertical

.zero_index_matches_continue_2:
    mov bl, [choices + 4]
    cmp [choices], bl
    je .check_first_cell_diagonal
    ret

.check_first_cell_horizontal:
    cmp [choices + 2], bl
    je .end_game
    jmp .zero_index_matches_continue_1
.check_first_cell_vertical:
    cmp [choices + 6], bl
    je .end_game
    jmp .zero_index_matches_continue_2
.check_first_cell_diagonal:
    cmp [choices + 8], bl
    je .end_game
    ret


; THIRD CELL => CHECK VERTICALLY AND DIAGONALLY
.check_all_second_index_matches:
    mov bl, [choices + 5]
    cmp [choices + 2], bl
    je .check_third_cell_vertical

.second_index_matches_continue_1:
    mov bl, [choices + 4]
    cmp [choices + 2], bl
    je .check_third_cell_diagonal

    ret

.check_third_cell_vertical:
    cmp [choices + 8], bl
    je .end_game
    jmp .second_index_matches_continue_1

.check_third_cell_diagonal:
    cmp [choices + 6], bl
    je .end_game
    ret

; EIGHTH CELL => CHECK VERTICALLY AND DIAGONALLY
.check_all_seventh_index_matches:
    mov bl, [choices + 6]
    cmp [choices + 7], bl
    je .check_eighth_cell_horizontal

.seventh_index_matches_continue_1:
    mov bl, [choices + 4]
    cmp [choices + 7], bl
    je .check_eighth_cell_vertical

    ret

.check_eighth_cell_horizontal:
    cmp [choices + 8], bl
    je .end_game
    jmp .seventh_index_matches_continue_1

.check_eighth_cell_vertical:
    cmp [choices + 1], bl
    je .end_game
    ret


.has_free_cell:
    mov rcx, -1
.keep_looking_for:
    inc rcx
    cmp rcx, 8
    jg .not_found

    mov bl, [o_sym]
    cmp [choices + rcx], bl
    je .keep_looking_for

    mov bl, [x_sym]
    cmp [choices + rcx], bl
    je .keep_looking_for

    mov rax, TRUE
    ret

.not_found:
    mov rax, FALSE
    ret


_board_printer:
    mov rcx, 3
    mov r12, 0
.dashes_pipes_pair:
    push rcx
    call .dashes_row_printer 
    call _newline
    call .pipes_row_printer
    call _newline
    
    pop rcx
    loop .dashes_pipes_pair
    call .dashes_row_printer 
    call _newline
    ret


.pipes_row_printer:
    mov r10, 0
.pr_one_of_the_three:
    inc r10
    cmp r10, COL_NUM
    jg .end

    mov rax, 3
    call .calc_pipe_or_sym
    je .pr_pipe

    mov rax, 1
    call .calc_pipe_or_sym
    je .pr_sym

    mov rsi, space
    mov rdi, space_size
    call _print
    jmp .pr_one_of_the_three
.end:
    ret


.calc_pipe_or_sym:
    add rax, r10
    mov rbx, 4
    xor rdx, rdx
    div rbx

    cmp rdx, 0
    ret


.pr_pipe:
    mov rsi, pipe
    mov rdi, pipe_size
    call _print
    jmp .pr_one_of_the_three


.pr_sym:
    lea rsi, [choices + r12]
    mov rdi, sym_size
    call _print
    inc r12
    jmp .pr_one_of_the_three


.dashes_row_printer:
    mov rcx, COL_NUM
.pr_dash:
    push rcx
    mov rsi, dash
    mov rdi, dash_size
    call _print
    pop rcx

    loop .pr_dash
    ret

_read_symbol:
    mov bl, [sym]
    mov byte [time_msg], bl
    mov rsi, time_msg
    mov rdi, time_msg_size
    call _print    

    call .read_choice

    cmp r10, SYMBOL_SIZE
    jge .invalid_entry
    cmp byte [choice], '0'
    jle .invalid_entry
    cmp byte [choice], '9'
    jg .invalid_entry

    mov al, [choice]
    sub al, '0'
    dec al

    mov bl, [o_sym]
    cmp [choices + rax], bl
    je .cell_is_used

    mov bl, [x_sym]
    cmp [choices + rax], bl
    je .cell_is_used

    mov bl, [sym]
    mov [choices + rax], bl

    mov bl, [o_sym]
    cmp [sym], bl
    je .set_x_sym
    jne .set_o_sym


.read_choice:
    mov r10, 0
.keep_reading:
    mov rax, READ
    mov rdi, STDIN
    mov rsi, choice
    mov rdx, SYMBOL_SIZE
    syscall

    inc r10
    cmp byte [rsi + rax - 1], 0x0A
    jne .keep_reading
    ret

.set_o_sym:
    mov bh, [o_sym]
    mov [sym], bh
    ret
.set_x_sym:
    mov bh, [x_sym]
    mov [sym], bh
    ret

.cell_is_used:
    mov rsi, used_cell_msg
    mov rdi, used_cell_msg_size
    call _print
    call _newline
    call _newline
    
    pop rbx
    jmp _run

.invalid_entry:
    mov rsi, invalid_entry_msg
    mov rdi, invalid_entry_msg_size
    call _print
    call _newline
    call _newline

    pop rbx
    jmp _run


_print:
    push rdi

    mov rax, WRITE
    mov rdi, STDOUT
    pop rdx
    syscall
    ret

_newline:
    mov rsi, newline
    mov rdi, newline_size
    call _print
    ret

_exit:
    mov rax, 60
    mov rdi, 8
    syscall
