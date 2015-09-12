/* fdc8272.h -- declarations from the Intel 8272 FDC driver */
#ifndef _FDC8272_H
#define _FDC8272_H 1
#include "mytypes.h"
#include "io.h"
#include "mfpic.h"

#define _DUAL_IDE	1
#define FULL_COMMAND_SET	0

#ifdef M68000
#define	address	dword
#define	input(a)	inp(a)
#define	output(a,b) outp((a),(b))
#endif


#ifdef _DUAL_IDE
/*#define fdc_base_port	0x2A */
word fdc_base_port;

#define fdc_status_port (fdc_base_port)
#define fdc_data_port	(fdc_base_port+1)
#define fdc_WD_ldor		(fdc_base_port+2)
#define fdc_WD_ldcr		(fdc_base_port+3)
#define fdc_8in_fault_reset	(fdc_base_port+16)
#define fdc_tc				(fdc_base_port+17)
#define fdc_dack			(fdc_base_port+18)
#define fdc_dack_and_tc	(fdc_base_port+19)
/* the following is on the MF/PIC board, rev. 1.1 (or rev. 1.0 + update) */
#define fdc_dreq			(mf_rtc & 0xFF)
#else
#define fdc_status_port 0x30
#define fdc_data_port	0x31
#endif

/* FDC commands -- with MT, MF, SK, where applicable */
#define	MT	0x80
#define	MF	0x40
#define	SK 0x20

#define fdc_cmd_read_data		(MT|MF|SK + 6)
#define fdc_cmd_write_data		(MT|MF + 5)
#define fdc_cmd_read_id			(MF + 10)
#define fdc_cmd_format_track	(MF + 13)
#define fdc_cmd_recalibrate		7
#define fdc_cmd_sense_int_status	8
#define fdc_cmd_specify				3
#define fdc_cmd_sense_drive_status	4
#define fdc_cmd_seek					15
#define fdc_cmd_read_a_track			(MF|SK + 2)

#if FULL_COMMAND_SET
#define fdc_cmd_scan_high_or_equal	(MT|MF|SK + 16+13)
#define fdc_cmd_scan_low_or_equal	(MT|MF|SK + 16+9)
#define fdc_cmd_scan_equal				(MT|MF|SK + 16+1)
#define fdc_cmd_write_deleted_data	(MT|MF + 9)
#define fdc_cmd_read_deleted_data	(MT|MF + 12)
#endif



/* #define fdc_int_level		0x33 */

/* return status and error code */
#define error	0
#define ok		1
#define complete 3
#define false	0
#define true	1
#define error_in	!
#define not !
#define propagate_error		return error

#define stat_ok	0
#define stat_busy	1
#define stat_error 2
#define stat_command_error 3
#define stat_result_error	4
#define stat_invalid	5

/* masks */
#define busy_mask	0x10
#define DIO_mask	0x40
#define RQM_mask	0x80
#define seek_mask	0x0F
#define result_error_mask 0xC0
#define result_drive_mask 0x03
#define result_ready_mask 0x08

/* ST3 bits */
#define st3_wp		0x40
#define st3_rdy	0x20
#define st3_tr0	0x10
#define st3_wp2	0x08
#define st3_hs		0x04
#define st3_us1	0x02
#define st3_us0	0x01

/* drive numbers */
#define max_no_drives	3
#define fdc_general		max_no_drives+1

/* miscellaneous control */
#define any_drive_seeking	((input(fdc_status_port) & seek_mask) != 0)
#if FULL_COMMAND_SET
#define command_code	(docb.disk_command[0] & 0x1F)
#else
#define command_code	(docb.disk_command[0] & 0x0F)
#endif
#define DIO_set_for_input	((input(fdc_status_port) & DIO_mask) == 0)
#define DIO_set_for_output	((input(fdc_status_port) & DIO_mask) != 0)
#define extract_drive_no	(docb.disk_command[1] & 0x03)
#define fdc_busy	((input(fdc_status_port) & busy_mask) != 0)
#define no_fdc_error	possible_error[command_code] && ((docb.disk_result[0] & result_error_mask) == 0)
#define wait_for_op_complete	while (!operation_complete[drive_no])
#define wait_for_RQM	while ((input(fdc_status_port) & RQM_mask) == 0)

/* structures */

typedef				/* disk operation control block */
struct	DOCB	{
	/* byte	dma_op;     move down */
	address	dma_addr;
	/* no dma_addr_ext byte; */
	word	dma_count;
	byte	disk_command[9];
	byte	dma_op;		/* moved to here */
	byte	disk_result[7];
	byte	misc;
}	T_docb;


/* globally available variables */

byte drive_status_change[fdc_general];		/* indicates drive status changed */
byte drive_ready[fdc_general];		/* current status of drive */
extern T_docb* operation_docb_ptr[fdc_general+1];


/* global procedures */

void initialize_drivers(void);

/* interrupt enable/disable procedures (implementation dependent) */
void enable(void);
void disable(void);



/* common to IBM, WD, & Intel drivers */

typedef
struct PARAM {
	byte srt_hut;		/* specify command */
	byte hlt_nd;		/* " */
	byte timeout;		/* not sure */
	byte N;				/* data length, N, major */
	byte eot;			/* end of track (max sector #) */
	byte gpl;			/* gap length 1 */
	byte dtl;			/* data length, minor */
	byte gpl3;			/* gap length 3 */
	byte data;			/* filler data D */
	byte del_mot_on;	/* motor turnon delay ??? */
	byte del_cmd;		/* 2 revolution delay command timeout */
	byte cylm1;			/* max. cylinder - 1 */
	byte unk3;			/* unknown, perhaps related to data density */
	byte osc;			/* WD37C65 Control Reg value */
} T_param;

#include "myide.h"

typedef
struct FLOPPY {
	struct DISK disk;			/* same as IDE disks */
	const T_param *param;
	T_docb  *docb;				/* pointer to Intel disk-oper. control block */
	byte	last_seek;			/* cylinder of last seek */
} T_floppy;



extern const T_param *fdc_parameters[];


#endif	/* _FDC8272_H */
