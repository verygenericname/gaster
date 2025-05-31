/* By Alfie, based on rmsigchks.py by Linus Henze */

.text
.align 2

.pool
.set payload_dest,                        0x7FFFFFF0
.set dfu_handle_bus_reset,                0x7FFFFFF1
.set dfu_handle_request,                  0x7FFFFFF2
.set payload_off,                         0x7FFFFFF3
.set payload_sz,                          0x7FFFFFF4
.set memcpy_addr,                         0x7FFFFFF5
.set gUSBSerialNumber,                    0x7FFFFFF6
.set usb_create_string_descriptor,        0x7FFFFFF7
.set usb_serial_number_string_descriptor, 0x7FFFFFF8
.set patch_addr,                          0x7FFFFFF9

.global _main
_main:
	stp x29, x30, [sp, #-0x10]!
	ldr x0, =payload_dest
	ldr x2, =dfu_handle_bus_reset
	str xzr, [x2]
	ldr x2, =dfu_handle_request
	add x1, x0, #0xC
	str x1, [x2]
	adr x1, _main
	ldr x2, =payload_off
	add x1, x1, x2
	ldr x2, =payload_sz
	ldr x3, =memcpy_addr
	blr x3
	ldr x0, =gUSBSerialNumber
_find_zero_loop:
	add x0, x0, #1
	ldrb w1, [x0]
	cbnz w1, _find_zero_loop
	adr x1, PWND_STR
	ldp x2, x3, [x1]
	stp x2, x3, [x0]
	ldr x0, =gUSBSerialNumber
	ldr x1, =usb_create_string_descriptor
	blr x1
	ldr x1, =usb_serial_number_string_descriptor
	strb w0, [x1]
	mov w0, #0xD2800000
	ldr x1, =patch_addr
	str w0, [x1]

	// nop
	mov w0, #0xd5030000
	movk w0, #0x201f

	// mov w1, 1
	mov w1, #0x52800000
	movk w1, #0x21

	// strb w1, [sp,#0xA7]
	mov w2, #0x39020000
	movk w2, #0x9fe1

	// First patch - 0x1000054e4
	mov x3, #0x54e4
	movk x3, #1, lsl #32
	str w0, [x3]

	// Second patch - 0x1000054b4
	sub x3, x3, #0x30
	stp w1, w2, [x3], #8

	movk w2, #0xa7e1
	stp w0, w2, [x3], #8

	movk w2, #0xabe1
	stp w2, w0, [x3], #8

	str w0, [x3], #4
	str w0, [x3], #4
	str w0, [x3]

	ldp x29, x30, [sp], #0x10
	ret

PWND_STR:
.asciz " PWND:[checkm8]"
