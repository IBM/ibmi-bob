
/* ====================================================================================== */
/* EXECWTHLIB - Add library list entry, then issue a command.                              */
/* ====================================================================================== */

             CMD        PROMPT('ADDLIBLE, then issue a command')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) RSTD(*NO) MIN(0) MAX(1) PROMPT('Library')

             PARM       KWD(CMD) TYPE(*CMDSTR) LEN(5000) MIN(1) MAX(1) VARY(*YES *INT2) +
                          CASE(*MONO) PROMPT('Command')
