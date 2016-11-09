#!/bin/bash

sudo fdisk -l

    Disk /dev/mmcblk0: 7948 MB, 7948206080 bytes
    4 heads, 16 sectors/track, 242560 cylinders, total 15523840 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x0002c262

            Device Boot      Start         End      Blocks   Id  System
    /dev/mmcblk0p1            8192      122879       57344    6  FAT16
    /dev/mmcblk0p2          122880    15523839     7700480   83  Linux

    Disk /dev/sda: 7860 MB, 7860125696 bytes   -  Kingston microSD 8GB
    242 heads, 62 sectors/track, 1023 cylinders, total 15351808 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x0002c262

       Device Boot      Start         End      Blocks   Id  System
    /dev/sda1            8192      122879       57344    6  FAT16
    /dev/sda2          122880    15523839     7700480   83  Linux



sudo blockdev --getsize64 /dev/mmcblk0
    7948206080  (Bytes)
sudo blockdev --getsize /dev/mmcblk0p2
    15400960    (512 Blocks)
sudo blockdev --getsize64 /dev/mmcblk0p2
    7885291520  (Bytes)
    7700480     (KBytes)

sudo blockdev --getsize /dev/sda2
    15228928    (512 Blocks)
sudo blockdev --getsize64 /dev/sda2
    7797211136  (bytes)
    7614464     (KBytes)


#  UUID="6EC3-6341" TYPE="vfat"
sudo blockdev --getsize64 /dev/sda
    7969177600  (bytes)
sudo blockdev --getsize   /dev/sda
    15564800    (512 Blocks)



Cerco di mantenermi un pò al di sotto e quindi forzo a:
    Block_512:     15228800
    Block_1K:       7614400
    Block_4K:       1903600
    Bytes:       7797145600

sudo resize2fs /dev/sda2 7614400K
    resize2fs 1.42.5 (29-Jul-2012)
    Resizing the filesystem on /dev/sda2 to 1903600 (4k) blocks.
    The filesystem on /dev/sda2 is now 1903600 blocks long.

sudo fdisk /dev/sda
    Command (m for help): d
    Partition number (1-4): 2

    Command (m for help): n


-----------
# ----- ????  SD - 8GB
    blkid
        /dev/mmcblk0p1: SEC_TYPE="msdos" LABEL="boot" UUID="C0E6-1BEB" TYPE="vfat"
        /dev/mmcblk0p2: UUID="9c7e2035-df9b-490b-977b-d60f2170889d" TYPE="ext4"

    sudo fdisk -l /dev/mmcblk0

        Disk /dev/mmcblk0: 7948 MB, 7948206080 bytes
        4 heads, 16 sectors/track, 242560 cylinders, total 15523840 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk identifier: 0x0002c262

                Device Boot      Start         End      Blocks   Id  System
        /dev/mmcblk0p1            8192      122879       57344    6  FAT16
        /dev/mmcblk0p2          122880    15523839     7700480   83  Linux


# ----- KingSton 2 microSD - 8GB
    sudo fdisk /dev/sda
        Disk /dev/sda: 7860 MB, 7860125696 bytes
        242 heads, 62 sectors/track, 1023 cylinders, total 15351808 sectors



# --------------------------------
# ----- aggiusta partizione
# --------------------------------
sudo fdisk /dev/sda
    Command (m for help): p

        Disk /dev/sda: 7860 MB, 7860125696 bytes
        242 heads, 62 sectors/track, 1023 cylinders, total 15351808 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk identifier: 0x0002c262

           Device Boot      Start         End      Blocks   Id  System
        /dev/sda1            8192      122879       57344    6  FAT16
        /dev/sda2          122880    15523839     7700480   83  Linux

    Command (m for help): d             [delete Partition]
    Partition number (1-4): 2

    Command (m for help): p             [print Partition Table]

        Disk /dev/sda: 7860 MB, 7860125696 bytes
        242 heads, 62 sectors/track, 1023 cylinders, total 15351808 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk identifier: 0x0002c262

           Device Boot      Start         End      Blocks   Id  System
        /dev/sda1            8192      122879       57344    6  FAT16

    Command (m for help): n         [create new Partition]
        Partition type:
           p   primary (1 primary, 0 extended, 3 free)
           e   extended
        Select (default p): p
        Partition number (1-4, default 2): 2
        First sector (2048-15351807, default 2048): 122880
        Last sector, +sectors or +size{K,M,G} (122880-15351807, default 15351807): +7614400K

    Command (m for help): p

        Disk /dev/sda: 7860 MB, 7860125696 bytes
        242 heads, 62 sectors/track, 1023 cylinders, total 15351808 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disk identifier: 0x0002c262

           Device Boot      Start         End      Blocks   Id  System
        /dev/sda1            8192      122879       57344    6  FAT16
        /dev/sda2          122880    15351679     7614400   83  Linux

    Command (m for help): w
        The partition table has been altered!

        Calling ioctl() to re-read partition table.
        Syncing disks.



    sudo fsck -n /dev/sda2
        fsck from util-linux 2.20.1
        e2fsck 1.42.5 (29-Jul-2012)
        /dev/sda2: clean, 108255/483328 files, 1018525/1903600 blocks


    Then we create the journal on our new /dev/sda1, thus turning it into an ext3 partition again:
    sudo tune2fs -j /dev/sda2

        tune2fs 1.42.5 (29-Jul-2012)
        Creating journal inode: done




