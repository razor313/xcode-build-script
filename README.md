# xcode-build-script
This shell script build and export IPA file for Xcode project that used Maven

Maybe you have to use the Maven-Xcode-Plugin for many reasons such as
-your source control is SVN 
-you want to use Maven-Release-Plugin
-you want to generate change list with the Maven-Site-Plugin.

You cannot use Pod (dependency management) and the Maven-Xcode-Plugin on a project because when Pod is used, it will change structure of your project and made Xcworkspace file.

You have to build your project with Xcworkspace instead of Xcproject file and the Maven Xcode plugin doesn't support this manner build :(

I write a shell script that does build and export IPA file (if the build was succeeding)

Prequesit:
1) Install Xcode 9.X with command line tools.
2) Make/define Plist file like this tutorial.
