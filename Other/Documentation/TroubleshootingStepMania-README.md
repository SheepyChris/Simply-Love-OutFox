## My controller doesn't work on SM5.3, but it did on older versions.
Alpha 4.5 switched to using an XInput-compliant input system by default; additional configuration is needed to use unrecognized controllers in this mode. See [here](https://projectmoon.dance/help/controllers) for more information on how to map your controller for use in XInput mode on StepMania 5.3.

As of [Alpha 4.8.1](https://projectmoon.dance/news/stepmania-53-alpha-48-released), a HIDAPI-based "Legacy" input system was introduced as an option in the Experimental Settings menu. It is similar in behaviour to the input system seen in SM 5.0, but rewritten. If you are having difficulty getting a controller to work in XInput mode or if it performed better under the input handling of previous versions, we recommend that you try it on Legacy mode.

## Windows

**1.** Follow along with the StepMania installer, ensuring that you **do not install to Program Files** to avoid conflicts with Windows UAC.  By default, the installer will install to `C:\Games\` and this is recommended.

**2.** You'll likely need Microsoft's [Visual C++ x86 Redistributable for Visual Studio 2015](http://www.microsoft.com/en-us/download/details.aspx?id=48145).

**3.** If you're using SM5.1-beta2, you'll also need to have Microsoft's [DirectX 9 runtime](https://www.microsoft.com/en-ca/download/details.aspx?id=35).  It's possible you already have it installed from something else, but if StepMania crashes with <strong>d3dx9_43.dll was not found</strong> or <strong>XINPUT1_3.dll is missing</strong>, you don't, and you'll need to install it.

## macOS

### 10.15 Catalina

macOS 10.15 (Catalina) dropped support for 32-bit apps.  As a result, SM5.1-beta2 is not compatible with macOS 10.15. StepMania 5.3 is fully supported.

### older versions of macOS

If you're running an older version of macOS (10.7 to 10.14), you can still use SM5.1-beta2.

### I'm having issues launching the game.

If you receive errors such as "No noteskins found" or other unusual behavior, you will have to change macOS security settings in order for Project OutFox to operate correctly. The OS does not trust unsigned applications, and prevents access to external files unless given manual permission by the user.

To do this, open Terminal and run the following command: `xattr -dr com.apple.quarantine /path/to/OutFox`

Alternatively, you can exclude the path, and drag the folder containing the game executable directly onto the window.

## Linux

### I get the error "error while loading shared libraries: libOpenGL.so.0:" on Ubuntu 20.04-based distributions

Install the `libopengl0` package. (`sudo apt install ibopengl0`)

If the precompiled executable for SM5.1-beta2 is not compatible with your architecture/distro/etc., you'll likely have better luck building from source.

* [Linux Dependencies](https://github.com/stepmania/stepmania/wiki/Linux-dependencies)
* [Instructions on Compiling](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania)
