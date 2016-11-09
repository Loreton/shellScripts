#!/bin/bash

# Backup della schedina SD del RaspBerry
#
#                                                   Bytes        Blocks 512     Blocks 1024      Blocks 8192
# KingSton 1 microSD - 8GB - N0514-001 A00LF      7969177600      15564800       7782400           972800
# KingSton 1 microSD - 8GB - N0538-002 A01LF      7860125696      15351808       7675904           959488
# SanDisk 1 microSD  - 8GB - 5227DKG6T1H5         7948206080      15523840       7761920           970240


nohup sudo dd if=/dev/mmcblk0 conv=sync,noerror bs=8192 count=959488 of=/dev/sda &


# ###############################################################
# # http://www.gossamer-threads.com/lists/gentoo/user/230606
# ###############################################################
    # You can try finding the optimum size of the bs= value by creating a partition
    # on the new disk, formating it and then run something like:
    #
    # dd if=/dev/zero bs=1024 count=1000000 of=/1G_test.file        [ Loreto: 1024000000 bytes (1.0 GB) copied, 93.8943 s, 10.9 MB/s ]
    # dd if=/dev/zero bs=2048 count=500000 of=/1G_test.file
    # dd if=/dev/zero bs=4096 count=250000 of=/1G_test.file
    # dd if=/dev/zero bs=8192 count=125000 of=/1G_test.file         [ Loreto: 1024000000 bytes (1.0 GB) copied, 79.8705 s, 12.8 MB/s ]
    #
    # and compare the results that dd reports. bs=4096 often gives best performance
    # (on my drives at least) but with the new 1T+ drives you may find that another
    # block size does the job better.
    #
    # Then zero the drive first using dd:
    #
    # nohup sudo dd if=/dev/zero of=/dev/sda bs=4096 oflag=direct conv=notrunc &
    #
    # and try repeating your restoring from back up with a more suitable block size.

# ###############################################################
# # http://www.gossamer-threads.com/lists/gentoo/user/230606
# ###############################################################
    #   Done - and its worked.
    #
    #   Here's what i did;
    #   1. Take existing drive out of laptop and connect to Gentoo box using an
    #   esata box, then
    #   sphinx ~ # dd if=/dev/sdb bs=10M conv=notrunc,noerror | gzip > windisk.gz
    #   5723+1 records in
    #   5723+1 records out
    #   60011642880 bytes (60 GB) copied, 5667.78 s, 10.6 MB/s
    #
    #   For interests sake, windows reports that 51gig is in use, which along with
    #   the free space has compressed down to
    #   sphinx ~ # ls -lh win*
    #   -rw-r--r-- 1 root root 37G May 17 12:29 windisk.gz
    #
    #   2. Swap existing disk to new drive, then
    #   sphinx ~ # gunzip -c windisk.gz | dd of=/dev/sdb bs=10M conv=notrunc
    #   0+1819751 records in
    #   0+1819751 records out
    #   60011642880 bytes (60 GB) copied, 940.652 s, 63.8 MB/s
    #
    #   3. Boot into windows. After login it says "You must restart your computer to
    #   apply these changes", so i restart. Then go into Disk managment and select
    #   "Extend Volume", which immediately makes all the space was immediately
    #   available. Paranoia says run a disk check, which windows offers to schedule
    #   at next reboot. I accept and reboot, check runs and no errors are reported,
    #   so im :)
    #
    #   Thanks again list!



    #   Benchmarking drive performance[edit]
    #   To make drive benchmark test and analyze the sequential (and usually single-threaded) system read and write performance for 1024-byte blocks:
    #
    #       WRITE:
    #            dd if=/dev/zero bs=1024 count=1000000 of=/1G_test.file  --> Loreto: 1024000000 bytes (1.0 GB) copied, 93.8943 s, 10.9 MB/s
    #            dd if=/dev/zero bs=2048 count=500000 of=/1G_test.file
    #            dd if=/dev/zero bs=4096 count=250000 of=/1G_test.file
    #            dd if=/dev/zero bs=8192 count=125000 of=/1G_test.file   --> Loreto: 1024000000 bytes (1.0 GB) copied, 79.8705 s, 12.8 MB/s
    #
    #       READ:
    #            dd if=file_1GB of=/dev/null bs=1024 --> 1024000000 bytes (1.0 GB) copied, 55.2414 s, 18.5 MB/s
    #            dd if=file_1GB of=/dev/null bs=8192 --> 1024000000 bytes (1.0 GB) copied, 55.101 s, 18.6 MB/s
    #
    #   Generating a file with random data[edit]
    #       To make a file of 100 random bytes using the kernel random driver:
    #           dd if=/dev/urandom of=myrandom bs=100 count=1
    #
    #   To convert a file to uppercase:
    #       dd if=filename of=filename1 conv=ucase

# nohup sudo dd if=/dev/zero of=/dev/sda bs=512  count=15400000 oflag=direct conv=notrunc &
# nohup sudo dd if=/dev/zero of=/dev/sda bs=8192 count=962500   oflag=direct conv=notrunc &
# nohup sudo dd if=/dev/zero of=/dev/sda bs=4096 oflag=direct conv=notrunc &

# Bytes da scrivere: 7.884.800.000
# sudo dd if=/dev/mmcblk0 conv=sync,noerror bs=512 count=15400000 of=/dev/sda &
# sudo dd if=/dev/mmcblk0 conv=sync,noerror bs=8192 count=962500 of=/dev/sda &

# ################################################
# - Calcolare il size di un disco
# - http://unix.stackexchange.com/questions/52215/determine-the-size-of-a-block-device
# ################################################
        # pi-Ln ~ $: cat /proc/partitions
        # major minor  #blocks  name
        #
        #  179        0    7761920 mmcblk0
        #  179        1      57344 mmcblk0p1
        #  179        2    7700480 mmcblk0p2
        #    8        0    7675904 sda
        # pi-Ln ~ $: echo $(( 1024 * 7675904 ))
        # 7860125696
    # oppure
        # blockdev --getsize64 /dev/sda returns size in bytes.
        # blockdev --getsize   /dev/sda returns size in sectors.
        #
        # pi-Ln ~ $: sudo blockdev --getsize64 /dev/sda
        # 7860125696    (bytes)
        # pi-Ln ~ $: sudo blockdev --getsize /dev/sda
        # 15351808      (sectors)
        # pi-Ln ~ $: echo $(( 512 * 15351808 ))
        # 7860125696
    # oppure:
        # cat /sys/class/block/sda/size    (in blocchi da 512)

# Per schedina Kingdom 8GBytes
nohup sudo dd if=/dev/mmcblk0 conv=sync,noerror bs=8192 count=959488 of=/dev/sda &

################################################################################
nohup sudo dd if=/dev/mmcblk0 conv=sync,noerror bs=8192 count=970240 of=/mnt/LN1TB_A/Appo/PImage_2015-08-12.img &

970240+0 records in
970240+0 records out
7948206080 bytes (7.9 GB) copied, 3731.45 s, 2.1 MB/s

ll /mnt/LN1TB_A/Appo/
total 8667005
-rw-rw-r-- 1 pi pi 7303200768 Aug 12 21:37 PI_Image_2015-08-12.img



