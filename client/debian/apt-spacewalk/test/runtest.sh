#!/bin/bash

set -e
set -o pipefail

. library.sh
. settings.sh


rlJournalStart
    rlPhaseStartSetup
        for pkg in ${required_packages}; do
            rlAssertDpkg ${pkg} || rlDie "Install ${pkg} first"
        done

        seed=$(date +%N | tr [:print:] a-z | fold -w5 | head -n1)
        rlFileBackup /etc/sysconfig/rhn/
    rlPhaseEnd



    rlPhaseStartSetup 'Build packages'
        old_pwd=`pwd`
        build_dir="${old_pwd}/build/"
        template="${old_pwd}/equivs-template"
        rlRun "rm -rf ${build_dir}"

        for arch in all `rlGetArch`; do
            rlRun "mkdir -p ${build_dir}/${arch}"
            cd ${build_dir}/${arch}
            for i in `seq ${package_count}`; do
                name="dum-${arch}-${i}-${seed}"
                cp ${template} ${name}
                sed -i s/%name%/${name}/g ${name}
                sed -i s/%arch%/${arch}/g ${name}
                sed -i s/%version%/1.1/g ${name}
                rlRun "equivs-build ${name} &> /dev/null"
                sed -i s/1.1/2.2/g ${name}
                rlRun "equivs-build ${name} &> /dev/null"
                rm -rf ${name}
                package_list="${package_list} $name"
            done
        done
        cd ${old_pwd}
    rlPhaseEnd



    rlPhaseStartSetup 'Create channels'
        channel_name="debian_${seed}"
        child_channel_name="child_${seed}"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} \
            create_channel ${channel_name} `rlGetArch`"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} \
            create_channel ${child_channel_name} `rlGetArch` ${channel_name}"
        rlRun "rhnpush --server ${SW_SERVER} -u ${SW_USER} -p ${SW_PASS} \
            -vvv -c  ${channel_name} -d ${build_dir}/all"
        rlRun "rhnpush --server ${SW_SERVER} -u ${SW_USER} -p ${SW_PASS} \
            -vvv -c  ${child_channel_name} -d ${build_dir}/`rlGetArch`"
        ak=`./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} \
            create_activationkey ${channel_name} ${child_channel_name}| head -n1`
    rlPhaseEnd



    rlPhaseStartSetup 'Register'
        rlRun "wget -q -O /etc/sysconfig/rhn/RHN-ORG-TRUSTED-SSL-CERT \
            https://${SW_SERVER}/pub/RHN-ORG-TRUSTED-SSL-CERT --no-check-certificate"
        rlRun "rhnreg_ks --sslCACert=/etc/sysconfig/rhn/RHN-ORG-TRUSTED-SSL-CERT -v \
            --serverUrl=https://${SW_SERVER}/XMLRPC --activationkey=${ak} --force"
    rlPhaseEnd



    rlPhaseStartTest 'rhn-profile-sync'
        rlRun 'rhn-profile-sync -v'
    rlPhaseEnd



    rlPhaseStartTest 'Taskomatic'
        rlRun "apt-get clean"
        rlRun "apt-get update" 0,100
        # Workaround for those who don't have Apt patched
        rlRun "apt-get update" 0,100

        rlRun "sleep 1m" 0 "Waiting for taskomatic to regenerate metadata"
    rlPhaseEnd



    rlPhaseStartTest "apt-get update"
        rlRun "apt-get update"
        sources_list=/etc/apt/sources.list.d/spacewalk.list
        rlAssertExists ${sources_list}
        rlAssertGrep "deb spacewalk://${SW_SERVER} channels: main ${child_channel_name}" ${sources_list}
    rlPhaseEnd



    rlPhaseStartTest "Install packages"
        for pkg in ${package_list}; do
            rlRun "apt-get install ${pkg}=1.1 -y --force-yes"
        done

        tmp=`mktemp`
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} system_package_list \
            ${channel_name} ${child_channel_name} > ${tmp}"
        for pkg in ${package_list}; do
            rlAssertGrep ${pkg}-1.1 ${tmp}
        done
        rm -rf $tmp
    rlPhaseEnd



    rlPhaseStartTest "Schedule actions"
        pkg1_id=`./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} channel_package_list ${channel_name} | head -n1`
        pkg2_id=`./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} channel_package_list ${child_channel_name} | head -n1`
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} package_install ${pkg1_id} ${pkg2_id}"
    rlPhaseEnd



    rlPhaseStartTest "Pick-up actions"
        rlRun "rhn_check -vvv"

        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} system_package_list \
            ${channel_name} ${child_channel_name} | grep dum | grep ${seed} | grep 2.2"
    rlPhaseEnd



    rlPhaseStartTest "Update"
        rlRun "apt-get install ${package_list} -y --force-yes"

        tmp=`mktemp`
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} system_package_list \
            ${channel_name} ${child_channel_name} > ${tmp}"
        for pkg in ${package_list}; do
            rlAssertGrep ${pkg}-2.2 ${tmp}
        done
        rm -rf $tmp
    rlPhaseEnd



    rlPhaseStartCleanup
        for pkg in ${package_list}; do
            dpkg -l ${pkg} &> /dev/null \
                && rlRun "apt-get remove ${pkg} -y --force-yes &>/dev/null"
        done

        rlRun "rm -rf ${build_dir}"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} remove_activationkey ${ak}"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} remove_channel ${child_channel_name}"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} remove_channel ${channel_name}"
        rlRun "./sw_deb.py ${SW_SERVER} ${SW_USER} ${SW_PASS} unregister"
        rlFileRestore
    rlPhaseEnd

rlJournalEnd
rlJournalPrintText
