#
# simple python script for conversion of 
# Lipid14 POPC residue names with duplicate atom names 
# to a split-residue convention: 
#   POPC will be split into 3 virtual residues with names
#   PALM - POPC - OLE
#   so that duplicate atom names can be distinquished at least
#   by a different residue name
#
# script assumes the particular ordering as above with 
# the head group segment beginning with O12 and ending with O22
# the rest (begin/end) being the tails PALM/OLE.


# last edit 29-Jan 2018 by Josef Melcr

# BEWARE: The update to MDAnalysis has lead to 
#         an unfortunate (to me and this script) 
#         lack of special function of this scipt
#         i.e. it does not give a special resname to 
#         subsections of a single residue.
#         As I plant to work with IUPAB (Charmm36) style of atom naming in the future,
#         I'm not correcting this in this script and leave it malfunctioning. 

import MDAnalysis as mda
from optparse import OptionParser

# help message is automatically provided
# type=string, action=store is default
parser = OptionParser()
parser.add_option('-i', '--inp',  dest='inp_fname',  help='input MDanalysis topology file name', default="last_frame_nonwat.gro")
parser.add_option('-o', '--out',  dest='out_fname',  help='output MDanalysis topology file name', default="last_frame_nonwat.gro")
opts, args = parser.parse_args()

print """
 BEWARE: The update to MDAnalysis has lead to 
         an unfortunate (to me and this script) 
         lack of special function of this scipt
         i.e. it does not give a special resname to 
         subsections of a single residue.
         As I plant to work with IUPAB (Charmm36) style of atom naming in the future,
         I'm not correcting this in this script and leave it malfunctioning. 
"""

u = mda.Universe(opts.inp_fname)

# find some POPC residue
try:
    for r in u.residues:
        if r.resname == "POPC":
            # find the indices of the first/last head group atoms
            for a in r.atoms:
                if a.name == "O12":
                    headgr_begin_index = a.id
                if a.name == "O22":
                    headgr_end_index = a.id
            break


    # resname the resnames of PALM and OLE segments
    for r in u.residues:
        if r.resname == "POPC":
            for a in r.atoms[:headgr_begin_index]:
                a.residue.resname = "PALM"
            for a in r.atoms[headgr_end_index+1:]:
                a.residue.resname = "OLE"

    # write the new topology out
    u.trajectory.Writer(opts.out_fname)

except:
    print "Couldn't find a POPC residue -- already renamed to PALM-POPC-OLE?"

