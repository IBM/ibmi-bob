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

/* ====================================================================================== */
/* CVTSRCF - Convert source physical file members to ASCII IFS files.                     */
/* ====================================================================================== */

             CMD        PROMPT('Convert source physical file')

             PARM       KWD(FILE) TYPE(NAME1) MIN(1) PROMPT('File')
             PARM       KWD(TODIR) TYPE(*PNAME) LEN(512) RSTD(*NO) MIN(1) MAX(1) +
                        CASE(*MIXED) PROMPT('To directory')
             PARM       KWD(STMFCCSID) TYPE(*UINT2) PROMPT('Stream file CCSID') +
                        DFT(1208) PMTCTL(*PMTRQS)
             PARM       KWD(BOBDIR) TYPE(*PNAME) LEN(512) RSTD(*NO) MAX(1) +
                        CASE(*MIXED) PROMPT('Path to Bob directory') +
                        DFT('/Build/Bob') PMTCTL(*PMTRQS)

NAME1:       QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) MIN(1) PROMPT('Library')