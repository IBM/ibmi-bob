**free
// ============================================================================
// EXECWTHLIB - Execute command with library in the library list
// ============================================================================

ctl-opt stgmdl(*teraspace);

dcl-pi EXECWTHLIB extpgm;
   pLib char(10) const;
   pCmd varchar(5000) const;
end-pi;

// Prototypes
dcl-pr QCmdExc extpgm;
   cmd char(5000) const options(*varsize);
   cmdLen packed(15:5) const;
end-pr;

dcl-pr resendEscapeMessage extpgm('QMHRSNEM');
   messageKey char(4) const;
   error char(1) options(*varsize) const;
   toCallStackEntry char(1) options(*varsize) const;
   toCallStackEntryLength int(10) const;
   format char(8) const;
   fromCallStackEntryAddress pointer;
   fromCallStackCounter int(10) const;
end-pr;

dcl-pr receiveProgramMessage extpgm('QMHRCVPM');
   messageInfo char(1) options(*varsize) const;
   messageInfoLen int(10) const;
   formatName char(8) const;
   callStackEntry char(1) options(*varsize) const;
   callStackCounter int(10) const;
   messageType char(10) const;
   messageKey char(4) const;
   waitTime int(10) const;
   messageAction char(10) const;
   error char(1) options(*varsize) const;
end-pr;

// Declarations
dcl-s cmd char(5000);
dcl-s cmdLen packed(15:5);
dcl-s nullPtr pointer inz;

dcl-ds error qualified;
   provided int(10) inz(%size(error));
   avail int(10) inz(0);
   msgid char(7);
   rsvd char(1);
   msgdta char(256);
end-ds;

dcl-ds rsnm0200 qualified;
   toCallStackEntryAddress pointer inz(*null);
   toCallStackCounter int(10) inz(1);
   pointerQualifier char(10) inz('*PGMBDY');
end-ds;

dcl-ds rcvm0100 qualified;
   bytesReturned int(10);
   bytesAvail int(10);
   msgSeverity int(10);
   msgId char(7);
end-ds;

// Mainline

// Add library to library list.  It's ok if it's already there.
if  pLib <> *blanks;
   cmd = 'ADDLIBLE ' + pLib;
   cmdLen = %len(cmd);
   callp(e) QCmdExc(cmd: cmdLen);

   // Forward error message back to caller, unless it's "Library already exists".
   if %error;
      error.avail = 0;
      callp(e) receiveProgramMessage(
                rcvm0100:
                %size(rcvm0100):
                'RCVM0100':
                '*':
                0:
                '*ESCAPE':
                ' ':
                0:
                '*SAME':
                error);

      if rcvm0100.msgId = 'CPF2103'; // Library already exists
         error.avail = 0;
         callp(e) receiveProgramMessage(
                   rcvm0100:
                   %size(rcvm0100):
                   'RCVM0100':
                   '*':
                   0:
                   '*ESCAPE':
                   ' ':
                   0:
                   '*REMOVE':
                   error);
      else;
         forwardEscape();
      endif;
   endif;
endif;

// Call user's command.  If an error occurred, forward the escape message back
// up the call stack so the Make tool will detect it.
cmd = pCmd;
cmdLen = %len(%trim(cmd));
callp(e) QCmdExc(cmd: cmdLen);

if %error;
   forwardEscape();
endif;

*inlr = *on;
return;

// Forward escape message to caller
dcl-proc forwardEscape;
   error.avail = 0;
   callp(e) resendEscapeMessage (
             ' ':
             error:
             rsnm0200:
             %size(rsnm0200):
             'RSNM0200':
             nullPtr:
             1);

   if %error ;   // Temp for testing
      *inlr = *on;
   endif;
end-proc;
