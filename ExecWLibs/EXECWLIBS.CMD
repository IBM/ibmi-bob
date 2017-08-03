/* Copyright 2017 S4i Systems, Inc.                                         +
 *                                                                          +
 * Licensed under the Apache License, Version 2.0 (the "License");          +
 * you may not use this file except in compliance with the License.         +
 * You may obtain a copy of the License at                                  +
 *                                                                          +
 *     http://www.apache.org/licenses/LICENSE-2.0                           +
 *                                                                          +
 * Unless required by applicable law or agreed to in writing, software      +
 * distributed under the License is distributed on an "AS IS" BASIS,        +
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. +
 * See the License for the specific language governing permissions and      +
 * limitations under the License.                                           +
 */

/* ========================================================================= */
/* EXECWLIBS - Add library list entries, then issue a command.               */
/* ========================================================================= */

             CMD        PROMPT('ADDLIBLE, then issue a command')

             PARM       KWD(CMD) TYPE(*CMDSTR) LEN(5000) MIN(1) MAX(1) VARY(*YES *INT2) CASE(*MONO) +
                          PROMPT('Command')

             PARM       KWD(LIB) TYPE(*NAME) LEN(10) MIN(0) MAX(250) PROMPT('Libraries')
