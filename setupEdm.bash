export EDM=/sdf/group/cds/sw/epics/config/edm/display
export EDMACTIONS=/sdf/group/cds/sw/epics/config/edm
export EDMDUMPFILES=/sdf/data/cds/dev/edm
export EDMFILES=/sdf/group/cds/sw/epics/config/edm
export EDMFILTERS=/sdf/group/cds/sw/epics/config/edm
export EDMHELPFILES=/sdf/sw/epics/extensions/R1.3.3/helpFiles
export EDMLIBS=/sdf/sw/epics/extensions/R1.3.3/lib/rhel9-x86_64
export EDMOBJECTS=/sdf/group/cds/sw/epics/config/edm
export EDMPVOBJECTS=/sdf/group/cds/sw/epics/config/edm
export EDMUSERLIB=/sdf/sw/epics/extensions/R1.3.3/lib/rhel7-x86_64
export EDMUSERS=/sdf/data/cds/dev/edm/display
export EDMWEBBROWSER=mozilla
export EDM_DATA=/sdf/data/cds/dev/edm

#
# Add 'newlist' command to manage lists like PATH, EPICS_CA_ADDR_LIST, etc.
#
if [ ! $(declare -f -F newlist) ];
then
        if [ -r $EPICS_SETUP/newlist.sh ];
        then
                source $EPICS_SETUP/newlist.sh
        else
                printf "Cannot find '%s' script for EDM path management.\n" "$EPICS_SETUP/newlist.sh"
                exit 1
        fi
fi

#
# 'newlist' creates functions, see
# top of newlist.sh for details.
#
newlist edm EDMDATAFILES
insedm -q . ..
addedm ${EDM}
addedm ${EDM}/ads
addedm ${EDM}/alh
addedm ${EDM}/autosave
addedm ${EDM}/bcs
addedm ${EDM}/blm
addedm ${EDM}/bpms
addedm ${EDM}/camac
addedm ${EDM}/cf
addedm ${EDM}/cryo
addedm ${EDM}/cud
addedm ${EDM}/event
addedm ${EDM}/facet
addedm ${EDM}/fbck
addedm ${EDM}/gadc
addedm ${EDM}/install
addedm ${EDM}/klys
addedm ${EDM}/knob
addedm ${EDM}/laser
addedm ${EDM}/lcls
addedm ${EDM}/llrf
addedm ${EDM}/mc
addedm ${EDM}/mgnt
addedm ${EDM}/misc
addedm ${EDM}/mps
addedm ${EDM}/ntwk
addedm ${EDM}/odm
addedm ${EDM}/photon_diag
addedm ${EDM}/pps
addedm ${EDM}/prof
addedm ${EDM}/rm
addedm ${EDM}/slc
addedm ${EDM}/temp
addedm ${EDM}/toroid
addedm ${EDM}/und
addedm ${EDM}/vac
addedm ${EDM}/watr
addedm ${EDM}/ws
addedm ${EDM}/xray
