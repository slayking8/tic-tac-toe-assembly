# Tic-Tac-Toe in Assembly

A terminal-based Tic-Tac-Toe game written entirely in x86-64 Assembly.

This project was developed as an exercise in low-level programming, focusing on direct system calls, memory manipulation, control flow, and manual game state management without relying on external libraries or high-level abstractions. 

## Features

* Two-player Tic-Tac-Toe
* Terminal rendering
* Direct Linux syscalls
* Win condition detection
* Draw detection
* Input validation
* Cell occupation validation
* Turn switching between players
* Manual board rendering logic

## Technical Highlights

The implementation includes:

* Direct usage of Linux syscalls (`read`, `write`, `exit`)
* Manual memory management through `.data` and `.bss`
* Branching and flow control using labels and jumps
* Board state management using raw byte arrays
* Win-state checking algorithms
* Register manipulation and stack usage

## Technologies

* x86-64 Assembly
* NASM
* Linux Syscalls

## Project Structure

```text id="utn0z7"
.
├── main.asm
└── README.md
```

## Building

Assemble the source:

```bash id="7h7m7v"
nasm -f elf64 main.asm -o main.o
```

Link the executable:

```bash id="66wnlq"
ld main.o -o tic-tac-toe
```

Run:

```bash id="kk39e3"
./tic-tac-toe
```

## Example

```text id="7w7j5y"
-------------
| 1 | 2 | 3 |
-------------
| 4 | 5 | 6 |
-------------
| 7 | 8 | 9 |
-------------
```

## Motivation

The goal of this project was to deepen understanding of:

* Low-level systems programming
* Computer architecture fundamentals
* Register operations
* Stack behavior
* Program execution flow
* Memory layout
* Manual state management
* System-level I/O

## Notes

This is an educational and experimental project intended to explore low-level software engineering concepts through Assembly programming.

## Author

SlayKing

GitHub: [slayking8](https://github.com/slayking8?utm_source=chatgpt.com)
