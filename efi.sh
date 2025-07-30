#!/bin/bash

make bin/ipxe.lkrn bin-x86_64-efi/ipxe.efi EMBED=
./util/genfsimg -o ipxe.iso bin/ipxe.lkrn bin-x86_64-efi/ipxe.efi
