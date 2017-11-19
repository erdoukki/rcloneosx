## RcloneOSX

![](icon/rcloneosx.png)

The project is a adapting [RsyncOSX](https://github.com/rsyncOSX/RsyncOSX) utilizing [rclone](https://rclone.org/) for synchronizing and backup of catalogs and files to a number of cloud services. RcloneOSX utilizes `rclone copy`, `sync`, `move` and `check` commands. The project is still early in development, but is quite stable.

RcloneOSX is compiled with support for macOS version 10.11 - 10.13. The application is implemented in **Swift 4** by using **Xcode 9**. RcloneOSX **require** the `rclone` utility to be installed. If installed in other directory than `/usr/local/bin`, please change directory by user Configuration in RcloneOSX. RcloneOSX checks if there is a `rclone` installed in the provided directory.

RcloneOSX is built upon the code for [RsyncOSX](https://github.com/rsyncOSX/RsyncOSX). A short [intro](https://rsyncosx.github.io/Documentation/docs/RcloneOSX/Intro/Intro.html) about what RcloneOSX is.

#### SwiftLint

As part of this version of RcloneOSX I am using [SwiftLint](https://github.com/realm/SwiftLint) as tool for writing more readable code.

### Application icon

The application icon is created by [Forrest Walter](http://www.forrestwalter.com/). All rights reserved to Forrest Walter.

### Changelog

Please see [Changelog](https://rsyncosx.github.io/Documentation/docs/RcloneOSX/Changelog.html)
